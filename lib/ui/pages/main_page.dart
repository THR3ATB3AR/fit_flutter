import 'package:fit_flutter/ui/pages/home_page/home_page_widget.dart';
import 'package:fit_flutter/ui/pages/left_drawer/left_drawer.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/left_info_section.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/right_info_section.dart';
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            LeftDrawer(
                constraints: constraints,
                allRepacksNames: allRepacksNames,
                openDrawerWithRepack: openDrawerWithRepack),
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
                              Expanded(
                                child: selectedRepack == null
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                LeftInfoSection(selectedRepack: selectedRepack, downloadManager: downloadManager, selectedHost: selectedHost, constraints: constraints,),
                                                RightInfoSection(selectedRepack: selectedRepack, constraints: constraints,),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Image.network(
                                                      selectedRepack
                                                                  ?.screenshots[
                                                              screenshotIndex] ??
                                                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaGldo0q0bGnxdCbIic3mY4g2PjqQgRIQhiQ&s',
                                                      height: constraints
                                                              .maxHeight *
                                                          0.8,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: selectedRepack
                                                            ?.screenshots
                                                            .asMap()
                                                            .entries
                                                            .map((entry) {
                                                          return GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  screenshotIndex =
                                                                      entry.key;
                                                                });
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                  child: Image
                                                                      .network(
                                                                    entry.value,
                                                                    width: constraints
                                                                            .maxWidth *
                                                                        0.08,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    color: entry.key ==
                                                                            screenshotIndex
                                                                        ? Colors
                                                                            .blue
                                                                            .withOpacity(0.5)
                                                                        : null,
                                                                    colorBlendMode:
                                                                        BlendMode
                                                                            .colorBurn,
                                                                  ),
                                                                ),
                                                              ));
                                                        }).toList() ??
                                                        [],
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          )),
                    ),
                    body: Builder(
                      builder: (BuildContext context) {
                        scaffoldContext = context;
                        return HomePageWidget(
                          scaffoldContext: scaffoldContext,
                          newRepacks: newRepacks,
                          popularRepacks: popularRepacks,
                          updatedRepacks: updatedRepacks,
                          openDrawerWithRepack: openDrawerWithRepack,
                        );
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
