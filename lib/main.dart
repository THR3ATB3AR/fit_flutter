import 'dart:io';
import 'package:fit_flutter/services/settings_service.dart';
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
  ValueNotifier<double> loadingProgress = ValueNotifier<double>(0.0);
  final ScraperService _scraperService = ScraperService.instance;
  String? defaultDownloadPath;

  Future<void> syncRepacks() async {
    setState(() {
      newRepacks = _scraperService.newRepackList;
      popularRepacks = _scraperService.popularRepackList;
      // updatedRepacks = _scraperService.updatedRepackList;
      allRepacksNames = _scraperService.allRepackList;
    });
  }

  Future<void> loadInitialData() async {
    setState(() {
      loadingMessage = 'Initializing...';
    });

    await _checkSettings();

    if (await _scraperService.allFilesExist()) {
      setState(() {
        loadingMessage = 'Loading cached repacks...';
      });
      await _scraperService.loadCashedRepacks();
      newRepacks = _scraperService.oldNewRepackList;
      popularRepacks = _scraperService.oldPopularRepackList;
      updatedRepacks=[];
      // updatedRepacks = _scraperService.oldUpdatedRepackList;
      allRepacksNames = _scraperService.oldAllRepackList;
    } else {
      newRepacks =
          await _scraperService.scrapeNewRepacks(onProgress: (loaded, total) {
        setState(() {
          loadingProgress = _scraperService.newLoadingProgress;
          loadingMessage =
              'Loading new repacks... ${((loaded / total) * 100).toStringAsFixed(0)}%';
        });
      });
      popularRepacks = await _scraperService
          .scrapePopularRepacks(onProgress: (loaded, total) {
        setState(() {
          loadingProgress = _scraperService.popularLoadingProgress;
          loadingMessage =
              'Loading popular repacks... ${((loaded / total) * 100).toStringAsFixed(0)}%';
        });
      });
      updatedRepacks =[];
      // updatedRepacks = await _scraperService
      //     .scrapeUpdatedRepacks(onProgress: (loaded, total) {
      //   setState(() {
      //     loadingProgress = _scraperService.updatedLoadingProgress;
      //     loadingMessage =
      //         'Loading updated repacks... ${((loaded / total) * 100).toStringAsFixed(0)}%';
      //   });
      // });
      allRepacksNames = await _scraperService
          .scrapeAllRepacksNames(onProgress: (loaded, total) {
        setState(() {
          loadingProgress = _scraperService.allLoadingProgress;
          loadingMessage =
              'Indexing all repacks... ${((loaded / total) * 100).toStringAsFixed(0)}%';
        });
      });
    }
  }

  Future<void> _checkSettings() async {
    SettingsService().checkAndCopySettings();
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
                        valueListenable: loadingProgress,
                        builder: (context, progress, child) {
                          return CircularProgressIndicator(value: progress);
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(loadingMessage),
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
                scrapeSync: syncRepacks,
              );
            }
          },
        ),
      );
    });
  }
}