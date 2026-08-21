import 'dart:io';

import 'package:dart_husky/src/utils/git_utils.dart';
import 'package:test/test.dart';

void main() {
  group('GitUtils.getStagedFiles', () {
    late Directory repository;

    setUp(() async {
      repository = await Directory.systemTemp.createTemp('dart_husky_git_');
      await _runGit(repository.path, ['init']);
      await _runGit(
          repository.path, ['config', 'user.email', 'test@example.com']);
      await _runGit(repository.path, ['config', 'user.name', 'Test User']);
    });

    tearDown(() async {
      await repository.delete(recursive: true);
    });

    test('excludes staged files that were deleted', () async {
      final retainedFile = File('${repository.path}/retained.dart');
      final deletedFile = File('${repository.path}/deleted.dart');

      await retainedFile.writeAsString('void retained() {}\n');
      await deletedFile.writeAsString('void deleted() {}\n');
      await _runGit(repository.path, ['add', '.']);
      await _runGit(repository.path, ['commit', '-m', 'initial']);

      await retainedFile
          .writeAsString('void retained() => print("retained");\n');
      await deletedFile.delete();
      await _runGit(repository.path, ['add', '--all']);

      expect(
        await GitUtils.getStagedFiles(workingDirectory: repository.path),
        ['retained.dart'],
      );
    });
  });
}

Future<void> _runGit(String workingDirectory, List<String> arguments) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: workingDirectory,
  );

  if (result.exitCode != 0) {
    throw ProcessException(
      'git',
      arguments,
      result.stderr.toString(),
      result.exitCode,
    );
  }
}
