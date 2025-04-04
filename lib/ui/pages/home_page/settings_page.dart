import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fit_flutter/data/install_mode.dart';
import 'package:fit_flutter/services/settings_service.dart';
import 'package:fit_flutter/services/dd_manager.dart';
import 'package:fit_flutter/services/updater.dart';
import 'package:fit_flutter/ui/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settingsService = SettingsService.instance;
  TextEditingController downloadPathController = TextEditingController();
  TextEditingController installPathController = TextEditingController();
  String? downloadPath;
  String? installPath;
  InstallMode installMode = InstallMode.normal;
  int maxConcurrentDownloads = 2;
  String appVersion = '';
  String latestVersion = '';
  String releaseNotes = '';
  bool isUpdateAvailable = false;
  bool autoCheckForUpdates = true;
  Updater updater = Updater();
  int theme = 0;
  bool win11 = true;
  bool autoExtract = false;

  @override
  void initState() {
    super.initState();
    setWinVersion();
    loadAutoExtract();
    setDefaultInstallFolder();
    setInstallMode();
    setDefaultDownloadFolder();
    loadMaxConcurrentDownloads();
    loadAutoCheckForUpdates();
    getSetVersion();
  }

  Future<void> loadAutoExtract() async {
    autoExtract = await _settingsService.loadAutoExtract();
    setState(() {});
  }

  Future<void> setWinVersion() async {
    win11 = await isWin11();
    loadSelectedTheme();
  }

  Future<bool> isWin11() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    WindowsDeviceInfo windowsDeviceInfo = await deviceInfo.windowsInfo;
    return windowsDeviceInfo.productName.contains("Windows 11");
  }

  void loadSelectedTheme() {
    _settingsService.loadSelectedTheme().then((int value) {
      setState(() {
        theme = value;
      });
    });
  }

  void saveAutoExtract(bool autoExtract) {
    _settingsService.saveAutoExtract(autoExtract);
  }

  void setDefaultDownloadFolder() {
    _settingsService
        .loadDownloadPathSettings()
        .then((String? selectedDownloadPath) {
      if (selectedDownloadPath != null) {
        downloadPathController.text = selectedDownloadPath;
        downloadPath = selectedDownloadPath;
      }
    });
  }

  void saveDefaultDownloadFolder() {
    _settingsService.saveDownloadPathSettings(downloadPath!);
  }

  void setInstallMode() {
    _settingsService.loadInstallMode().then((InstallMode value) {
      setState(() {
        installMode = value;
      });
    });
  }

  void saveInstallMode(InstallMode value) {
    _settingsService.saveInstallMode(value);
  }

  void setDefaultInstallFolder() {
    _settingsService.loadInstallPath().then((String? selectedInstallPath) {
      if (selectedInstallPath != null) {
        installPathController.text = selectedInstallPath;
        installPath = selectedInstallPath;
      }
    });
  }

  void saveDefaultInstallFolder() {
    _settingsService.saveInstallPath(installPath!);
  }

  void loadMaxConcurrentDownloads() {
    _settingsService.loadMaxTasksSettings().then((int value) {
      setState(() {
        maxConcurrentDownloads = value;
      });
    });
  }

  void saveMaxConcurrentDownloads(int value) {
    _settingsService.saveMaxTasksSettings(value);
    DdManager.instance.setMaxConcurrentDownloads(value);
  }

  void loadAutoCheckForUpdates() {
    _settingsService.loadAutoCheckForUpdates().then((bool value) {
      setState(() {
        autoCheckForUpdates = value;
      });
    });
  }

  void saveAutoCheckForUpdates(bool value) {
    _settingsService.saveAutoCheckForUpdates(value);
  }

  Future<void> checkForUpdates() async {
    final latestReleaseInfo = await updater.getLatestReleaseInfo();
    latestVersion = latestReleaseInfo['tag_name']!.substring(1);
    releaseNotes = latestReleaseInfo['release_notes']!;
    isUpdateAvailable = await updater.isUpdateAvailable();
    setState(() {});
  }

  Future<void> getSetVersion() async {
    appVersion = await updater.getAppVersion();
    setState(() {});
  }

  Future<void> setThemeMode(BuildContext context, int value) async {
    _settingsService.saveSelectedTheme(value);
    await DynamicTheme.of(context)!.setTheme(value);
    switch (value) {
      case 2:
        Window.setEffect(effect: WindowEffect.acrylic);
        break;
      case 3:
        Window.setEffect(effect: WindowEffect.transparent);
        break;
      case 4:
        Window.setEffect(effect: WindowEffect.aero);
        break;
      case 5:
        Window.setEffect(effect: WindowEffect.mica);
        break;
      case 6:
        Window.setEffect(effect: WindowEffect.tabbed);
        break;
      default:
        Window.setEffect(effect: WindowEffect.solid);
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SettingsSection(
                title: AppLocalizations.of(context)!.chooseDefaultDownloadPath,
                content: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    TextField(
                      controller: downloadPathController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText:
                            AppLocalizations.of(context)!.defaultDownloadFolder,
                      ),
                      onChanged: (String directory) {
                        downloadPath = directory;
                      },
                    ),
                    Positioned(
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(Icons.folder),
                          onPressed: () async {
                            downloadPath =
                                await FilePicker.platform.getDirectoryPath();
                            if (downloadPath != null) {
                              downloadPath =
                                  downloadPath!.replaceAll('\\', '/');
                              if (!downloadPath!.endsWith('/')) {
                                downloadPath = '$downloadPath/';
                              }
                              downloadPathController.text = downloadPath!;
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
                title: AppLocalizations.of(context)!.autoExtractSettingsTitle,
                content: SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.autoExtract),
                  value: autoExtract,
                  onChanged: (bool value) {
                    setState(() {
                      autoExtract = value;
                    });
                    saveAutoExtract(value);
                  },
                ),
              ),
              if (autoExtract)
              SettingsSection(
                title: AppLocalizations.of(context)!.chooseDefaultInstallPath,
                content: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    TextField(
                      controller: installPathController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText:
                            AppLocalizations.of(context)!.defaultInstallFolder,
                      ),
                      onChanged: (String directory) {
                        installPath = directory;
                      },
                    ),
                    Positioned(
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(Icons.folder),
                          onPressed: () async {
                            installPath =
                                await FilePicker.platform.getDirectoryPath();
                            if (installPath != null) {
                              installPath = installPath!.replaceAll('\\', '/');
                              if (!installPath!.endsWith('/')) {
                                installPath = '$installPath/';
                              }
                              installPathController.text = installPath!;
                              saveDefaultInstallFolder();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (autoExtract)
              SettingsSection(
                  title: AppLocalizations.of(context)!.installModeSettingsTitle,
                  content: DropdownButtonFormField<InstallMode>(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText:
                            AppLocalizations.of(context)!.changeInstallMode,
                      ),
                      value: installMode,
                      items: [
                        DropdownMenuItem<InstallMode>(
                            value: InstallMode.normal,
                            child: Text(
                                AppLocalizations.of(context)!.normalInstall)),
                        DropdownMenuItem<InstallMode>(
                            value: InstallMode.silent,
                            child: Text(
                                AppLocalizations.of(context)!.silentInstall)),
                        DropdownMenuItem<InstallMode>(
                            value: InstallMode.verysilent,
                            child: Text(AppLocalizations.of(context)!
                                .verySilentInstall)),
                      ],
                      onChanged: (InstallMode? value) {
                        setState(() {
                          installMode = value!;
                        });
                        saveInstallMode(installMode);
                      })),
              SettingsSection(
                title: AppLocalizations.of(context)!.maxConcurrentDownloads,
                content: Column(
                  children: [
                    Slider(
                      value: maxConcurrentDownloads.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: maxConcurrentDownloads.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          maxConcurrentDownloads = value.toInt();
                        });
                      },
                      onChangeEnd: (double value) {
                        saveMaxConcurrentDownloads(value.toInt());
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
                  title: AppLocalizations.of(context)!.themeSettingsTitle,
                  content: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.changeTheme,
                      ),
                      value: DynamicTheme.of(context)!.themeId,
                      items: [
                        DropdownMenuItem<int>(
                            value: 0,
                            child:
                                Text(AppLocalizations.of(context)!.darkTheme)),
                        DropdownMenuItem<int>(
                            value: 1,
                            child:
                                Text(AppLocalizations.of(context)!.lightTheme)),
                        if (win11 && !Platform.isAndroid)
                          DropdownMenuItem<int>(
                              value: 2,
                              child: Text(
                                  AppLocalizations.of(context)!.acrylicTheme)),
                        if (!Platform.isAndroid)
                          DropdownMenuItem<int>(
                              value: 3,
                              child: Text(AppLocalizations.of(context)!
                                  .transparentTheme)),
                        if (!Platform.isAndroid)
                          DropdownMenuItem<int>(
                              value: 4,
                              child: Text(
                                  AppLocalizations.of(context)!.aeroTheme)),
                        if (win11 && !Platform.isAndroid)
                          DropdownMenuItem<int>(
                              value: 5,
                              child: Text(
                                  AppLocalizations.of(context)!.micaTheme)),
                        if (win11 && !Platform.isAndroid)
                          DropdownMenuItem<int>(
                              value: 6,
                              child: Text(
                                  AppLocalizations.of(context)!.tabbedTheme)),
                      ],
                      onChanged: (int? value) {
                        setThemeMode(context, value!);
                      })),
              SettingsSection(
                title: AppLocalizations.of(context)!.checkForUpdates,
                content: Column(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.currentVersion}: $appVersion',
                      style: const TextStyle(fontSize: 18),
                    ),
                    (latestVersion == '')
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  checkForUpdates();
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                ),
                                child: const Icon(Icons.update_outlined,
                                    size: 30.0),
                              ),
                            ),
                          )
                        : Text(
                            '${AppLocalizations.of(context)!.latestVersion}: $latestVersion',
                            style: const TextStyle(fontSize: 18),
                          ),
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)!
                          .autoCheckForUpdatesAtStart),
                      value: autoCheckForUpdates,
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
                            // color: Colors.black.withValues(alpha: 0.2),
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
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
                                      if (Platform.isWindows) {
                                        final filePath = await updater
                                            .downloadLatestRelease();
                                        await updater
                                            .runDownloadedSetup(filePath);
                                      } else {
                                        launchUrl(Uri.parse(
                                            "https://github.com/THR3ATB3AR/fit_flutter/releases/latest"));
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
