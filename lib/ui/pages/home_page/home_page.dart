import 'package:fit_flutter/data/repack_list_type.dart';
import 'package:fit_flutter/ui/widgets/repack_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.openRepackPage});
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            RepackSlider(
                repackListType: RepackListType.newest,
                title: AppLocalizations.of(context)!.newRepacks,
                onRepackTap: (repack) {
                  widget.openRepackPage(repack: repack);
                }),
            RepackSlider(
                repackListType: RepackListType.popular,
                title: AppLocalizations.of(context)!.popularRepacks,
                onRepackTap: (repack) {
                  widget.openRepackPage(repack: repack);
                }),
          ],
        ),
      ),
    );
  }
}
