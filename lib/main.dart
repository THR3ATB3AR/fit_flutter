import 'dart:io';
import 'package:fit_flutter/services/settings_service.dart';
import 'package:fit_flutter/services/updater.dart';
import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/services/scraper_service.dart';
import 'package:fit_flutter/ui/pages/main_page.dart';

late List<Repack> newRepacks;
late List<Repack> popularRepacks;
late List<Repack> updatedRepacks;
late Map<String, String> allRepacksNames;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentColor.load();
  if (Platform.isWindows) {
    await Window.initialize();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final accentColor = SystemTheme.accentColor.accent;
  late Future<void> _initialization;
  String loadingMessage = 'Initializing...';
  final ScraperService _scraperService = ScraperService();
  String? defaultDownloadPath;
  bool isUpdateAvailable = false;
  Updater updater = Updater();
  String appVersion = '';
  String latestVersion = '';

  Future<void> loadInitialData() async {
    setState(() {
      loadingMessage = 'Initializing...';
    });

    await _checkSettings();

    await _checkForUpdates();

    newRepacks =
        await _scraperService.scrapeNewRepacks(onProgress: (loaded, total) {
      setState(() {
        loadingMessage =
            'Loading new repacks... ${((loaded / total) * 100).toStringAsFixed(0)}%';
      });
    });
    popularRepacks =
        await _scraperService.scrapePopularRepacks(onProgress: (loaded, total) {
      setState(() {
        loadingMessage =
            'Loading popular repacks... ${((loaded / total) * 100).toStringAsFixed(0)}%';
      });
    });
    updatedRepacks = [];
    allRepacksNames = await _scraperService.scrapeAllRepacksNames(
        onProgress: (loaded, total) {
      setState(() {
        loadingMessage =
            'Indexing all repacks... ${((loaded / total) * 100).toStringAsFixed(0)}%';
      });
    });
  }

  Future<void> _checkSettings() async {
    SettingsService().checkAndCopySettings();
  }

  Future<void> _checkForUpdates() async {
    appVersion = await updater.getAppVersion();
    latestVersion = await updater.getLatestReleaseVersion();
    isUpdateAvailable = appVersion != latestVersion.substring(1);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      Window.setEffect(effect: WindowEffect.acrylic);
    }

    _initialization = loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return SystemThemeBuilder(builder: (context, accent) {
      final colorScheme = ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.dark,
      );
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fit Flutter',
        theme: (Platform.isWindows)
            ? ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: accentColor,
                  brightness: Brightness.dark,
                  surface: Colors.transparent,
                  surfaceTint: Colors.transparent,
                  onPrimary: Colors.transparent,
                  onSecondary: Colors.transparent,
                  onSecondaryContainer: Colors.white,
                ),
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.transparent,
              )
            : ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: accentColor,
                  brightness: Brightness.dark,
                ),
                scaffoldBackgroundColor: colorScheme.surface,
                brightness: Brightness.dark,
                drawerTheme: DrawerThemeData(
                  backgroundColor: colorScheme.surface,
                ),
              ),
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
                            width: MediaQuery.of(context).size.width *
                                0.4, // Ustaw szerokość na 80% szerokości ekranu
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'A new version of the app is available. Would you like to update now?\n\nCurrent version: $appVersion\nLatest version: ${latestVersion.substring(1)}',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          // backgroundColor: Colors.deepPurple,
                                          shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                      onPressed: () async {
                                        setState(() {
                                          isUpdateAvailable = false;
                                        });
                                        final filePath = await updater
                                            .downloadLatestRelease();
                                        await updater
                                            .runDownloadedSetup(filePath);
                                      },
                                      child: const Text('Yes'),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          // backgroundColor: Colors.deepPurple,
                                          shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                      onPressed: () {
                                        setState(() {
                                          isUpdateAvailable = false;
                                        });
                                      },
                                      child: const Text('No'),
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
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            } else {
              return MainPage(
                newRepacks: newRepacks,
                popularRepacks: popularRepacks,
                updatedRepacks: updatedRepacks,
                allRepacksNames: allRepacksNames,
                downloadFolder: defaultDownloadPath,
              );
            }
          },
        ),
      );
    });
  }
}
