import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'config_model.dart';

class ConfigParser {
  static const _configFileName = 'dart_husky.yaml';
  static const _globalConfigKey = 'dart_husky';
  static const _validPresets = {'melos'};

  /// Parses raw YAML content as a string — useful for tests
  static GitHooksConfig parseString(String content) {
    final yaml = loadYaml(content) as YamlMap;
    return _parseConfig(yaml);
  }

  /// Finds and parses dart_husky.yaml from the project root
  static GitHooksConfig parse() {
    final configFile = _findConfigFile();
    final content = configFile.readAsStringSync();
    final yaml = loadYaml(content) as YamlMap;
    return _parseConfig(yaml);
  }

  static File _findConfigFile() {
    final configPath = path.join(Directory.current.path, _configFileName);
    final file = File(configPath);

    if (!file.existsSync()) {
      throw FileSystemException(
        'dart_husky.yaml not found. Create one in your project root.',
        configPath,
      );
    }

    return file;
  }

  static GitHooksConfig _parseConfig(YamlMap yaml) {
    final hooks = <HookType, HookConfig>{};
    DartHuskyConfig globalConfig = const DartHuskyConfig();

    for (final entry in yaml.entries) {
      final key = entry.key as String;

      // handle global dart_husky: block
      if (key == _globalConfigKey) {
        globalConfig = _parseGlobalConfig(entry.value as YamlMap);
        continue;
      }

      final hookType = HookType.fromString(key);

      if (hookType == null) {
        print('⚠️  Unknown hook "$key" — skipping.');
        continue;
      }

      hooks[hookType] = _parseHookConfig(entry.value as YamlMap, hookType);
    }

    return GitHooksConfig(globalConfig: globalConfig, hooks: hooks);
  }

  static DartHuskyConfig _parseGlobalConfig(YamlMap yaml) {
    return DartHuskyConfig(
      verbose: yaml['verbose'] as bool? ?? true,
      stagedOnly: yaml['staged_only'] as bool? ?? false,
    );
  }

  static HookConfig _parseHookConfig(YamlMap yaml, HookType hookType) {
    final parallel = yaml['parallel'] as bool? ?? false;
    final commandsYaml = yaml['commands'] as YamlMap? ?? YamlMap();
    final commands = <String, CommandConfig>{};
    final msgCommands = <String, CommitMsgCommandConfig>{};

    for (final entry in commandsYaml.entries) {
      final name = entry.key as String;
      final value = entry.value as YamlMap;

      if (hookType == HookType.commitMsg) {
        msgCommands[name] = _parseCommitMsgCommandConfig(value);
      } else {
        commands[name] = _parseCommandConfig(value);
      }
    }

    return HookConfig(
      parallel: parallel,
      commands: commands,
      msgCommands: msgCommands,
    );
  }

  static CommandConfig _parseCommandConfig(YamlMap yaml) {
    final run = yaml['run'] as String?;
    final preset = yaml['preset'] as String?;

    if (preset != null && run != null) {
      throw FormatException(
        'Command cannot have both "preset" and "run".',
      );
    }

    if (preset == null && run == null) {
      throw FormatException(
        'Command must have either "run" or "preset" field.',
      );
    }

    if (preset != null && !_validPresets.contains(preset)) {
      throw FormatException(
        'Unknown preset "$preset". Available presets: ${_validPresets.join(', ')}.',
      );
    }

    return CommandConfig(
      run: run,
      preset: preset,
      glob: yaml['glob'] as String?,
      stagedOnly: yaml['staged_only'] as bool?,
    );
  }

  static CommitMsgCommandConfig _parseCommitMsgCommandConfig(YamlMap yaml) {
    final preset = yaml['preset'] as String?;

    if (preset == null) {
      throw FormatException('commit-msg command must have a "preset" field.');
    }

    final typesYaml = yaml['types'] as YamlMap?;
    final appendTypes = _parseTypesList(typesYaml, 'append');
    final overrideTypes = _parseTypesList(typesYaml, 'override');

    if (appendTypes.isNotEmpty && overrideTypes.isNotEmpty) {
      throw FormatException(
        'commit-msg types cannot have both "append" and "override" at the same time.',
      );
    }

    return CommitMsgCommandConfig(
      preset: preset,
      appendTypes: appendTypes,
      overrideTypes: overrideTypes,
      onlySmallCase: yaml['only_small_case'] as bool? ?? true,
    );
  }

  static List<String> _parseTypesList(YamlMap? typesYaml, String key) {
    if (typesYaml == null) return const [];
    final list = typesYaml[key] as YamlList?;
    return list?.map((e) => e as String).toList() ?? const [];
  }
}
