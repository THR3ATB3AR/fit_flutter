import 'package:file_picker/file_picker.dart';
import 'package:fit_flutter/data_classes/download_info.dart';
import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/services/host_service.dart';
import 'package:fit_flutter/ui/widgets/download_dropdown.dart';
import 'package:fit_flutter/ui/widgets/download_files_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

class DownloadButton extends StatefulWidget {
  DownloadButton(
      {super.key,
      required this.constraints,
      required this.downloadManager,
      required this.selectedRepack,
      required this.selectedHost});
  final BoxConstraints constraints;
  final DownloadManager downloadManager;
  final Repack? selectedRepack;
  String? selectedHost;

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  @override
  void initState() {
    super.initState();
    directoryController.text = 'C:/Games/FitFlutter/';
    selectedDirectory = directoryController.text;
  }

  TextEditingController directoryController = TextEditingController();
  String? selectedDirectory;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: widget.constraints.maxWidth * 0.15,
        child: FilledButton.tonal(
          onPressed: () async {
            List<DownloadInfo> findls = [];
            bool isHostSelected = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Select Download Options'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DownloadDropdown(
                        repack: widget.selectedRepack!,
                        onSelected: (String host) {
                          widget.selectedHost = host;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(children: [
                          TextField(
                            controller: directoryController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Download Folder',
                            ),
                            onChanged: (String directory) {
                              selectedDirectory = directory;
                            },
                          ),
                          Positioned(
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(Icons.folder),
                                onPressed: () async {
                                  selectedDirectory = await FilePicker.platform
                                      .getDirectoryPath();
                              
                                  if (selectedDirectory != null) {
                                    selectedDirectory =
                                        '${selectedDirectory!.replaceAll('\\', '/')}/';
                                    directoryController.text = selectedDirectory!;
                                  }
                                },
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (widget.selectedHost != null) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          List dls = widget.selectedHost!.split(', ');
                          for (var i in dls) {
                            try {
                              findls.add(
                                  await HostService().getDownloadPlugin(i));
                            } catch (e) {
                              print('Failed to load plugin for host: $i');
                            }
                          }
                          Navigator.of(context).pop();
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: const Text('Select'),
                    ),
                  ],
                );
              },
            );
            if (isHostSelected) {
              setState(() {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DownloadFilesList(
                          findls: findls,
                          downloadFolder: selectedDirectory,
                          downloadManager: widget.downloadManager,
                          title: widget.selectedRepack?.title ?? 'No title');
                    });
              });
            }
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                side: BorderSide(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          child: const Text('Download'),
        ),
      ),
    );
  }
}
