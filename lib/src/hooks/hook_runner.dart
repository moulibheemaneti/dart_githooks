import 'dart:io';

import 'package:glob/glob.dart';

import '../config/config_model.dart';
import '../config/config_parser.dart';
import '../utils/git_utils.dart';
import '../utils/melos_utils.dart';
import '../utils/process_utils.dart';
import 'commit_msg_validator.dart';

class HookRunner {
  /// Called by the generated .git/hooks/ script
  static Future<void> run(String hookName, {String? arg}) async {
    final hookType = HookType.fromString(hookName);

    if (hookType == null) {
      print('❌ Unknown hook "$hookName"');
      exit(1);
    }

    final config = ConfigParser.parse();
    final hookConfig = config.hooks[hookType];

    if (hookConfig == null) {
      print('⚠️  No config found for "$hookName" — skipping.');
      exit(0);
    }

    print('🪝 Running $hookName hooks...');

    if (hookType == HookType.commitMsg) {
      await _runCommitMsgHook(hookConfig, arg);
    } else {
      // fetch staged files only if needed — glob filtering or staged_only is active
      final needsStagedFiles = config.globalConfig.stagedOnly ||
          hookConfig.commands.values.any(
            (c) => c.stagedOnly == true || c.glob != null,
          );

      final stagedFiles =
          needsStagedFiles ? await GitUtils.getStagedFiles() : <String>[];

      if (hookConfig.parallel) {
        await _runParallel(
          hookConfig.commands,
          config.globalConfig,
          stagedFiles,
        );
      } else {
        await _runSequential(
          hookConfig.commands,
          config.globalConfig,
          stagedFiles,
        );
      }
    }
  }

  static Future<void> _runCommitMsgHook(
    HookConfig config,
    String? msgFilePath,
  ) async {
    if (msgFilePath == null) {
      print('❌ No commit message file path provided.');
      exit(1);
    }

    final message = File(msgFilePath).readAsStringSync();

    for (final entry in config.msgCommands.entries) {
      final name = entry.key;
      final cmdConfig = entry.value;

      // universal check — runs regardless of preset
      if (cmdConfig.onlySmallCase) {
        print('  ▶ Running lowercase check...');

        final firstLine = message.trim().split('\n').first;

        if (firstLine != firstLine.toLowerCase()) {
          print('  ❌ lowercase check failed:\n');
          print('  Commit message must be lowercase.');
          print('  Got: $firstLine\n');
          exit(1);
        }

        print('  ✅ lowercase check passed');
      }

      print('  ▶ Running "$name"...');

      if (cmdConfig.preset == 'conventional') {
        final result = CommitMsgValidator.validate(
          message,
          appendTypes: cmdConfig.appendTypes,
          overrideTypes: cmdConfig.overrideTypes,
          onlySmallCase: false,
        );

        if (!result.passed) {
          print('  ❌ "$name" failed:\n');
          print(result.message);
          exit(1);
        }

        print('  ✅ "$name" passed');
      } else {
        print('  ⚠️  Unknown preset "${cmdConfig.preset}" — skipping.');
      }
    }
  }

  static Future<void> _runSequential(
    Map<String, CommandConfig> commands,
    DartHuskyConfig globalConfig,
    List<String> stagedFiles,
  ) async {
    for (final entry in commands.entries) {
      await _runCommand(entry.key, entry.value, globalConfig, stagedFiles);
    }
  }

  static Future<void> _runParallel(
    Map<String, CommandConfig> commands,
    DartHuskyConfig globalConfig,
    List<String> stagedFiles,
  ) async {
    await Future.wait(
      commands.entries.map(
        (e) => _runCommand(e.key, e.value, globalConfig, stagedFiles),
      ),
    );
  }

  static Future<void> _runCommand(
    String name,
    CommandConfig config,
    DartHuskyConfig globalConfig,
    List<String> stagedFiles,
  ) async {
    if (config.preset != null) {
      await _runPreset(name, config, globalConfig, stagedFiles);
      return;
    }

    if (config.run == null) {
      print('  ❌ "$name" has no run command or preset.');
      exit(1);
    }

    if (config.glob != null) {
      final matcher = Glob(config.glob!);
      final hasMatch = stagedFiles.any((f) => matcher.matches(f));
      if (!hasMatch) {
        print('  ⏭️  "$name" skipped — no staged files match "${config.glob}"');
        return;
      }
    }

    print('  ▶ Running "$name"...');

    final useStagedOnly = config.stagedOnly ?? globalConfig.stagedOnly;

    var commandToRun = config.run!;

    if (useStagedOnly && stagedFiles.isNotEmpty) {
      commandToRun = '${config.run!} ${stagedFiles.join(' ')}';
    } else if (useStagedOnly && stagedFiles.isEmpty) {
      print('  ⏭️  "$name" skipped — no staged files.');
      return;
    }

    final parts = commandToRun.split(' ');
    final executable = parts.first;
    final arguments = parts.skip(1).toList();

    final result = await Process.run(executable, arguments, runInShell: true);

    if (result.stdout.toString().isNotEmpty) {
      print(result.stdout);
    }

    if (result.exitCode != 0) {
      print('  ❌ "$name" failed:');
      print(result.stderr);
      exit(result.exitCode);
    }

    print('  ✅ "$name" passed');
  }

  static Future<void> _runPreset(
    String name,
    CommandConfig config,
    DartHuskyConfig globalConfig,
    List<String> stagedFiles,
  ) async {
    if (config.preset == 'melos') {
      await _runMelosPreset(name, config, globalConfig, stagedFiles);
    } else {
      print('  ❌ Unknown preset "${config.preset}" — aborting.');
      exit(1);
    }
  }

  static Future<void> _runMelosPreset(
    String name,
    CommandConfig config,
    DartHuskyConfig globalConfig,
    List<String> stagedFiles,
  ) async {
    print('  ▶ Running "$name"...');

    final allPackages = await MelosUtils.listPackages();

    if (allPackages.isEmpty) {
      print('  ❌ "$name" failed: no melos workspace found. '
          'Is melos installed and configured?');
      exit(1);
    }

    final testCommand = await ProcessUtils.detectTestCommand();

    final useStagedOnly = config.stagedOnly ?? globalConfig.stagedOnly;

    List<String> args;

    if (useStagedOnly) {
      final affected =
          MelosUtils.getAffectedPackageNames(allPackages, stagedFiles);

      if (affected.isEmpty) {
        print('  ⏭️  "$name" skipped — no staged files in any package.');
        return;
      }

      final scopeArgs = affected.expand((p) => ['--scope=$p']).toList();
      args = ['exec', ...scopeArgs, '--', ...testCommand.split(' ')];

      print('  📦 Running tests in: ${affected.join(', ')}');
    } else {
      args = ['exec', '--', ...testCommand.split(' ')];
      print('  📦 Running tests in all packages');
    }

    final result = await Process.run('melos', args, runInShell: true);

    if (result.stdout.toString().isNotEmpty) print(result.stdout);

    if (result.exitCode != 0) {
      print('  ❌ "$name" failed:');
      print(result.stderr);
      exit(result.exitCode);
    }

    print('  ✅ "$name" passed');
  }
}
