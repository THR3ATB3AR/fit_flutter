import 'package:fit_flutter/ui/pages/home_page/download_manager_page.dart';
import 'package:fit_flutter/ui/pages/home_page/home_page.dart';
import 'package:fit_flutter/ui/pages/home_page/repack_page.dart';
import 'package:fit_flutter/ui/pages/home_page/settings_page.dart';
import 'package:fit_flutter/ui/pages/left_drawer/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fit_flutter/data/repack.dart';
import 'package:fit_flutter/services/scraper_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.downloadFolder});
  final String? downloadFolder;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Repack? selectedRepack;
  late BuildContext scaffoldContext;
  final _scraperService = ScraperService.instance;
  int _currentIndex = 0;

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
                  padding: const EdgeInsets.only(
                      left: 4, right: 8, top: 8, bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: IndexedStack(
                        key: ValueKey<int>(_currentIndex),
                        index: _currentIndex,
                        children: _buildPages(),
                      ),
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

  List<Widget> _buildPages() {
    return [
      HomePage(
        key: const ValueKey('home'),
        openRepackPage: openRepackPage,
      ),
      RepackPage(
          key: UniqueKey(),
          selectedRepack: selectedRepack,
          goHome: changeWidget),
      const SettingsPage(key: ValueKey('settings')),
      const DownloadManagerPage(key: ValueKey('downloads')),
    ];
  }

  void changeWidget(String widgetName) {
    setState(() {
      switch (widgetName) {
        case 'home':
          _currentIndex = 0;
          break;
        case 'repack':
          _currentIndex = 1;
          break;
        case 'settings':
          _currentIndex = 2;
          break;
        case 'downloads':
          _currentIndex = 3;
          break;
      }
    });
  }
}
