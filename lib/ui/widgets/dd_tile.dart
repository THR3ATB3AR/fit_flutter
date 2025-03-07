import 'package:fit_flutter/data_classes/download_info.dart';
import 'package:fit_flutter/services/dd_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

class DDTile extends StatefulWidget {
  const DDTile({
    super.key,
    required this.downloadManager,
    required this.plugin,
    required this.title,
    required this.downloadFolder,
  });

  final DownloadManager downloadManager;
  final DownloadInfo plugin;
  final String title;
  final String? downloadFolder;

  @override
  State<DDTile> createState() => DDTileState();
}

class DDTileState extends State<DDTile> {
  double _progress = 0.0;
  bool _isDownloading = false;
  bool _isDownloaded = false;
  DdManager ddManager = DdManager.instance;

  String sanitizeFileName(String fileName) {
    final RegExp regExp = RegExp(r'[<>:"/\\|?*]');
    return fileName.replaceAll(regExp, '_');
  }

  Future<void> addLink(){
    return ddManager.addDdLink(widget.plugin, widget.downloadFolder!, widget.title);
  }

  DownloadTask? getDownloadTask(){
    return ddManager.getDownloadTask(widget.plugin);
  }

  Future<void> startDownload() async {
    setState(() {
      _isDownloading = true;
    });
    await addLink();
    DownloadTask? task = getDownloadTask();
    task?.progress.addListener(() {
      setState(() {
        _progress = task.progress.value;
      });
    });
    
    task?.status.addListener(() {
      if (task.status.value == DownloadStatus.completed) {
        setState(() {
          _isDownloading = false;
          _isDownloaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.plugin.fileName),
      trailing: _isDownloading
          ? Stack(
            children: [
              CircularProgressIndicator(value: _progress),
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () async {
                  await widget.downloadManager.cancelDownload(widget.plugin.downloadLink);
                  setState(() {
                    _isDownloading = false;
                  });
                },
              ),
            ],
          )
          : _isDownloaded
              ? const Icon(Icons.download_done)
              : IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () async {
                    await startDownload();
                  },
                ),
    );
  }
}