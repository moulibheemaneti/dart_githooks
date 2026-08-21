import 'dart:io';

/// Utilities for interacting with the git repository
class GitUtils {
  /// Returns a list of currently staged file paths
  /// Returns empty list if no files are staged
  static Future<List<String>> getStagedFiles() async {
    final result = await Process.run(
        'git',
        [
          'diff',
          '--cached',
          '--name-only',
        ],
        runInShell: true);

    if (result.exitCode != 0) return [];

    return result.stdout
        .toString()
        .trim()
        .split('\n')
        .where((f) => f.isNotEmpty)
        .toList();
  }
}
