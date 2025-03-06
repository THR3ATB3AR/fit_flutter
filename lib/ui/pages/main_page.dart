import 'package:fit_flutter/data_classes/download_info.dart';
import 'package:fit_flutter/services/host_service.dart';
import 'package:fit_flutter/ui/widgets/download_dropdown.dart';
import 'package:fit_flutter/ui/widgets/download_files_list.dart';
import 'package:flutter/material.dart';
import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/services/scraper_service.dart';
import 'package:fit_flutter/ui/widgets/repack_slider.dart';
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
            Drawer(
              shape: Border.all(style: BorderStyle.none),
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 4, top: 8, bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SearchAnchor(
                            viewElevation: (0),
                            viewBackgroundColor: Colors.black.withOpacity(0.5),
                            viewConstraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.8,
                                maxHeight: constraints.maxHeight * 0.26),
                            builder: (BuildContext context,
                                SearchController controller) {
                              return SearchBar(
                                elevation:
                                    const MaterialStatePropertyAll<double>(0),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.black.withOpacity(0.5)),
                                controller: controller,
                                hintText: 'Search repacks',
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
                              return allRepacksNames.keys
                                  .where((name) => name
                                      .toLowerCase()
                                      .contains(controller.text.toLowerCase()))
                                  .map((name) => ListTile(
                                        title: Text(name),
                                        onTap: () {
                                          openDrawerWithRepack(
                                              repackUrl:
                                                  allRepacksNames[name] ?? '');
                                          controller.closeView(name);
                                        },
                                      ))
                                  .toList();
                            },
                          ))
                    ],
                  ),
                ),
              ),
            ),
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
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Column(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        child: Image.network(
                                                          selectedRepack
                                                                  ?.cover ??
                                                              'https://fitgirl-repacks.site/wp-content/uploads/2016/08/cropped-icon-270x270.jpg',
                                                          width: constraints
                                                                  .maxWidth *
                                                              0.15,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8),
                                                        child: SizedBox(
                                                          width: constraints
                                                                  .maxWidth *
                                                              0.15,
                                                          child: FilledButton
                                                              .tonal(
                                                            onPressed:
                                                                () async {
                                                              List<DownloadInfo>
                                                                  findls = [];
                                                              bool
                                                                  isHostSelected =
                                                                  await showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: const Text(
                                                                        'Select Download Options'),
                                                                    content:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        DownloadDropdown(
                                                                          repack:
                                                                              selectedRepack!,
                                                                          onSelected:
                                                                              (String host) {
                                                                            selectedHost =
                                                                                host;
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop(false);
                                                                        },
                                                                        child: const Text(
                                                                            'Cancel'),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          if (selectedHost !=
                                                                              null) {
                                                                            showDialog(
                                                                              context: context,
                                                                              barrierDismissible: false,
                                                                              builder: (BuildContext context) {
                                                                                return const Center(
                                                                                  child: CircularProgressIndicator(),
                                                                                );
                                                                              },
                                                                            );
                                                                            List
                                                                                dls =
                                                                                selectedHost!.split(', ');
                                                                            for (var i
                                                                                in dls) {
                                                                              try {
                                                                                findls.add(await HostService().getDownloadPlugin(i));
                                                                              } catch (e) {
                                                                                print('Failed to load plugin for host: $i');
                                                                              }
                                                                            }
                                                                            Navigator.of(context).pop();
                                                                            Navigator.of(context).pop(true);
                                                                          }
                                                                        },
                                                                        child: const Text(
                                                                            'Select'),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                              if (isHostSelected) {
                                                                setState(() {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return DownloadFilesList(findls: findls, downloadManager: downloadManager, title: selectedRepack?.title ?? 'No title');
                                                                      });
                                                                });
                                                              }
                                                            },
                                                            style: ButtonStyle(
                                                              shape: MaterialStateProperty
                                                                  .all<
                                                                      RoundedRectangleBorder>(
                                                                const RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            10),
                                                                  ),
                                                                  side:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                                'Download'),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Card.filled(
                                                          child: SizedBox(
                                                            width: constraints
                                                                    .maxWidth *
                                                                0.15,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text.rich(
                                                                TextSpan(
                                                                    text:
                                                                        'Genres: ${selectedRepack?.genres}\n',
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Company: ${selectedRepack?.company}\n',
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            'Language: ${selectedRepack?.language}\n',
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            'Original Size: ${selectedRepack?.originalSize}\n',
                                                                      ),
                                                                      TextSpan(
                                                                          text:
                                                                              'Repack Size: ${selectedRepack?.repackSize}'),
                                                                    ]),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15.0,
                                                            right: 20),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          selectedRepack
                                                                  ?.title ??
                                                              'No repack selected',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 34,
                                                          ),
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .visible,
                                                          maxLines: null,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0),
                                                          child: SizedBox(
                                                            height: constraints
                                                                    .maxHeight *
                                                                0.3,
                                                            width: constraints
                                                                .maxWidth,
                                                            child: Card.filled(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                              'Game Description',
                                                                              style: TextStyle(fontSize: 24)),
                                                                        ],
                                                                      ),
                                                                      Text(
                                                                        selectedRepack?.description ??
                                                                            'No description available',
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                        softWrap:
                                                                            true,
                                                                        overflow:
                                                                            TextOverflow.visible,
                                                                        maxLines:
                                                                            null,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0),
                                                          child: SizedBox(
                                                            height: constraints
                                                                    .maxHeight *
                                                                0.3,
                                                            width: constraints
                                                                .maxWidth,
                                                            child: Card.filled(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                              'Repack Features',
                                                                              style: TextStyle(fontSize: 24)),
                                                                        ],
                                                                      ),
                                                                      Text(
                                                                        selectedRepack?.repackFeatures ??
                                                                            'No feeatures available',
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                        softWrap:
                                                                            true,
                                                                        overflow:
                                                                            TextOverflow.visible,
                                                                        maxLines:
                                                                            null,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
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
                    body: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Colors.black.withOpacity(0.2),
                      ),
                      child: Builder(
                        builder: (BuildContext context) {
                          scaffoldContext = context;
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                RepackSlider(
                                    repacksList: newRepacks,
                                    title: 'New Repacks',
                                    onRepackTap: (repack) {
                                      openDrawerWithRepack(repack: repack);
                                    }),
                                RepackSlider(
                                    repacksList: popularRepacks,
                                    title: 'Popular Repacks',
                                    onRepackTap: (repack) {
                                      openDrawerWithRepack(repack: repack);
                                    }),
                                RepackSlider(
                                    repacksList: updatedRepacks,
                                    title: 'Updated Repacks',
                                    onRepackTap: (repack) {
                                      openDrawerWithRepack(repack: repack);
                                    }),
                              ],
                            ),
                          );
                        },
                      ),
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
