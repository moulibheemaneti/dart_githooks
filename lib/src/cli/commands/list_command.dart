import 'dart:io';

import 'package:path/path.dart' as path;

import '../../config/config_model.dart';
import '../../config/config_parser.dart';

class ListCommand {
  void run() {
    final config = ConfigParser.parse();

    if (config.hooks.isEmpty) {
      print('No hooks configured in dart_husky.yaml');
      return;
    }

    print('🪝 Configured hooks:\n');

    for (final entry in config.hooks.entries) {
      final hookType = entry.key;
      final hookConfig = entry.value;
      final isInstalled = _isInstalled(hookType);

      print(
        '  ${hookType.scriptName.padRight(20)} ${isInstalled ? '✅ installed' : '❌ not installed'} — ${hookConfig.commands.length} command(s)',
      );

      for (final cmd in hookConfig.commands.entries) {
        final desc = cmd.value.run ?? 'preset: ${cmd.value.preset}';
        print('    • ${cmd.key}: $desc');
      }
      print('');
    }
  }

  bool _isInstalled(HookType hookType) {
    final hookPath = path.join(
      Directory.current.path,
      '.git',
      'hooks',
      hookType.scriptName,
    );
    return File(hookPath).existsSync();
  }
}
