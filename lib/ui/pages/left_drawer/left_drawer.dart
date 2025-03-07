import 'package:fit_flutter/ui/pages/left_drawer/menu_section.dart';
import 'package:flutter/material.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer(
      {super.key,
      required this.constraints,
      required this.allRepacksNames,
      required this.openDrawerWithRepack,
      required this.changeWidget}); // Dodaj parametr changeWidget
  final BoxConstraints constraints;
  final Map<String, String> allRepacksNames;
  final Function openDrawerWithRepack;
  final Function(String) changeWidget; // Dodaj parametr changeWidget

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchAnchor(
                  viewElevation: (0),
                  viewBackgroundColor: Colors.black.withOpacity(0.2),
                  viewConstraints: BoxConstraints(
                      maxWidth: widget.constraints.maxWidth * 0.8,
                      maxHeight: widget.constraints.maxHeight * 0.26),
                  builder: (BuildContext context, SearchController controller) {
                    return SearchBar(
                      elevation: const MaterialStatePropertyAll<double>(0),
                      backgroundColor: MaterialStateProperty.all(
                          Colors.black.withOpacity(0.2)),
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
                                    repackUrl: widget.allRepacksNames[name] ?? '');
                                controller.closeView(name);
                              },
                            ))
                        .toList();
                  },
                ),
              ),
              MenuSection(changeWidget: widget.changeWidget), // Przekaż funkcję changeWidget do MenuSection
            ],
          ),
        ),
      ),
    );
  }
}