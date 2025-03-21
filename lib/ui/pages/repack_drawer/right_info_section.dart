import 'package:fit_flutter/data/repack.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/description_and_features_section.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/screenshots_section.dart';
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: constraints.maxHeight,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  selectedRepack!.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ScreenshotsSection(
                selectedRepack: selectedRepack,
                constraints: constraints,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DescriptionAndFeaturesSection(
                  selectedRepack: selectedRepack,
                  constraints: constraints,
                  sectionType: SectionType.description,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DescriptionAndFeaturesSection(
                  selectedRepack: selectedRepack,
                  constraints: constraints,
                  sectionType: SectionType.features,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
