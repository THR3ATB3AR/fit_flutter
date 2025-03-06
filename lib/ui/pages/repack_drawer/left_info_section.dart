import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/download_button.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/repack_info_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

class LeftInfoSection extends StatelessWidget {
  const LeftInfoSection({
    super.key,
    required this.selectedRepack,
    required this.downloadManager,
    required this.selectedHost,
    required this.constraints,
  });

  final Repack? selectedRepack;
  final DownloadManager downloadManager;
  final String? selectedHost;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
          20.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius
                    .circular(10.0),
            child: Image.network(
              selectedRepack
                      ?.cover ??
                  'https://fitgirl-repacks.site/wp-content/uploads/2016/08/cropped-icon-270x270.jpg',
              width: constraints
                      .maxWidth *
                  0.15,
            ),
          ),
          DownloadButton(
              constraints:
                  constraints,
              downloadManager:
                  downloadManager,
              selectedRepack:
                  selectedRepack,
              selectedHost:
                  selectedHost),
          RepackInfoSection(
              selectedRepack:
                  selectedRepack,
              constraints:
                  constraints),
        ],
      ),
    );
  }
}
