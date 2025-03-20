import 'package:fit_flutter/services/repack_service.dart';
import 'package:fit_flutter/ui/pages/left_drawer/menu_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer(
      {super.key,
      required this.constraints,
      required this.openRepackPage,
      required this.changeWidget}); // Dodaj parametr changeWidget
  final BoxConstraints constraints;
  final Function openRepackPage;
  final Function(String) changeWidget; // Dodaj parametr changeWidget

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  final RepackService _repackService = RepackService.instance;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 304),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 4, top: 8, bottom: 8),
        child: Container(
          decoration: BoxDecoration(
            // color: Colors.black.withValues(alpha: 0.2),
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchAnchor(
                  viewElevation: (0),
                  viewBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  viewConstraints: BoxConstraints(
                      maxWidth: widget.constraints.maxWidth * 0.8,
                      maxHeight: widget.constraints.maxHeight * 0.4),
                  builder: (BuildContext context, SearchController controller) {
                    return SearchBar(
                      elevation: const WidgetStatePropertyAll<double>(0),
                      backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.surfaceContainerHighest),
                      controller: controller,
                      hintText: AppLocalizations.of(context)!.searchRepacks,
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
                    return _repackService.allRepacksNames.keys
                        .where((name) => name
                            .toLowerCase()
                            .contains(controller.text.toLowerCase()))
                        .map((name) => ListTile(
                              title: Text(name),
                              onTap: () {
                                widget.openRepackPage(
                                    repackUrl:
                                        _repackService.allRepacksNames[name] ?? '');
                                controller.closeView(name);
                              },
                            ))
                        .toList();
                  },
                ),
              ),
              MenuSection(
                  changeWidget: widget
                      .changeWidget),
            ],
          ),
        ),
      ),
    );
  }
}
