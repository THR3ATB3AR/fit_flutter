import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsService {
  Future<void> checkAndCopySettings() async {
    final appDataDir = await getApplicationSupportDirectory();
    final settingsDir = Directory('${appDataDir.path}\\FitFlutter');
    final settingsFile = File('${settingsDir.path}\\settings.json');

    if (!await settingsDir.exists()) {
      await settingsDir.create(recursive: true);
    }

    if (!await settingsFile.exists()) {
      final defaultSettings = {
      'defaultDownloadFolder': '',
      'maxTasksNumber': 5,
      'autoCheckForUpdates': true,
      };
      await settingsFile.writeAsString(jsonEncode(defaultSettings));
    }
  }

  Future<String?> loadDownloadPathSettings() async {
    final appDataDir = await getApplicationSupportDirectory();
    final settingsFile = File('${appDataDir.path}\\FitFlutter\\settings.json');
    final settingsContent = await settingsFile.readAsString();
    final settings = jsonDecode(settingsContent);
    return settings['defaultDownloadFolder'];
  }

  Future<void> saveDownloadPathSettings(String downloadPath) async {
    final appDataDir = await getApplicationSupportDirectory();
    final settingsFile = File('${appDataDir.path}\\FitFlutter\\settings.json');
    final settingsContent = await settingsFile.readAsString();
    final settings = jsonDecode(settingsContent);
    settings['defaultDownloadFolder'] = downloadPath;
    await settingsFile.writeAsString(jsonEncode(settings));
  }

  Future<double> loadMaxTasksSettings() async {
    final appDataDir = await getApplicationSupportDirectory();
    final settingsFile = File('${appDataDir.path}\\FitFlutter\\settings.json');
    final settingsContent = await settingsFile.readAsString();
    final settings = jsonDecode(settingsContent);
    return settings['maxTasksNumber'];
  }

  Future<void> saveMaxTasksSettings(double maxTasks) async {
    final appDataDir = await getApplicationSupportDirectory();
    final settingsFile = File('${appDataDir.path}\\FitFlutter\\settings.json');
    final settingsContent = await settingsFile.readAsString();
    final settings = jsonDecode(settingsContent);
    settings['maxTasksNumber'] = maxTasks;
    await settingsFile.writeAsString(jsonEncode(settings));
  }

  Future<bool> loadAutoCheckForUpdates() async {
    final appDataDir = await getApplicationSupportDirectory();
    final settingsFile = File('${appDataDir.path}\\FitFlutter\\settings.json');
    final settingsContent = await settingsFile.readAsString();
    final settings = jsonDecode(settingsContent);
    return settings['autoCheckForUpdates'] ?? true;
  }

  Future<void> saveAutoCheckForUpdates(bool autoCheck) async {
    final appDataDir = await getApplicationSupportDirectory();
    final settingsFile = File('${appDataDir.path}\\FitFlutter\\settings.json');
    final settingsContent = await settingsFile.readAsString();
    final settings = jsonDecode(settingsContent);
    settings['autoCheckForUpdates'] = autoCheck;
    await settingsFile.writeAsString(jsonEncode(settings));
  }
}