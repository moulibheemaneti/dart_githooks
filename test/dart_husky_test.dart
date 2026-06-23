import 'package:dart_husky/src/config/config_model.dart';
import 'package:dart_husky/src/config/config_parser.dart';
import 'package:dart_husky/src/hooks/commit_msg_validator.dart';
import 'package:test/test.dart';

void main() {
  group('CommitMsgValidator', () {
    group('valid messages — built-in types', () {
      test('simple type and subject', () {
        final result = CommitMsgValidator.validate('feat: add login screen');
        expect(result.passed, isTrue);
      });

      test('type with scope', () {
        final result = CommitMsgValidator.validate(
          'fix(auth): resolve null pointer',
        );
        expect(result.passed, isTrue);
      });

      test('breaking change', () {
        final result = CommitMsgValidator.validate(
          'feat!: breaking api change',
        );
        expect(result.passed, isTrue);
      });

      test('breaking change with scope', () {
        final result = CommitMsgValidator.validate(
          'feat(api)!: breaking api change',
        );
        expect(result.passed, isTrue);
      });

      test('all valid built-in types', () {
        final validTypes = [
          'feat',
          'fix',
          'chore',
          'docs',
          'style',
          'refactor',
          'test',
          'build',
          'ci',
          'perf',
          'revert',
        ];
        for (final type in validTypes) {
          final result = CommitMsgValidator.validate('$type: some subject');
          expect(result.passed, isTrue, reason: '$type should be valid');
        }
      });
    });

    group('invalid messages', () {
      test('empty message', () {
        final result = CommitMsgValidator.validate('');
        expect(result.passed, isFalse);
      });

      test('missing colon', () {
        final result = CommitMsgValidator.validate('feat add login screen');
        expect(result.passed, isFalse);
      });

      test('invalid type', () {
        final result = CommitMsgValidator.validate('update: something');
        expect(result.passed, isFalse);
      });

      test('missing subject', () {
        final result = CommitMsgValidator.validate('feat: ');
        expect(result.passed, isFalse);
      });

      test('no space after colon', () {
        final result = CommitMsgValidator.validate('feat:add login screen');
        expect(result.passed, isFalse);
      });
    });

    group('append types', () {
      test('appended type wip is valid', () {
        final result = CommitMsgValidator.validate(
          'wip: work in progress',
          appendTypes: ['wip', 'release'],
        );
        expect(result.passed, isTrue);
      });

      test('appended type release is valid', () {
        final result = CommitMsgValidator.validate(
          'release: v1.0.0',
          appendTypes: ['wip', 'release'],
        );
        expect(result.passed, isTrue);
      });

      test('built-in types still valid when appending', () {
        final result = CommitMsgValidator.validate(
          'feat: still works',
          appendTypes: ['wip', 'release'],
        );
        expect(result.passed, isTrue);
      });

      test('non-appended custom type is invalid', () {
        final result = CommitMsgValidator.validate(
          'hotfix: critical bug',
          appendTypes: ['wip', 'release'],
        );
        expect(result.passed, isFalse);
      });
    });

    group('override types', () {
      test('override type is valid', () {
        final result = CommitMsgValidator.validate(
          'release: v1.0.0',
          overrideTypes: ['release', 'hotfix'],
        );
        expect(result.passed, isTrue);
      });

      test('built-in types invalid when overridden', () {
        final result = CommitMsgValidator.validate(
          'feat: something',
          overrideTypes: ['release', 'hotfix'],
        );
        expect(result.passed, isFalse);
      });

      test('only override types are valid', () {
        final result = CommitMsgValidator.validate(
          'hotfix: critical bug',
          overrideTypes: ['release', 'hotfix'],
        );
        expect(result.passed, isTrue);
      });
    });
  });

  group('HookType', () {
    test('fromString returns correct type', () {
      expect(HookType.fromString('pre-commit'), equals(HookType.preCommit));
      expect(HookType.fromString('commit-msg'), equals(HookType.commitMsg));
      expect(HookType.fromString('pre-push'), equals(HookType.prePush));
    });

    test('fromString returns null for unknown hook', () {
      expect(HookType.fromString('unknown-hook'), isNull);
    });

    test('scriptName matches git hook filename', () {
      expect(HookType.preCommit.scriptName, equals('pre-commit'));
      expect(HookType.commitMsg.scriptName, equals('commit-msg'));
      expect(HookType.prePush.scriptName, equals('pre-push'));
    });
  });

  group('DartHuskyConfig', () {
    test('verbose defaults to true', () {
      const config = DartHuskyConfig();
      expect(config.verbose, isTrue);
    });

    test('verbose can be set to false', () {
      const config = DartHuskyConfig(verbose: false);
      expect(config.verbose, isFalse);
    });

    test('stagedOnly defaults to false', () {
      const config = DartHuskyConfig();
      expect(config.stagedOnly, isFalse);
    });

    test('stagedOnly can be set to true', () {
      const config = DartHuskyConfig(stagedOnly: true);
      expect(config.stagedOnly, isTrue);
    });
  });

  group('CommandConfig', () {
    test('stagedOnly defaults to null — inherits global', () {
      const config = CommandConfig(run: 'dart format .');
      expect(config.stagedOnly, isNull);
    });

    test('stagedOnly can be explicitly set to false', () {
      const config = CommandConfig(run: 'dart test', stagedOnly: false);
      expect(config.stagedOnly, isFalse);
    });

    test('stagedOnly can be explicitly set to true', () {
      const config = CommandConfig(run: 'dart format .', stagedOnly: true);
      expect(config.stagedOnly, isTrue);
    });
  });

  group('CommitMsgCommandConfig', () {
    test('appendTypes defaults to empty', () {
      const config = CommitMsgCommandConfig(preset: 'conventional');
      expect(config.appendTypes, isEmpty);
    });

    test('overrideTypes defaults to empty', () {
      const config = CommitMsgCommandConfig(preset: 'conventional');
      expect(config.overrideTypes, isEmpty);
    });

    test('appendTypes are stored correctly', () {
      const config = CommitMsgCommandConfig(
        preset: 'conventional',
        appendTypes: ['wip', 'release'],
      );
      expect(config.appendTypes, equals(['wip', 'release']));
    });
  });

  group('CommandConfig — preset', () {
    test('preset defaults to null', () {
      const config = CommandConfig(run: 'dart test');
      expect(config.preset, isNull);
    });

    test('preset can be set', () {
      const config = CommandConfig(preset: 'melos');
      expect(config.preset, equals('melos'));
    });

    test('run can be null when preset is set', () {
      const config = CommandConfig(preset: 'melos');
      expect(config.run, isNull);
    });
  });

  group('ConfigParser — preset validation', () {
    test('preset without run parses successfully', () {
      final config = ConfigParser.parseString('''
pre-commit:
  commands:
    test:
      preset: melos
''');
      final cmd = config.hooks[HookType.preCommit]!.commands['test']!;
      expect(cmd.preset, equals('melos'));
      expect(cmd.run, isNull);
    });

    test('preset with staged_only parses successfully', () {
      final config = ConfigParser.parseString('''
pre-commit:
  commands:
    test:
      preset: melos
      staged_only: true
''');
      final cmd = config.hooks[HookType.preCommit]!.commands['test']!;
      expect(cmd.preset, equals('melos'));
      expect(cmd.stagedOnly, isTrue);
    });

    test('run without preset parses successfully', () {
      final config = ConfigParser.parseString('''
pre-commit:
  commands:
    test:
      run: dart test
''');
      final cmd = config.hooks[HookType.preCommit]!.commands['test']!;
      expect(cmd.run, equals('dart test'));
      expect(cmd.preset, isNull);
    });

    test('both preset and run throws FormatException', () {
      expect(
        () => ConfigParser.parseString('''
pre-commit:
  commands:
    test:
      run: dart test
      preset: melos
'''),
        throwsA(isA<FormatException>()),
      );
    });

    test('unknown preset throws FormatException', () {
      expect(
        () => ConfigParser.parseString('''
pre-commit:
  commands:
    test:
      preset: melos_
'''),
        throwsA(isA<FormatException>()),
      );
    });

    test('neither preset nor run throws FormatException', () {
      expect(
        () => ConfigParser.parseString('''
pre-commit:
  commands:
    test:
      glob: '**/*.dart'
'''),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('only_small_case', () {
    test('lowercase message passes', () {
      final result = CommitMsgValidator.validate(
        'feat: add login screen',
        onlySmallCase: true,
      );
      expect(result.passed, isTrue);
    });

    test('uppercase message fails when onlySmallCase is true', () {
      final result = CommitMsgValidator.validate(
        'feat: Add Login Screen',
        onlySmallCase: true,
      );
      expect(result.passed, isFalse);
    });

    test('uppercase message passes when onlySmallCase is false', () {
      final result = CommitMsgValidator.validate(
        'feat: Add Login Screen',
        onlySmallCase: false,
      );
      expect(result.passed, isTrue);
    });
  });
}
