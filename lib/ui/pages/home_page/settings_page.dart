import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fit_flutter/services/settings_service.dart';
import 'package:fit_flutter/services/dd_manager.dart';
import 'package:fit_flutter/services/updater.dart';
import 'package:fit_flutter/ui/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  bool autoCheckForUpdates = true;
  Updater updater = Updater();

  @override
  void initState() {
    super.initState();
    setDefaultDownloadFolder();
    loadMaxConcurrentDownloads();
    loadAutoCheckForUpdates();
    if (autoCheckForUpdates) {
      checkForUpdates();
    }
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

  void loadAutoCheckForUpdates() async {
    SettingsService().loadAutoCheckForUpdates().then((bool value) {
      setState(() {
        autoCheckForUpdates = value;
      });
    });
  }

  void saveAutoCheckForUpdates(bool value) {
    SettingsService().saveAutoCheckForUpdates(value);
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
        color: Colors.black.withValues(alpha: 0.2),
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
                title:
                    AppLocalizations.of(context)!.chooseDefaultDownloadFolder,
                content: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    TextField(
                      controller: directoryController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText:
                            AppLocalizations.of(context)!.defaultDownloadFolder,
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
                title: AppLocalizations.of(context)!.maxConcurrentDownloads,
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
                      '${AppLocalizations.of(context)!.current}: ${maxConcurrentDownloads.round()}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              SettingsSection(
                title: AppLocalizations.of(context)!.checkForUpdates,
                content: Column(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.currentVersion}: $appVersion',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.latestVersion}: $latestVersion',
                      style: const TextStyle(fontSize: 18),
                    ),
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)!
                          .autoCheckForUpdatesAtStart),
                      value: autoCheckForUpdates,
                      thumbColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return Theme.of(context)
                                .colorScheme
                                .primaryContainer;
                          }
                          return null;
                        },
                      ),
                      onChanged: (bool value) {
                        setState(() {
                          autoCheckForUpdates = value;
                        });
                        saveAutoCheckForUpdates(value);
                      },
                    ),
                    if (isUpdateAvailable)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .aNewVersionOfTheAppIsAvailableWouldYouLikeToUpdateNow,
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
                                onTapLink: (text, href, title) async {
                                  if (href != null) {
                                    final Uri uri = Uri.parse(href);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      throw 'Could not launch $href';
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    )),
                                    onPressed: () async {
                                      setState(() {
                                        isUpdateAvailable = false;
                                      });
                                      if (Platform.isWindows){
                                          final filePath = await updater
                                            .downloadLatestRelease();
                                        await updater
                                            .runDownloadedSetup(filePath);
                                        } else {
                                          launchUrl(Uri.parse("https://github.com/THR3ATB3AR/fit_flutter/releases/latest"));
                                        }
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.update),
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
