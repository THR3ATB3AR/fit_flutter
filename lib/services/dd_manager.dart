import 'package:fit_flutter/data/download_info.dart';
import 'package:fit_flutter/services/auto_extract.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

class DdManager {
  final DownloadManager downloadManager = DownloadManager();
  final AutoExtract autoExtract = AutoExtract();

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

    printSanitizedTitleWhenCompleted(sanitizedTitle,'$downloadFolder$sanitizedTitle');
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

  void setMaxConcurrentDownloads(int maxDownloads) {
    downloadManager.maxConcurrentTasks = maxDownloads;
  }

  void printSanitizedTitleWhenCompleted(String sanitizedTitle, String downloadPath) {
    if (!downloadTasks.containsKey(sanitizedTitle)) return;

    final tasks = downloadTasks[sanitizedTitle]!;
    bool allCompleted = tasks.every((task) =>
        (task['task'] as DownloadTask).status.value == DownloadStatus.completed);

    if (allCompleted) {
      print('All tasks for "$sanitizedTitle" are completed.');
      autoExtract.extract(downloadPath);
      downloadTasks.remove(sanitizedTitle);
    } else {
      // Monitor tasks periodically
      Future.delayed(const Duration(seconds: 1), () {
        printSanitizedTitleWhenCompleted(sanitizedTitle, downloadPath);
      });
    }
  }
}
