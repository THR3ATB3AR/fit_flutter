import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class Updater {
  Future<Map<String, String>> getLatestReleaseInfo() async {
    const url = 'https://api.github.com/repos/THR3ATB3AR/fit_flutter/releases/latest';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final tagName = jsonResponse['tag_name'];
      final releaseNotes = jsonResponse['body'];
      return {
        'tag_name': tagName,
        'release_notes': releaseNotes,
      };
    } else {
      throw Exception('Failed to fetch latest release version from GitHub');
    }
  }

  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<bool> isUpdateAvailable() async {
    final latestReleaseInfo = await getLatestReleaseInfo();
    final latestVersion = latestReleaseInfo['tag_name']!.substring(1);
    final appVersion = await getAppVersion();
    print("$latestVersion $appVersion");
    return latestVersion != appVersion;
  }

  Future<String> downloadLatestRelease() async {
    const url = 'https://api.github.com/repos/THR3ATB3AR/fit_flutter/releases/latest';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final asset = jsonResponse['assets'][0];
      final downloadUrl = asset['browser_download_url'];
      final fileName = asset['name'];

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}\\$fileName';

      final fileResponse = await http.get(Uri.parse(downloadUrl));
      final file = File(filePath);
      await file.writeAsBytes(fileResponse.bodyBytes);

      print('Downloaded latest release to $filePath');
      return filePath;
    } else {
      throw Exception('Failed to fetch latest release from GitHub');
    }
  }

  Future<void> runDownloadedSetup(String filePath) async {
    try {
      final result = await Process.run(filePath, ['/verysilent']);
      if (result.exitCode == 0) {
        print('Setup ran successfully.');
      } else {
        print('Setup failed with exit code ${result.exitCode}.');
      }
    } catch (e) {
      print('Failed to run setup: $e');
    }
  }
}