import 'package:fit_flutter/data_classes/repack.dart';
import 'package:flutter/material.dart';

class ScreenhotsSection extends StatefulWidget {
  ScreenhotsSection(
      {super.key,
      required this.constraints,
      required this.screenshotIndex,
      required this.selectedRepack});
  final BoxConstraints constraints;
  int screenshotIndex;
  final Repack? selectedRepack;

  @override
  State<ScreenhotsSection> createState() => _ScreenhotsSectionState();
}

class _ScreenhotsSectionState extends State<ScreenhotsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              widget.selectedRepack?.screenshots[widget.screenshotIndex] ??
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaGldo0q0bGnxdCbIic3mY4g2PjqQgRIQhiQ&s',
              height: widget.constraints.maxHeight * 0.8,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                widget.selectedRepack?.screenshots.asMap().entries.map((entry) {
                      return GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.screenshotIndex = entry.key;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                entry.value,
                                width: widget.constraints.maxWidth * 0.08,
                                fit: BoxFit.cover,
                                color: entry.key == widget.screenshotIndex
                                    ? Colors.blue.withOpacity(0.5)
                                    : null,
                                colorBlendMode: BlendMode.colorBurn,
                              ),
                            ),
                          ));
                    }).toList() ??
                    [],
          ),
        ),
      ],
    );
  }
}
