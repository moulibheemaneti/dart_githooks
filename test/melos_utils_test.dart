import 'package:dart_husky/src/utils/melos_utils.dart';
import 'package:test/test.dart';

void main() {
  group('MelosUtils.getAffectedPackageNames', () {
    test('returns package name when staged file is in package', () {
      final packages = [
        MelosPackage(name: 'app', location: 'app'),
        MelosPackage(name: 'core', location: 'packages/core'),
      ];
      final result = MelosUtils.getAffectedPackageNames(
        packages,
        ['app/lib/main.dart'],
      );
      expect(result, equals(['app']));
    });

    test('returns multiple unique package names sorted', () {
      final packages = [
        MelosPackage(name: 'app', location: 'app'),
        MelosPackage(name: 'core', location: 'packages/core'),
        MelosPackage(name: 'ui', location: 'packages/ui'),
      ];
      final result = MelosUtils.getAffectedPackageNames(
        packages,
        [
          'packages/ui/src/widget.dart',
          'app/lib/main.dart',
          'packages/core/src/core.dart',
        ],
      );
      expect(result, equals(['app', 'core', 'ui']));
    });

    test('returns empty when no staged files match any package', () {
      final packages = [
        MelosPackage(name: 'app', location: 'app'),
      ];
      final result = MelosUtils.getAffectedPackageNames(
        packages,
        ['README.md', 'melos.yaml', 'pubspec.yaml'],
      );
      expect(result, isEmpty);
    });

    test('returns empty for empty staged files', () {
      final packages = [
        MelosPackage(name: 'app', location: 'app'),
      ];
      final result = MelosUtils.getAffectedPackageNames(packages, []);
      expect(result, isEmpty);
    });

    test('does not match partial path prefix', () {
      final packages = [
        MelosPackage(name: 'app', location: 'app'),
      ];
      final result = MelosUtils.getAffectedPackageNames(
        packages,
        ['application/lib/main.dart'],
      );
      expect(result, isEmpty);
    });

    test('deduplicates when multiple files in same package', () {
      final packages = [
        MelosPackage(name: 'core', location: 'packages/core'),
      ];
      final result = MelosUtils.getAffectedPackageNames(
        packages,
        [
          'packages/core/src/a.dart',
          'packages/core/src/b.dart',
          'packages/core/test/c_test.dart',
        ],
      );
      expect(result, equals(['core']));
    });

    test('handles nested package locations', () {
      final packages = [
        MelosPackage(name: 'auth', location: 'packages/features/auth'),
        MelosPackage(name: 'core', location: 'packages/core'),
      ];
      final result = MelosUtils.getAffectedPackageNames(
        packages,
        ['packages/features/auth/src/auth.dart'],
      );
      expect(result, equals(['auth']));
    });

    test('handles empty packages list', () {
      final result = MelosUtils.getAffectedPackageNames(
        [],
        ['app/lib/main.dart'],
      );
      expect(result, isEmpty);
    });
  });

  group('MelosPackage', () {
    test('stores name and location', () {
      const pkg = MelosPackage(name: 'my_pkg', location: 'packages/my_pkg');
      expect(pkg.name, equals('my_pkg'));
      expect(pkg.location, equals('packages/my_pkg'));
    });
  });
}
