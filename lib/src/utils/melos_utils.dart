import 'dart:convert';
import 'dart:io';

/// A package discovered in a melos workspace via `melos list --json --relative`.
class MelosPackage {
  /// The package name (from pubspec.yaml, used for `melos exec --scope=<name>`).
  final String name;

  /// Relative path to the package from the workspace root (e.g. `packages/auth`).
  final String location;

  const MelosPackage({required this.name, required this.location});
}

/// Utilities for interacting with a melos workspace.
class MelosUtils {
  /// Lists all packages in the melos workspace by running `melos list --json --relative`.
  /// Returns an empty list if melos is not available or not in a workspace.
  static Future<List<MelosPackage>> listPackages() async {
    final result = await Process.run(
      'melos',
      ['list', '--json', '--relative'],
      runInShell: true,
    );

    if (result.exitCode != 0) return [];

    final json = jsonDecode(result.stdout.toString()) as List;

    return json
        .map((pkg) => MelosPackage(
              name: pkg['name'] as String,
              location: pkg['location'] as String,
            ))
        .toList();
  }

  /// Given workspace packages and staged file paths, returns the names of
  /// packages that have at least one staged file.
  ///
  /// Staged files are matched to packages via prefix: a file at
  /// `packages/auth/lib/x.dart` matches a package at location `packages/auth`.
  /// This is a pure function — no filesystem or process calls.
  static List<String> getAffectedPackageNames(
    List<MelosPackage> packages,
    List<String> stagedFiles,
  ) {
    final affected = <String>{};

    for (final file in stagedFiles) {
      for (final pkg in packages) {
        if (file.startsWith('${pkg.location}/')) {
          affected.add(pkg.name);
          break;
        }
      }
    }

    return affected.toList()..sort();
  }
}
