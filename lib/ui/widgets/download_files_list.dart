import 'package:fit_flutter/data_classes/download_info.dart';
import 'package:fit_flutter/services/dd_manager.dart';
import 'package:fit_flutter/ui/widgets/dd_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

class DownloadFilesList extends StatefulWidget {
  const DownloadFilesList({
    super.key,
    required this.findls,
    required this.downloadManager,
    required this.title,
    required this.downloadFolder,
  });

  final List<DownloadInfo> findls;
  final DownloadManager downloadManager;
  final String title;
  final String? downloadFolder;

  @override
  State<DownloadFilesList> createState() => _DownloadFilesListState();
}

class _DownloadFilesListState extends State<DownloadFilesList> {
  final List<GlobalKey<DDTileState>> _tileKeys = [];
  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    for (var plugin in widget.findls) {
      _tileKeys.add(GlobalKey<DDTileState>());
    }
  }

  Future<void> startAllDownloads() async {
    setState(() {
      _isButtonDisabled = true;
    });
    for (var key in _tileKeys) {
      if (key.currentState != null) {
        await key.currentState!.startDownload();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Download Links'),
          IconButton(
            onPressed: _isButtonDisabled ? null : () async {
              await startAllDownloads();
            },
            icon: const Icon(Icons.download_for_offline),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: widget.findls.asMap().entries.map<Widget>((entry) {
            int index = entry.key;
            DownloadInfo plugin = entry.value;
            return DDTile(
              key: _tileKeys[index],
              downloadManager: widget.downloadManager,
              plugin: plugin,
              title: widget.title,
              downloadFolder: widget.downloadFolder,
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Ok'),
        ),
      ],
    );
  }
}