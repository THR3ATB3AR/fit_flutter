import 'package:fit_flutter/data/repack.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/download_button.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/repack_info_section.dart';
import 'package:flutter/material.dart';

class LeftInfoSection extends StatelessWidget {
  const LeftInfoSection({
    super.key,
    required this.selectedRepack,
  });

  final Repack? selectedRepack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.network(
            selectedRepack!.cover,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          child: DownloadButton(selectedRepack: selectedRepack),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          child: RepackInfoSection(selectedRepack: selectedRepack),
        ),
      ],
    );
  }
}
