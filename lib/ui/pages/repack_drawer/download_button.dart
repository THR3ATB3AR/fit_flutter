import 'package:file_picker/file_picker.dart';
import 'package:fit_flutter/data_classes/download_info.dart';
import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/services/host_service.dart';
import 'package:fit_flutter/services/settings_service.dart';
import 'package:fit_flutter/ui/widgets/download_dropdown.dart';
import 'package:fit_flutter/ui/widgets/download_files_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadButton extends StatefulWidget {
  const DownloadButton({
    super.key,
    required this.selectedRepack,
  });
  final Repack? selectedRepack;

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  String? selectedHost;
  @override
  void initState() {
    super.initState();
    setDefaultDownloadFolder();
  }

  TextEditingController directoryController = TextEditingController();
  String? selectedDirectory;
  void setDefaultDownloadFolder() async {
    SettingsService().loadDownloadPathSettings().then((String? downloadPath) {
      if (downloadPath != null) {
        directoryController.text = downloadPath;
        selectedDirectory = downloadPath;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          List<DownloadInfo> findls = [];
          bool isHostSelected = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title:
                    Text(AppLocalizations.of(context)!.selectDownloadOptions),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DownloadDropdown(
                        repack: widget.selectedRepack!,
                        onSelected: (String host) {
                          selectedHost = host;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(clipBehavior: Clip.none, children: [
                          TextField(
                            controller: directoryController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText:
                                  AppLocalizations.of(context)!.downloadFolder,
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
                                        selectedDirectory!.replaceAll('\\', '/');
                                    if (!selectedDirectory!.endsWith('/')) {
                                      selectedDirectory = '$selectedDirectory/';
                                    }
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
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      if (selectedHost != null) {
                        if (selectedHost!.startsWith("magnet:")) {
                          launchUrl(Uri.parse(selectedHost!));
                          Navigator.of(context).pop(false);
                        } else {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          List dls = selectedHost!.split(', ');
                          for (var i in dls) {
                            try {
                              findls.add(
                                  await HostService().getDownloadPlugin(i));
                            } catch (e) {
                              print('Failed to load plugin for host: $i');
                            }
                          }
                          navigator.pop();
                          navigator.pop(true);
                        }
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.select),
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
                        title: widget.selectedRepack?.title ??
                            AppLocalizations.of(context)!.noTitle);
                  });
            });
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20.0),
        ),
        child: Text(AppLocalizations.of(context)!.download,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}
