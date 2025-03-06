import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/left_info_section.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/right_info_section.dart';
import 'package:fit_flutter/ui/pages/repack_drawer/screenhots_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

class RepackDrawer extends StatefulWidget {
  const RepackDrawer(
      {super.key,
      required this.constraints,
      required this.screenshotIndex,
      required this.selectedRepack,
      required this.downloadManager,
      required this.selectedHost});
  final DownloadManager downloadManager;
  final String? selectedHost;
  final BoxConstraints constraints;
  final int screenshotIndex;
  final Repack? selectedRepack;

  @override
  State<RepackDrawer> createState() => _RepackDrawerState();
}

class _RepackDrawerState extends State<RepackDrawer> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: widget.selectedRepack == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      LeftInfoSection(
                        selectedRepack: widget.selectedRepack,
                        downloadManager: widget.downloadManager,
                        selectedHost: widget.selectedHost,
                        constraints: widget.constraints,
                      ),
                      RightInfoSection(
                        selectedRepack: widget.selectedRepack,
                        constraints: widget.constraints,
                      ),
                    ],
                  ),
                  ScreenhotsSection(
                      constraints: widget.constraints,
                      screenshotIndex: widget.screenshotIndex,
                      selectedRepack: widget.selectedRepack)
                ],
              ),
            ),
    );
  }
}
