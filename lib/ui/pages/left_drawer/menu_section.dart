import 'package:fit_flutter/data_classes/scrape_status.dart';
import 'package:fit_flutter/services/scraper_service.dart';
import 'package:flutter/material.dart';

class MenuSection extends StatefulWidget {
  MenuSection(
      {super.key, required this.changeWidget, required this.scrapeSync});
  final Function(String) changeWidget;

  final Function scrapeSync;

  @override
  _MenuSectionState createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  bool isSettings = false;
  bool isDownloads = false;
  ScrapeStatus scrapeStatus = ScrapeStatus.notStarted;
  final scraperService = ScraperService.instance;

  Future<void> scrapeEverything() async {
    var a = await scraperService.scrapeEverything();
    setState(() {
      scrapeStatus = a;
    });
  }

  Future<void> scrapesync() async {
    switch (scrapeStatus) {
      case ScrapeStatus.notStarted:
        setState(() {
          scrapeStatus = ScrapeStatus.scraping;
        });
        await scrapeEverything();
      case ScrapeStatus.scraping:

      case ScrapeStatus.finished:
        scrapeStatus=ScrapeStatus.notStarted;
        widget.scrapeSync();
      case ScrapeStatus.error:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: ElevatedButton(
                  onPressed: () {
                    scrapesync();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                  ),
                    child: scrapeStatus == ScrapeStatus.scraping
                      ? CircularProgressIndicator()
                      : Icon(
                        scrapeStatus == ScrapeStatus.notStarted ? Icons.cloud_download_outlined : scrapeStatus == ScrapeStatus.finished ? Icons.sync : Icons.sync_problem_outlined,
                        size: 30.0),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 4, bottom: 8),
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
                padding: const EdgeInsets.only(left: 4, right: 8, bottom: 8),
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
                  child: Icon(isSettings ? Icons.close : Icons.settings,
                      size: 30.0),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
