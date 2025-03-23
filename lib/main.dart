import 'dart:io';
import 'package:fit_flutter/services/dd_manager.dart';
import 'package:fit_flutter/services/repack_service.dart';
import 'package:fit_flutter/services/settings_service.dart';
import 'package:fit_flutter/services/updater.dart';
import 'package:fit_flutter/ui/themes/dynamic_theme_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:fit_flutter/services/scraper_service.dart';
import 'package:fit_flutter/ui/pages/main_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentColor.load();
  if (Platform.isWindows) {
    await Window.initialize();
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final accentColor = SystemTheme.accentColor.accent;
  final RepackService _repackService = RepackService.instance;
  late Future<void> _initialization;
  String loadingMessage = '';
  final ScraperService _scraperService = ScraperService.instance;
  String? defaultDownloadPath;
  bool isUpdateAvailable = false;
  Updater updater = Updater();
  String appVersion = '';
  String latestVersion = '';
  String releaseNotes = '';
  int selectedTheme = 0;

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        print('Permission granted');
      } else {
        print('Permission denied');
      }
    }
  }

  Future<void> loadInitialData() async {
    await _checkSettings();

    setState(() {
      loadingMessage =
          AppLocalizations.of(context)?.initializing ?? 'Initializing...';
    });

    if (await SettingsService().loadAutoCheckForUpdates()) {
      await _checkForUpdates();
    }

    if (await _repackService.allFilesExist()) {
      setState(() {
        loadingMessage = AppLocalizations.of(context)?.initializing ??
            'Loading cached repacks';
      });

      await _repackService.loadAllData();
      
      // await _repackService.loadOldUpdatedRepackList();
      setState(() {});
    } else {
      _repackService.deleteFiles();
      _repackService.newRepacks =
          await _scraperService.scrapeNewRepacks(onProgress: (loaded, total) {
        setState(() {
          loadingMessage =
              '${AppLocalizations.of(context)?.loadingNewRepacks ?? 'Loading new repacks'}... ${((loaded / total) * 100).toStringAsFixed(0)}%';
        });
      });
      setState(() {});
      _repackService.popularRepacks = await _scraperService
          .scrapePopularRepacks(onProgress: (loaded, total) {
        setState(() {
          loadingMessage =
              '${AppLocalizations.of(context)?.loadingPopularRepacks ?? 'Loading popular repacks'}... ${((loaded / total) * 100).toStringAsFixed(0)}%';
        });
      });
      setState(() {});
      // _repackService.updatedRepacks = [];
      // _repackService.saveUpdatedRepackList();
      _repackService.allRepacksNames = await _scraperService
          .scrapeAllRepacksNames(onProgress: (loaded, total) {
        setState(() {
          loadingMessage =
              '${AppLocalizations.of(context)?.indexingAllRepacks ?? 'Indexing all repacks'}... ${((loaded / total) * 100).toStringAsFixed(0)}%';
        });
      });
      setState(() {});

      // _repackService.everyRepack = await _scraperService.scrapeEveryRepack(
      //   onProgress: (loaded, total) {
      //     setState(() {
      //       loadingMessage =
      //           'Loading every repack... $loaded/$total';
      //     });
      //   },
      // );
      _repackService.saveNewRepackList();
      _repackService.savePopularRepackList();
      _repackService.saveAllRepackList();
      _repackService.saveEveryRepackList();
    }
    _scraperService.scrapeMissingRepacks();
  }

  Future<void> _checkSettings() async {
    await SettingsService().checkAndCopySettings();
    DdManager.instance.setMaxConcurrentDownloads(
        await SettingsService().loadMaxTasksSettings());
    selectedTheme = await SettingsService().loadSelectedTheme();
    if (selectedTheme == 2) {
      Window.setEffect(effect: WindowEffect.acrylic);
    }
  }

  Future<void> _checkForUpdates() async {
    final latestReleaseInfo = await updater.getLatestReleaseInfo();
    appVersion = await updater.getAppVersion();
    latestVersion = latestReleaseInfo['tag_name']!;
    releaseNotes = latestReleaseInfo['release_notes']!;
    isUpdateAvailable = appVersion != latestVersion.substring(1);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _requestPermissions();
    _initialization = loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return SystemThemeBuilder(builder: (context, accent) {
      final colorScheme = ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.dark,
      );
      return DynamicThemeBuilder(
        title: 'Fit Flutter',
        home: FutureBuilder<void>(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<double>(
                        valueListenable: _scraperService.loadingProgress,
                        builder: (context, progress, child) {
                          return CircularProgressIndicator(value: progress);
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(loadingMessage),
                      if (isUpdateAvailable)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                            ?.aNewVersionOfTheAppIsAvailableWouldYouLikeToUpdateNow ??
                                        'A new version of the app is available. Would you like to update now?',
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${AppLocalizations.of(context)?.currentVersion ?? 'Current version'}: $appVersion',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    '${AppLocalizations.of(context)?.latestVersion ?? 'Latest version'}: $latestVersion',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  MarkdownBody(
                                    data: releaseNotes,
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
                                          borderRadius:
                                              BorderRadius.circular(10.0),
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
                                            AppLocalizations.of(context)?.yes ??
                                                'Yes'),
                                      ),
                                      const SizedBox(width: 16),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        )),
                                        onPressed: () {
                                          setState(() {
                                            isUpdateAvailable = false;
                                          });
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)?.no ??
                                                'No'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            } else {
              return Container(
                color: Platform.isWindows
                    ? Colors.transparent
                    : colorScheme.surface,
                child: MainPage(
                  downloadFolder: defaultDownloadPath,
                ),
              );
            }
          },
        ),
      );
    });
  }
}
