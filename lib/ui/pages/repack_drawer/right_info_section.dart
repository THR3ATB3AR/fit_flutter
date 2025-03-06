import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/description_and_features_section.dart';
import 'package:flutter/material.dart';

class RightInfoSection extends StatelessWidget {
  const RightInfoSection({
    super.key,
    required this.selectedRepack,
    required this.constraints,
  });

  final Repack? selectedRepack;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            DescriptionAndFeaturesSection(
                selectedRepack:
                    selectedRepack,
                constraints:
                    constraints,
                sectionType:
                    SectionType
                        .description),
            DescriptionAndFeaturesSection(
                selectedRepack:
                    selectedRepack,
                constraints:
                    constraints,
                sectionType:
                    SectionType
                        .features),
          ],
        ),
      ),
    );
  }
}
