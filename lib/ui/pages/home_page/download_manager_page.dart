import 'package:fit_flutter/services/dd_manager.dart';
import 'package:fit_flutter/ui/pages/dd_page/download_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DownloadManagerPage extends StatefulWidget {
  const DownloadManagerPage({super.key});

  @override
  State<DownloadManagerPage> createState() => _DownloadManagerPageState();
}

class _DownloadManagerPageState extends State<DownloadManagerPage> {
  Map<String, List<Map<String, dynamic>>> downloadTasks = {};
  DdManager ddManager = DdManager.instance;

  @override
  void initState() {
    super.initState();
    downloadTasks = ddManager.getDownloadTasks();
  }

  void updateDownloadTasks() {
    setState(() {
      downloadTasks = ddManager.getDownloadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.black.withOpacity(0.2),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              AppLocalizations.of(context)!.downloadManager,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: downloadTasks.entries.expand((entry) {
                  String title = entry.key;
                  List<Map<String, dynamic>> tasks = entry.value;
                  return [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...tasks.map((task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: DownloadTile(
                          key: ValueKey(task['fileName']), // Dodanie klucza
                          fileName: task['fileName'],
                          task: task['task'],
                          updateDownloadTasks: updateDownloadTasks,
                        ),
                      );
                    }).toList(),
                  ];
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
