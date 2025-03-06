import 'package:flutter/material.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer(
      {super.key,
      required this.constraints,
      required this.allRepacksNames,
      required this.openDrawerWithRepack});
  final BoxConstraints constraints;
  final Map<String, String> allRepacksNames;
  final Function openDrawerWithRepack;

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: Border.all(style: BorderStyle.none),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 4, top: 8, bottom: 8),
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
                        maxWidth: widget.constraints.maxWidth * 0.8,
                        maxHeight: widget.constraints.maxHeight * 0.26),
                    builder:
                        (BuildContext context, SearchController controller) {
                      return SearchBar(
                        elevation: const MaterialStatePropertyAll<double>(0),
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
                    suggestionsBuilder:
                        (BuildContext context, SearchController controller) {
                      return widget.allRepacksNames.keys
                          .where((name) => name
                              .toLowerCase()
                              .contains(controller.text.toLowerCase()))
                          .map((name) => ListTile(
                                title: Text(name),
                                onTap: () {
                                  widget.openDrawerWithRepack(
                                      repackUrl:
                                          widget.allRepacksNames[name] ?? '');
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
    );
  }
}
