import 'dart:io';

/// Utilities for running and detecting external processes.
class ProcessUtils {
  /// Checks whether [command] is available in PATH by running `<command> --version`.
  static Future<bool> isCommandAvailable(String command) async {
    try {
      final result = await Process.run(
        command,
        ['--version'],
        runInShell: true,
      );
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Detects the test command to use based on what is available in PATH.
  /// Priority: `fvm flutter test` > `flutter test` > `dart test`.
  static Future<String> detectTestCommand() async {
    if (await isCommandAvailable('fvm')) {
      return 'fvm flutter test';
    }
    if (await isCommandAvailable('flutter')) {
      return 'flutter test';
    }
    return 'dart test';
  }
}
