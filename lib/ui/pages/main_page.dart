import 'package:fit_flutter/ui/pages/home_page/home_page_widget.dart';
import 'package:fit_flutter/ui/pages/left_drawer/left_drawer.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/repack_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/services/scraper_service.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

class MainPage extends StatefulWidget {
  final List<Repack> newRepacks;
  final List<Repack> popularRepacks;
  final List<Repack> updatedRepacks;
  final Map<String, String> allRepacksNames;
  const MainPage(
      {super.key,
      required this.newRepacks,
      required this.popularRepacks,
      required this.updatedRepacks,
      required this.allRepacksNames});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late List<Repack> newRepacks;
  late List<Repack> popularRepacks;
  late List<Repack> updatedRepacks;
  late Map<String, String> allRepacksNames;
  Repack? selectedRepack;
  late BuildContext scaffoldContext;
  int screenshotIndex = 0;
  String? selectedHost;
  final DownloadManager downloadManager = DownloadManager();
  String currentWidget = 'home'; // Dodaj zmienną stanu do przechowywania aktualnie wybranego widgetu

  @override
  void initState() {
    super.initState();
    newRepacks = widget.newRepacks;
    popularRepacks = widget.popularRepacks;
    updatedRepacks = widget.updatedRepacks;
    allRepacksNames = widget.allRepacksNames;
  }

  void openDrawerWithRepack({String repackUrl = '', Repack? repack}) {
    setState(() {
      selectedRepack = null;
    });
    if (repack != null) {
      setState(() {
        selectedRepack = repack;
      });
      Scaffold.of(scaffoldContext).openEndDrawer();
      return;
    }
    Scaffold.of(scaffoldContext).openEndDrawer();
    ScraperService().scrapeRepackFromSearch(repackUrl).then((repack) {
      setState(() {
        selectedRepack = repack;
      });
    });
  }

  void changeWidget(String widgetName) {
    setState(() {
      currentWidget = widgetName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            LeftDrawer(
                constraints: constraints,
                allRepacksNames: allRepacksNames,
                openDrawerWithRepack: openDrawerWithRepack,
                changeWidget: changeWidget), // Przekaż funkcję changeWidget do LeftDrawer
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 4, right: 8, top: 8, bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Scaffold(
                    drawerScrimColor: Colors.transparent,
                    endDrawer: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.black.withOpacity(0.9),
                      ),
                      child: Drawer(
                          width: constraints.maxWidth,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: IconButton.filledTonal(
                                  onPressed: () {
                                    Scaffold.of(scaffoldContext)
                                        .closeEndDrawer();
                                    screenshotIndex = 0;
                                  },
                                  icon: const Icon(Icons.arrow_forward_ios),
                                ),
                              ),
                              RepackDrawer(constraints: constraints, screenshotIndex: screenshotIndex, selectedRepack: selectedRepack, downloadManager: downloadManager, selectedHost: selectedHost)
                            ],
                          )),
                    ),
                    body: Builder(
                      builder: (BuildContext context) {
                        scaffoldContext = context;
                        // Wyświetl odpowiedni widget w zależności od stanu currentWidget
                        if (currentWidget == 'home') {
                          return HomePageWidget(
                            scaffoldContext: scaffoldContext,
                            newRepacks: newRepacks,
                            popularRepacks: popularRepacks,
                            updatedRepacks: updatedRepacks,
                            openDrawerWithRepack: openDrawerWithRepack,
                          );
                        } else if (currentWidget == 'settings') {
                          return Center(child: Text('Settings Page'));
                        } else if (currentWidget == 'downloads') {
                          return Center(child: Text('Downloads Page'));
                        } else {
                          return Center(child: Text('Unknown Page'));
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}