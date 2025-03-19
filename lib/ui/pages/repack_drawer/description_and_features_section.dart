import 'package:fit_flutter/data_classes/repack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum SectionType {
  description,
  features,
}

class DescriptionAndFeaturesSection extends StatelessWidget {
  const DescriptionAndFeaturesSection({
    super.key,
    required this.selectedRepack,
    required this.constraints,
    required this.sectionType,
  });

  final Repack? selectedRepack;
  final BoxConstraints constraints;
  final SectionType sectionType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sectionType == SectionType.description
                      ? AppLocalizations.of(context)!.gameDescription
                      : AppLocalizations.of(context)!.repackFeatures,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              sectionType == SectionType.description
                  ? selectedRepack?.description ??
                      AppLocalizations.of(context)!.noDescriptionAvailable
                  : selectedRepack?.repackFeatures ??
                      AppLocalizations.of(context)!.noFeaturesAvailable,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 16),
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
