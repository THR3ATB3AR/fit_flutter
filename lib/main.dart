import 'dart:io';
import 'package:fit_flutter/services/settings_service.dart';
import 'package:fit_flutter/services/updater.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/services/scraper_service.dart';
import 'package:fit_flutter/ui/pages/main_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  String loadingMessage = '';
  final ScraperService _scraperService = ScraperService();
  String? defaultDownloadPath;
  bool isUpdateAvailable = false;
  Updater updater = Updater();
  String appVersion = '';
  String latestVersion = '';
  String releaseNotes = '';

  Future<void> loadInitialData() async {
    setState(() {
      loadingMessage =
          AppLocalizations.of(context)?.initializing ?? 'Initializing...';
    });

    await _checkSettings();

    if (await SettingsService().loadAutoCheckForUpdates()) {
      await _checkForUpdates();
    }

    newRepacks =
        await _scraperService.scrapeNewRepacks(onProgress: (loaded, total) {
      setState(() {
        loadingMessage =
            '${AppLocalizations.of(context)?.loadingNewRepacks ?? 'Loading new repacks'}... ${((loaded / total) * 100).toStringAsFixed(0)}%';
      });
    });
    popularRepacks =
        await _scraperService.scrapePopularRepacks(onProgress: (loaded, total) {
      setState(() {
        loadingMessage =
            '${AppLocalizations.of(context)?.loadingPopularRepacks ?? 'Loading popular repacks'}... ${((loaded / total) * 100).toStringAsFixed(0)}%';
      });
    });
    updatedRepacks = [];
    allRepacksNames = await _scraperService.scrapeAllRepacksNames(
        onProgress: (loaded, total) {
      setState(() {
        loadingMessage =
            '${AppLocalizations.of(context)?.indexingAllRepacks ?? 'Indexing all repacks'}... ${((loaded / total) * 100).toStringAsFixed(0)}%';
      });
    });
  }

  Future<void> _checkSettings() async {
    await SettingsService().checkAndCopySettings();
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
                            width: MediaQuery.of(context).size.width * 0.4,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                  newRepacks: newRepacks,
                  popularRepacks: popularRepacks,
                  updatedRepacks: updatedRepacks,
                  allRepacksNames: allRepacksNames,
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
