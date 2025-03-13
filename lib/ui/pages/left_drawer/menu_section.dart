import 'package:flutter/material.dart';

class MenuSection extends StatefulWidget {
  const MenuSection({super.key, required this.changeWidget});
  final Function(String) changeWidget;

  @override
  _MenuSectionState createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  bool isSettings = false;
  bool isDownloads = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 4, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isDownloads = !isDownloads;
                  isSettings = false;
                });
                widget.changeWidget(isDownloads
                    ? 'downloads'
                    : 'home'); // Zmień widget na 'downloads' lub 'home'
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20.0),
              ),
              child: Icon(
                  isDownloads ? Icons.close : Icons.downloading_outlined,
                  size: 30.0),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 4, right: 8, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isSettings = !isSettings;
                  isDownloads = false;
                });
                widget.changeWidget(isSettings
                    ? 'settings'
                    : 'home'); // Zmień widget na 'settings' lub 'home'
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 20.0),
              ),
              child:
                  Icon(isSettings ? Icons.close : Icons.settings, size: 30.0),
            ),
          ),
        ),
      ],
    );
  }
}
