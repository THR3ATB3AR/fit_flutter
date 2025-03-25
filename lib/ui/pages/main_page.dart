import 'package:fit_flutter/ui/pages/home_page/all_repacks_page.dart';
import 'package:fit_flutter/ui/pages/home_page/download_manager_page.dart';
import 'package:fit_flutter/ui/pages/home_page/failed_repacks_page.dart';
import 'package:fit_flutter/ui/pages/home_page/home_page.dart';
import 'package:fit_flutter/ui/pages/home_page/repack_page.dart';
import 'package:fit_flutter/ui/pages/home_page/settings_page.dart';
import 'package:fit_flutter/ui/pages/left_drawer/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fit_flutter/data/repack.dart';
import 'package:fit_flutter/services/scraper_service.dart';
import 'package:fit_flutter/services/repack_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final RepackService _repackService = RepackService.instance;
  int _currentIndex = 0;
  String title = 'Home';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          title: Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 4.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          flexibleSpace: _currentIndex == 0 || _currentIndex == 1
              ? Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    child: Center(
                      child: SizedBox(
                        child: StreamBuilder<void>(
                          stream: _repackService.repacksStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            return SearchAnchor(
                              viewElevation: (0),
                              viewBackgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              viewConstraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.4,
                              ),
                              builder: (BuildContext context,
                                  SearchController controller) {
                                return SearchBar(
                                  elevation:
                                      const WidgetStatePropertyAll<double>(0),
                                  backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                  ),
                                  controller: controller,
                                  hintText: AppLocalizations.of(context)!
                                      .searchRepacks,
                                  leading: const Icon(Icons.search),
                                  onTap: () {
                                    controller.openView();
                                  },
                                  onChanged: (value) {
                                    controller.openView();
                                  },
                                );
                              },
                              suggestionsBuilder: (BuildContext context,
                                  SearchController controller) {
                                return _repackService.allRepacksNames.keys
                                    .where((name) => name
                                        .toLowerCase()
                                        .contains(
                                            controller.text.toLowerCase()))
                                    .map((name) => ListTile(
                                          title: Text(name),
                                          onTap: () {
                                            openRepackPage(
                                                repackUrl: _repackService
                                                            .allRepacksNames[
                                                        name] ??
                                                    '');
                                            controller.closeView(name);
                                          },
                                        ))
                                    .toList();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                  ),
                ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              LeftDrawer(
                constraints: constraints,
                changeWidget: changeWidget,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 4, right: 8, top: 8, bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: IndexedStack(
                      key: ValueKey<int>(_currentIndex),
                      index: _currentIndex,
                      children: _buildPages(),
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
      AllRepacksPage(
          key: const ValueKey('allRepacks'), openRepackPage: openRepackPage),
      RepackPage(
        key: UniqueKey(),
        selectedRepack: selectedRepack,
        goHome: changeWidget,
      ),
      const SettingsPage(key: ValueKey('settings')),
      const DownloadManagerPage(key: ValueKey('downloads')),
      const FailedRepacksPage(key: ValueKey('failed')),
    ];
  }

  void changeWidget(String widgetName) {
    setState(() {
      switch (widgetName) {
        case 'home':
          _currentIndex = 0;
          title = AppLocalizations.of(context)!.home;
          break;
        case 'allRepacks':
          _currentIndex = 1;
          title = AppLocalizations.of(context)!.allRepacks;
          break;
        case 'repack':
          _currentIndex = 2;
          break;
        case 'settings':
          _currentIndex = 3;
          title = AppLocalizations.of(context)!.settings;
          break;
        case 'downloads':
          _currentIndex = 4;
          title = AppLocalizations.of(context)!.downloadManager;
          break;
        case 'failed':
          _currentIndex = 5;
          title = AppLocalizations.of(context)!.failedRepacks;
          break;
      }
    });
  }
}
