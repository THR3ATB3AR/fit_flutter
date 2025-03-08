import 'package:fit_flutter/data_classes/download_info.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

class DdManager {
  final DownloadManager downloadManager = DownloadManager();

  DdManager._privateConstructor();
  Map<String, List<Map<String, dynamic>>> downloadTasks = {};

  static final DdManager _instance = DdManager._privateConstructor();

  static DdManager get instance => _instance;

  String sanitizeFileName(String fileName) {
    final RegExp regExp = RegExp(r'[<>:"/\\|?*]');
    return fileName.replaceAll(regExp, '_');
  }

  Future<void> addDdLink(
      DownloadInfo ddInfo, String downloadFolder, String title) async {
    final sanitizedTitle = sanitizeFileName(title);
    final downloadPath = '$downloadFolder$sanitizedTitle/${ddInfo.fileName}';
    await downloadManager.addDownload(ddInfo.downloadLink, downloadPath);

    if (!downloadTasks.containsKey(sanitizedTitle)) {
      downloadTasks[sanitizedTitle] = [];
    }
    downloadTasks[sanitizedTitle]!.add({
      'fileName': ddInfo.fileName,
      'task': downloadManager.getDownload(ddInfo.downloadLink)!
    });
  }

  DownloadTask? getDownloadTask(DownloadInfo ddInfo) {
    return downloadManager.getDownload(ddInfo.downloadLink);
  }

  Future<void> cancelDownload(String url) async {
    await downloadManager.cancelDownload(url);
  }

  Future<void> pauseDownload(String url) async {
    await downloadManager.pauseDownload(url);
  }

  Future<void> resumeDownload(String url) async {
    await downloadManager.resumeDownload(url);
  }

  Map<String, List<Map<String, dynamic>>> getDownloadTasks() {
    return downloadTasks;
  }

  void removeDownloadTask(String url) {
    downloadTasks.forEach((title, tasks) {
      tasks.removeWhere((task) => task['task'].request.url == url);
    });
    downloadTasks.removeWhere((title, tasks) => tasks.isEmpty);
  }

  void printDownloadTasks() {
    downloadTasks.forEach((title, tasks) {
      print('Title: $title');
      for (var task in tasks) {
        print('  FileName: ${task['fileName']}, Task: ${task['task']}');
      }
    });
  }

}
