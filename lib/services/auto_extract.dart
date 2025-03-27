import 'dart:io';

import 'package:fit_flutter/data/install_mode.dart';

class AutoExtract {
  InstallMode installMode = InstallMode.normal;
  String installPath = "";
  Future<void> extract(String downloadPath) async {
    final directory = Directory(downloadPath);
    final files = directory.listSync();

    final List<String> optionalFiles = files
        .where((file) =>
            file is File &&
            (file.path
                    .split(Platform.pathSeparator)
                    .last
                    .startsWith('fg-optional') ||
                file.path
                    .split(Platform.pathSeparator)
                    .last
                    .startsWith('fg-selective')) &&
            RegExp(r'part(0*1)\.rar$').hasMatch(file.path))
        .map((file) => file.path)
        .toList();

    print('Optional files: $optionalFiles');

    final targetFile = files.firstWhere(
      (file) =>
          file is File &&
          !file.path
              .split(Platform.pathSeparator)
              .last
              .startsWith('fg-optional') &&
          !file.path
              .split(Platform.pathSeparator)
              .last
              .startsWith('fg-selective') &&
          RegExp(r'part(0*1)\.rar$').hasMatch(file.path),
      orElse: () => throw Exception('No valid file found'),
    );

    print('Found target file: ${targetFile.path}');

    await _executeCommand(targetFile.path, downloadPath);

    for (final optionalFile in optionalFiles) {
      await _executeCommand(optionalFile, downloadPath);
    }

    await runInstaller(installMode, downloadPath, installPath);
  }

  Future<void> _executeCommand(String filePath, String outputPath) async {
    try {
      final process =
          await Process.start('7z', ['x', filePath, '-o$outputPath']);

      // Listen to the standard output
      process.stdout.transform(const SystemEncoding().decoder).listen((data) {
        print('Output: $data');
      });

      // Listen to the standard error
      process.stderr.transform(const SystemEncoding().decoder).listen((data) {
        print('Error: $data');
      });

      // Wait for the process to complete
      final exitCode = await process.exitCode;
      print('Process for $filePath exited with code: $exitCode');
    } catch (e) {
      print('Failed to execute command for $filePath: $e');
    }
  }

  Future<void> runInstaller(InstallMode mode, String workingDirectory, String outputPath) async {
    try {
      List<String> arguments;
      switch (mode) {
        case InstallMode.normal:
          arguments = ['/DIR=$outputPath'];
          break;
        case InstallMode.silent:
          arguments = ['/silent', '/DIR=$outputPath'];
          break;
        case InstallMode.verysilent:
          arguments = ['/verysilent', '/DIR=$outputPath'];
          break;
      }

      final process = await Process.start(
        'setup.exe',
        arguments,
        workingDirectory: workingDirectory,
      );

      process.stdout.transform(const SystemEncoding().decoder).listen((data) {
        print('Output: $data');
      });

      process.stderr.transform(const SystemEncoding().decoder).listen((data) {
        print('Error: $data');
      });

      final exitCode = await process.exitCode;
      print('Process exited with code: $exitCode');
    } catch (e) {
      print('Failed to execute command: $e');
    }
  }
}
