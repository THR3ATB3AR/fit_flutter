import 'package:file_picker/file_picker.dart';
import 'package:fit_flutter/data_classes/repack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

class FolderPicker extends StatefulWidget {
  FolderPicker({super.key, required this.constraints, required this.downloadManager, required this.selectedRepack, required this.selectedHost, required this.selectedDirectory, required this.directoryController});
  final TextEditingController directoryController;
  final BoxConstraints constraints;
  final DownloadManager downloadManager;
  final Repack? selectedRepack;
  String? selectedHost;
  String? selectedDirectory;

  @override
  State<FolderPicker> createState() => _FolderPickerState();
}

class _FolderPickerState extends State<FolderPicker> {
  @override
  Widget build(BuildContext context) {
    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(children: [
                          TextField(
                            controller: widget.directoryController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Download Folder',
                            ),
                            onChanged: (String directory) {
                              widget.selectedDirectory = directory;
                            },
                          ),
                          Positioned(
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(Icons.folder),
                                onPressed: () async {
                                  widget.selectedDirectory = await FilePicker.platform
                                      .getDirectoryPath();
                              
                                  if (widget.selectedDirectory != null) {
                                    widget.selectedDirectory =
                                        '${widget.selectedDirectory!.replaceAll('\\', '/')}/';
                                    widget.directoryController.text = widget.selectedDirectory!;
                                  }
                                },
                              ),
                            ),
                          ),
                        ]),
                      );
  }
}