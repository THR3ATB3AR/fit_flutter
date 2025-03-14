import 'package:fit_flutter/services/dd_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DownloadTile extends StatefulWidget {
  const DownloadTile(
      {super.key,
      required this.fileName,
      required this.task,
      required this.updateDownloadTasks});
  final String fileName;
  final DownloadTask task;
  final Function updateDownloadTasks;

  @override
  State<DownloadTile> createState() => _DownloadTileState();
}

class _DownloadTileState extends State<DownloadTile> {
  late double _progress;
  late DownloadStatus _status;
  DdManager ddManager = DdManager.instance;

  void pauseDownload() {
    ddManager.pauseDownload(widget.task.request.url);
    setState(() {});
  }

  void resumeDownload() {
    ddManager.resumeDownload(widget.task.request.url);
    setState(() {});
  }

  void cancelDownload() {
    ddManager.cancelDownload(widget.task.request.url);
    setState(() {
      ddManager.removeDownloadTask(widget.task.request.url);
      widget.updateDownloadTasks();
    });
  }

  @override
  void dispose() {
    widget.task.progress.removeListener(_updateProgress);
    widget.task.status.removeListener(_updateStatus);
    super.dispose();
  }

  void _updateProgress() {
    setState(() {
      _progress = widget.task.progress.value;
    });
  }

  void _updateStatus() {
    setState(() {
      _status = widget.task.status.value;
    });
  }

  String _getStatusText(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloading:
        return AppLocalizations.of(context)!.downloading;
      case DownloadStatus.paused:
        return AppLocalizations.of(context)!.paused;
      case DownloadStatus.completed:
        return AppLocalizations.of(context)!.complete;
      case DownloadStatus.failed:
        return AppLocalizations.of(context)!.failed;
      case DownloadStatus.canceled:
        return AppLocalizations.of(context)!.canceled;
      case DownloadStatus.queued:
        return AppLocalizations.of(context)!.queued;
    }
  }

  @override
  void initState() {
    super.initState();
    _progress = widget.task.progress.value;
    _status = widget.task.status.value;

    widget.task.progress.addListener(_updateProgress);
    widget.task.status.addListener(_updateStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.black.withValues(alpha: 0.2),
      ),
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fileName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '${AppLocalizations.of(context)!.status}: ${_getStatusText(_status)}',
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${(_progress * 100).toStringAsFixed(0)}%',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _status == DownloadStatus.paused
                          ? resumeDownload
                          : pauseDownload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15), // Increase the size
                      ),
                      child: Icon(
                        _status == DownloadStatus.paused
                            ? Icons.play_arrow
                            : Icons.pause,
                        size: 25, // Increase the icon size
                      ),
                    ),
                    ElevatedButton(
                      onPressed: cancelDownload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15), // Increase the size
                      ),
                      child: const Icon(
                        Icons.cancel,
                        size: 25, // Increase the icon size
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10), // Add some spacing
          LinearProgressIndicator(
            value: _progress,
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary),
            backgroundColor: Colors.transparent,
            minHeight: 10,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
