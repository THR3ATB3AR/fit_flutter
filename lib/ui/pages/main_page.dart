import 'package:fit_flutter/ui/pages/home_page/download_manager_page.dart';
import 'package:fit_flutter/ui/pages/home_page/home_page.dart';
import 'package:fit_flutter/ui/pages/home_page/repack_page.dart';
import 'package:fit_flutter/ui/pages/home_page/settings_page.dart';
import 'package:fit_flutter/ui/pages/left_drawer/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fit_flutter/data/repack.dart';
import 'package:fit_flutter/services/scraper_service.dart';

class MainPage extends StatefulWidget {
  const MainPage(
      {super.key,
      required this.downloadFolder});
  final String? downloadFolder;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Repack? selectedRepack;
  late BuildContext scaffoldContext;
  int screenshotIndex = 0;
  String currentWidget = 'home';
  final _scraperService = ScraperService.instance;

  @override
  void initState() {
    super.initState();
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
    _scraperService.scrapeRepackFromSearch(repackUrl).then((repack) {
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
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              LeftDrawer(
                  constraints: constraints,
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
          openRepackPage: openRepackPage,
        );
      case 'repack':
        return RepackPage(
          key: const ValueKey('repack'),
          selectedRepack: selectedRepack,
          goHome: changeWidget,
        );

      case 'settings':
        return const SettingsPage(key: ValueKey('settings'));
      case 'downloads':
        return const DownloadManagerPage(key: ValueKey('downloads'));
      default:
        return const Center(
            key: ValueKey('unknown'), child: Text('Unknown Page'));
    }
  }
}
