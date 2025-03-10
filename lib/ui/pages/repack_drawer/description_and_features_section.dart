import 'package:fit_flutter/data_classes/repack.dart';
import 'package:flutter/material.dart';

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
        color: Colors.black.withOpacity(0.2),
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
                      ? 'Game Description'
                      : 'Repack Features',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              sectionType == SectionType.description
                  ? selectedRepack?.description ??
                      'No description available'
                  : selectedRepack?.repackFeatures ??
                      'No features available',
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
