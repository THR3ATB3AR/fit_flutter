import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/ui/widgets/repack_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  HomePage(
      {super.key,
      required this.scaffoldContext,
      required this.newRepacks,
      required this.popularRepacks,
      required this.updatedRepacks,
      required this.openRepackPage});
  BuildContext scaffoldContext;
  final List<Repack> newRepacks;
  final List<Repack> popularRepacks;
  final List<Repack> updatedRepacks;
  final Function openRepackPage;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BoxConstraints constraints = const BoxConstraints.expand();
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Builder(
        builder: (BuildContext context) {
          widget.scaffoldContext = context;
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: RepackSlider(
                      repacksList: widget.newRepacks,
                      title: AppLocalizations.of(context)!.newRepacks,
                      onRepackTap: (repack) {
                        widget.openRepackPage(repack: repack);
                      }),
                ),
                RepackSlider(
                    repacksList: widget.popularRepacks,
                    title: AppLocalizations.of(context)!.popularRepacks,
                    onRepackTap: (repack) {
                      widget.openRepackPage(repack: repack);
                    }),
                // RepackSlider(
                //     repacksList: widget.updatedRepacks,
                //     title: 'Updated Repacks',
                //     onRepackTap: (repack) {
                //       widget.openRepackPage(repack: repack);
                //     }),
              ],
            ),
          );
        },
      ),
    );
  }
}
