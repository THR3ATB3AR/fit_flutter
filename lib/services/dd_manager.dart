import 'dart:io';

import 'package:fit_flutter/data/download_info.dart';
import 'package:fit_flutter/services/auto_extract.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

class DdManager {
  final DownloadManager downloadManager = DownloadManager();
  final AutoExtract autoExtract = AutoExtract.instance;

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
    if (autoExtract.turnedOn && !Platform.isAndroid){
      printSanitizedTitleWhenCompleted(
        sanitizedTitle, '$downloadFolder$sanitizedTitle');
    }
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

  void printSanitizedTitleWhenCompleted(
      String sanitizedTitle, String downloadPath) {
    if (!downloadTasks.containsKey(sanitizedTitle)) return;

    final tasks = downloadTasks[sanitizedTitle]!;

    // Podziel zadania na opcjonalne i pozostałe
    final optionalTasks = tasks.where((task) {
      final fileName = task['fileName'] as String;
      return fileName.startsWith('fg-selective') ||
          fileName.startsWith('fg-optional');
    }).toList();

    final mainTasks = tasks.where((task) {
      final fileName = task['fileName'] as String;
      return !fileName.startsWith('fg-selective') &&
          !fileName.startsWith('fg-optional');
    }).toList();

    // Sprawdź, czy wszystkie główne zadania są ukończone
    bool allMainTasksCompleted = mainTasks.every((task) =>
        (task['task'] as DownloadTask).status.value ==
        DownloadStatus.completed);

    // Sprawdź, czy wszystkie opcjonalne zadania są ukończone
    bool allOptionalTasksCompleted = optionalTasks.every((task) =>
        (task['task'] as DownloadTask).status.value ==
        DownloadStatus.completed);

    if (allMainTasksCompleted) {
      print('All main tasks for "$sanitizedTitle" are completed.');

      mainTasks.forEach((task) {
        tasks.remove(task);
      });
    }

    if (allOptionalTasksCompleted) {
      print('All optional tasks for "$sanitizedTitle" are completed.');

      optionalTasks.forEach((task) {
        tasks.remove(task);
      });
    }

    // Sprawdź, czy wszystkie zadania są ukończone
    if (tasks.isEmpty) {
      print('All tasks for "$sanitizedTitle" are completed.');
      autoExtract.extract(downloadPath);
      downloadTasks.remove(sanitizedTitle);
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        printSanitizedTitleWhenCompleted(sanitizedTitle, downloadPath);
      });
    }
  }
}
