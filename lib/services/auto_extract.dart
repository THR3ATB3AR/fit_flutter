import 'dart:convert';
import 'dart:io';

import 'package:fit_flutter/data/install_mode.dart';
import 'package:fit_flutter/services/settings_service.dart';

class AutoExtract {
  AutoExtract._privateConstructor();

  static final AutoExtract _instance = AutoExtract._privateConstructor();
  static AutoExtract get instance => _instance;
  final SettingsService _settingsService = SettingsService.instance;
  InstallMode installMode = InstallMode.normal;
  String installPath = "";
  bool turnedOn = false;
  Future<void> extract(String downloadPath) async {
    
    installMode = await _settingsService.loadInstallMode();
    print(installMode);
    installPath = await _settingsService.loadInstallPath();
    turnedOn = await _settingsService.loadAutoExtract();
    final directory = Directory(downloadPath);
    final files = directory.listSync();

    final List<String> selectiveFiles = files
        .where((file) =>
            file is File &&
            (file.path
                .split(Platform.pathSeparator)
                .last
                .startsWith('fg-selective')))
        .map((file) => file.path)
        .toList();

    selectiveFiles.sort((a, b) => a.compareTo(b));

    final selectiveFile =
        selectiveFiles.isNotEmpty ? selectiveFiles.first : null;

    final List<String> optionalFiles = files
        .where((file) =>
            file is File &&
            (file.path
                .split(Platform.pathSeparator)
                .last
                .startsWith('fg-optional')))
        .map((file) => file.path)
        .toList();

    optionalFiles.sort((a, b) => a.compareTo(b));

    final optionalFile = optionalFiles.isNotEmpty ? optionalFiles.first : null;

    print('Optional files: $optionalFiles');

    final List<FileSystemEntity> validFiles = files
        .where((file) =>
            file is File &&
            !file.path
                .split(Platform.pathSeparator)
                .last
                .startsWith('fg-optional') &&
            !file.path
                .split(Platform.pathSeparator)
                .last
                .startsWith('fg-selective'))
        .toList();

// Posortuj pliki alfabetycznie według ich nazw
    validFiles.sort((a, b) => a.path.compareTo(b.path));

// Wybierz pierwszy plik z posortowanej listy
    final targetFile = validFiles.isNotEmpty
        ? validFiles.first
        : throw Exception('No valid file found');

    print('Found target file: ${targetFile.path}');

    await _executeCommand(targetFile.path, downloadPath);
    if (selectiveFiles.isNotEmpty) {
      await _executeCommand(selectiveFile!, downloadPath);
    }

    if (optionalFiles.isNotEmpty) {
      await _executeCommand(optionalFile!, downloadPath);
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

  Future<void> runInstaller(
      InstallMode mode, String workingDirectory, String outputPath) async {
    try {
      List<String> setupArgs = [];
      switch (mode) {
        case InstallMode.normal:
          setupArgs = ['/DIR="$outputPath"'];
          // Note: Even in normal mode, elevation might be requested.
          // The setup UI will appear *after* the UAC prompt is approved.
          break;
        case InstallMode.silent:
          setupArgs = ['/silent', '/DIR="$outputPath"'];
          break;
        case InstallMode.verysilent:
          setupArgs = ['/verysilent', '/DIR="$outputPath"'];
          break;
      }

      final setupExePath = '$workingDirectory/setup.exe';

      // Escape backslashes for the Dart string literal if necessary,
      // but PowerShell itself handles paths well, especially when quoted.
      // Use single quotes within the PowerShell command to handle paths with spaces.
      final psEscapedSetupExePath =
          setupExePath.replaceAll("'", "''"); // Escape single quotes for PS

      // Construct the argument list string for PowerShell's Start-Process
      // Each argument for setup.exe needs to be quoted (e.g., "'/silent'")
      final psArgsString =
          setupArgs.map((arg) => "'${arg.replaceAll("'", "''")}'").join(',');

      // Construct the full PowerShell command
      // -Wait: Makes PowerShell wait for setup.exe to finish.
      // -Verb RunAs: Triggers the UAC prompt for elevation.
      String psCommand = "Start-Process -FilePath '$psEscapedSetupExePath'";
      if (psArgsString.isNotEmpty) {
        psCommand += " -ArgumentList $psArgsString";
      }
      psCommand += " -Verb RunAs -Wait";

      print('Attempting to run with elevation via PowerShell:');
      print(
          'Executing: powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$psCommand"');

      final process = await Process.start(
        'powershell.exe',
        [
          '-NoProfile', // Speeds up startup, less interference
          '-ExecutionPolicy',
          'Bypass', // Ensures the command can run
          '-Command',
          psCommand, // The command we constructed
        ],
        // No need for runInShell: true, we are explicitly running powershell.exe
      );

      // Capture output/errors from PowerShell itself (useful for debugging)
      process.stdout.transform(utf8.decoder).listen((data) {
        // Use utf8.decoder
        print('PS Output: $data');
      });
      process.stderr.transform(utf8.decoder).listen((data) {
        // Use utf8.decoder
        print(
            'PS Error: $data'); // Check here for errors like "The requested operation requires elevation" if UAC is denied
      });

      final exitCode = await process.exitCode;
      print('PowerShell process exited with code: $exitCode');

      // IMPORTANT: The exit code here is from powershell.exe.
      // If UAC is approved and setup.exe runs, PowerShell (with -Wait) *should*
      // return setup.exe's exit code. However, if UAC is denied,
      // Start-Process might throw an error caught by stderr, and PowerShell might exit non-zero.
      // If UAC is cancelled, the exit code might be less predictable. Test thoroughly!
      if (exitCode == 0) {
        print(
            'Installer process likely completed (check specific setup logs if available).');
      } else {
        print(
            'Installer process may have failed or UAC was denied. Check PS Error output.');
      }
    } catch (e) {
      print('Failed to execute PowerShell command: $e');
    }
  }
}
