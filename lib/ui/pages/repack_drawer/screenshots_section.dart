import 'package:fit_flutter/data_classes/repack.dart';
import 'package:flutter/material.dart';

class ScreenshotsSection extends StatefulWidget {
  ScreenshotsSection(
      {super.key, required this.selectedRepack, required this.constraints});
  final Repack? selectedRepack;
  final BoxConstraints constraints;

  @override
  State<ScreenshotsSection> createState() => _ScreenshotsSectionState();
}

class _ScreenshotsSectionState extends State<ScreenshotsSection> {
  int screenshotIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: widget.constraints.maxHeight * 0.6,
                maxWidth: widget.constraints.maxWidth * 0.6,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  widget.selectedRepack?.screenshots[screenshotIndex] ??
                      'https://fitgirl-repacks.site/wp-content/uploads/2016/08/cropped-icon-270x270.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.selectedRepack?.screenshots
                      .asMap()
                      .entries
                      .map((entry) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: widget.constraints.maxWidth *
                              0.7 /
                              widget.selectedRepack!.screenshots.length),
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              screenshotIndex = entry.key;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                entry.value,
                                fit: BoxFit.cover,
                                color: entry.key == screenshotIndex
                                    ? Colors.blue.withOpacity(0.5)
                                    : null,
                                colorBlendMode: BlendMode.colorBurn,
                              ),
                            ),
                          )),
                    );
                  }).toList() ??
                  [],
            ),
          ),
        ],
      ),
    );
  }
}
