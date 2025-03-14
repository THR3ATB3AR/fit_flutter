import 'package:fit_flutter/ui/pages/home_page/download_manager_page.dart';
import 'package:fit_flutter/ui/pages/home_page/home_page.dart';
import 'package:fit_flutter/ui/pages/home_page/repack_page.dart';
import 'package:fit_flutter/ui/pages/home_page/settings_page.dart';
import 'package:fit_flutter/ui/pages/left_drawer/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/services/scraper_service.dart';

class MainPage extends StatefulWidget {
  final List<Repack> newRepacks;
  final List<Repack> popularRepacks;
  final List<Repack> updatedRepacks;
  final Map<String, String> allRepacksNames;
  MainPage(
      {super.key,
      required this.newRepacks,
      required this.popularRepacks,
      required this.updatedRepacks,
      required this.allRepacksNames,
      required this.downloadFolder});
  String? downloadFolder;

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
  String currentWidget = 'home';

  @override
  void initState() {
    super.initState();
    newRepacks = widget.newRepacks;
    popularRepacks = widget.popularRepacks;
    updatedRepacks = widget.updatedRepacks;
    allRepacksNames = widget.allRepacksNames;
  }

  void openRepackPage({String repackUrl = '', Repack? repack}) {
    setState(() {
      selectedRepack = null;
    });
    if (repack != null) {
      setState(() {
        selectedRepack = repack;
      });
      changeWidget('repack');
      return;
    }
    changeWidget('repack');
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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              LeftDrawer(
                  constraints: constraints,
                  allRepacksNames: allRepacksNames,
                  openRepackPage: openRepackPage,
                  changeWidget: changeWidget),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 4, right: 8, top: 8, bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Builder(
                      builder: (BuildContext context) {
                        scaffoldContext = context;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                          child: _getCurrentWidget(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _getCurrentWidget() {
    switch (currentWidget) {
      case 'home':
        return HomePage(
          key: const ValueKey('home'),
          scaffoldContext: scaffoldContext,
          newRepacks: newRepacks,
          popularRepacks: popularRepacks,
          updatedRepacks: updatedRepacks,
          openRepackPage: openRepackPage,
        );
      case 'repack':
        return RepackPage(
          key: const ValueKey('repack'),
          selectedRepack: selectedRepack,
          goHome: changeWidget,
        );

      case 'settings':
        return SettingsPage(key: const ValueKey('settings'));
      case 'downloads':
        return const DownloadManagerPage(key: ValueKey('downloads'));
      default:
        return const Center(
            key: ValueKey('unknown'), child: Text('Unknown Page'));
    }
  }
}
