import 'dart:io';

/// Utilities for interacting with the git repository
class GitUtils {
  /// Returns a list of currently staged, non-deleted file paths
  /// Returns empty list if no files are staged
  static Future<List<String>> getStagedFiles({String? workingDirectory}) async {
    final result = await Process.run(
        'git',
        [
          'diff',
          '--cached',
          '--name-only',
          '--diff-filter=ACMR',
        ],
        runInShell: true,
        workingDirectory: workingDirectory);

    if (result.exitCode != 0) return [];

    return result.stdout
        .toString()
        .trim()
        .split('\n')
        .where((f) => f.isNotEmpty)
        .toList();
  }
}
