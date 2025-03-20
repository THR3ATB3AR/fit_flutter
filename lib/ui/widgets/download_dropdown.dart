import 'package:flutter/material.dart';
import 'package:fit_flutter/data/repack.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DownloadDropdown extends StatefulWidget {
  final Repack repack;
  final Function(String) onSelected;
  const DownloadDropdown(
      {super.key, required this.repack, required this.onSelected});

  @override
  State<DownloadDropdown> createState() => _DownloadDropdownState();
}

class _DownloadDropdownState extends State<DownloadDropdown> {
  Map<String, String?> selectedValues = {};
  String? initialValue;
  String? secondDropdownValue;

  @override
  void initState() {
    super.initState();

    if (widget.repack.downloadLinks.isNotEmpty) {
      initialValue = widget.repack.downloadLinks.keys.first;
      selectedValues['key'] = initialValue;
      secondDropdownValue =
          widget.repack.downloadLinks[initialValue]?.first['url'];
      widget.onSelected(secondDropdownValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.selectDownloadOption,
              border: const OutlineInputBorder(),
            ),
            value: initialValue,
            items: widget.repack.downloadLinks.keys.map((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(key),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                initialValue = newValue;
                selectedValues['key'] = newValue;
                secondDropdownValue =
                    widget.repack.downloadLinks[newValue]?.first['url'];
                widget.onSelected(
                    widget.repack.downloadLinks[newValue]!.first['url']!);
              });
            },
          ),
        ),
        if (initialValue != null &&
            widget.repack.downloadLinks[initialValue] != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.selectHoster,
                border: const OutlineInputBorder(),
              ),
              value: secondDropdownValue,
              items: widget.repack.downloadLinks[initialValue]!.map((link) {
                return DropdownMenuItem<String>(
                  value: link['url'],
                  child: Text(link['hostName']!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  secondDropdownValue = newValue;
                  selectedValues['url'] = newValue;
                  widget.onSelected(newValue!);
                });
              },
            ),
          ),
      ],
    );
  }
}
