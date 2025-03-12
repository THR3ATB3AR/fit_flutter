import 'package:file_picker/file_picker.dart';
import 'package:fit_flutter/services/settings_service.dart';
import 'package:fit_flutter/services/dd_manager.dart';
import 'package:fit_flutter/services/updater.dart';
import 'package:fit_flutter/ui/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController directoryController = TextEditingController();
  String? selectedDirectory;
  double maxConcurrentDownloads = 2;
  String appVersion = '';
  String latestVersion = '';
  String releaseNotes = '';
  bool isUpdateAvailable = false;
  Updater updater = Updater();

  @override
  void initState() {
    super.initState();
    setDefaultDownloadFolder();
    loadMaxConcurrentDownloads();
    checkForUpdates();
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

  Future<void> checkForUpdates() async {
    final latestReleaseInfo = await updater.getLatestReleaseInfo();
    appVersion = await updater.getAppVersion();
    latestVersion = latestReleaseInfo['tag_name']!.substring(1);
    releaseNotes = latestReleaseInfo['release_notes']!;
    isUpdateAvailable = await updater.isUpdateAvailable();
    setState(() {});
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
              SettingsSection(
                title: 'Choose default download folder',
                content: Stack(
                  children: [
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
                  ],
                ),
              ),
              SettingsSection(
                title: 'Max Concurrent Downloads',
                content: Column(
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
              SettingsSection(
                title: 'Check for Updates',
                content: Column(
                  children: [
                    Text(
                      'Current version: $appVersion',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Latest version: $latestVersion',
                      style: const TextStyle(fontSize: 18),
                    ),
                    if (isUpdateAvailable)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'A new version of the app is available. Would you like to update now?',
                              ),
                              const SizedBox(height: 8),
                              MarkdownBody(
                                  data: '''
$releaseNotes
                                  ''',
                                  styleSheet: MarkdownStyleSheet(
                                    textAlign: WrapAlignment.center,
                                    h1Align: WrapAlignment.center,
                                    h2Align: WrapAlignment.center,
                                    h3Align: WrapAlignment.center,
                                    h4Align: WrapAlignment.center,
                                    h5Align: WrapAlignment.center,
                                    h6Align: WrapAlignment.center,
                                    unorderedListAlign: WrapAlignment.center,
                                    orderedListAlign: WrapAlignment.center,
                                    blockquoteAlign: WrapAlignment.center,
                                    codeblockAlign: WrapAlignment.center,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                    onPressed: () async {
                                      setState(() {
                                        isUpdateAvailable = false;
                                      });
                                      final filePath = await updater.downloadLatestRelease();
                                      await updater.runDownloadedSetup(filePath);
                                    },
                                    child: const Text('Update'),
                                  ),
                                  
                                ],
                              ),
                            ],
                          ),
                        ),
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
