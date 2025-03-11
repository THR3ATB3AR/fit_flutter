import 'package:file_picker/file_picker.dart';
import 'package:fit_flutter/services/settings_service.dart';
import 'package:fit_flutter/services/dd_manager.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController directoryController = TextEditingController();
  String? selectedDirectory;
  double maxConcurrentDownloads = 2;

  @override
  void initState() {
    super.initState();
    setDefaultDownloadFolder();
    loadMaxConcurrentDownloads();
  }

  void setDefaultDownloadFolder() async {
    SettingsService().loadDownloadPathSettings().then((String? downloadPath) {
      if (downloadPath != null) {
        directoryController.text = downloadPath;
        selectedDirectory = downloadPath;
      }
    });
  }

  void saveDefaultDownloadFolder() {
    SettingsService().saveDownloadPathSettings(selectedDirectory!);
  }

  void loadMaxConcurrentDownloads() async {
    SettingsService().loadMaxTasksSettings().then((double value) {
      setState(() {
        maxConcurrentDownloads = value;
      });
    });
  }

  void saveMaxConcurrentDownloads(double value) {
    SettingsService().saveMaxTasksSettings(value);
    DdManager.instance.setMaxConcurrentDownloads(value.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.black.withOpacity(0.2),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose default download folder',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(children: [
                  TextField(
                    controller: directoryController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Default Download Folder',
                    ),
                    onChanged: (String directory) {
                      selectedDirectory = directory;
                    },
                  ),
                  Positioned(
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(Icons.folder),
                        onPressed: () async {
                          selectedDirectory =
                              await FilePicker.platform.getDirectoryPath();
                          if (selectedDirectory != null) {
                            selectedDirectory =
                                selectedDirectory!.replaceAll('\\', '/');
                            if (!selectedDirectory!.endsWith('/')) {
                              selectedDirectory = '$selectedDirectory/';
                            }
                            directoryController.text = selectedDirectory!;
                            saveDefaultDownloadFolder();
                          }
                        },
                      ),
                    ),
                  ),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Max Concurrent Downloads',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Slider(
                      value: maxConcurrentDownloads,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: maxConcurrentDownloads.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          maxConcurrentDownloads = value;
                        });
                      },
                      onChangeEnd: (double value) {
                        saveMaxConcurrentDownloads(value);
                      },
                    ),
                    Text(
                      'Current: ${maxConcurrentDownloads.round()}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
