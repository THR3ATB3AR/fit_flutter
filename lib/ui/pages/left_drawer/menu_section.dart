import 'package:fit_flutter/services/repack_service.dart';
import 'package:fit_flutter/services/scraper_service.dart';
import 'package:flutter/material.dart';

class MenuSection extends StatefulWidget {
  const MenuSection({super.key, required this.changeWidget});
  final Function(String) changeWidget;

  @override
  State<MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  final ScraperService _scraperService = ScraperService.instance;
  final RepackService _repackService = RepackService.instance;
  bool _isRescraping = false;
  bool isSettings = false;
  bool isDownloads = false;

  Future<void> _rescrapeAll() async {
    if (_isRescraping) return;

    setState(() {
      _isRescraping = true;
    });

    try {
      // Uruchom wszystkie rescrape'y równolegle za pomocą Future.wait
      
      await Future.wait([
        _scraperService.rescrapeNewRepacks(),
        _scraperService.rescrapePopularRepacks(),
        _scraperService.rescrapeAllRepacksNames(),
        // _repackService.rescrapeUpdatedRepacks(),
      ]);
    } catch (e) {
      print("Błąd podczas rescrape'owania: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wystąpił błąd podczas aktualizacji danych.")),
      );
    } finally {
      setState(() {
        _isRescraping = false;
      });
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
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 4),
                child: ElevatedButton(
                  onPressed: () {
                    _isRescraping ? null : _rescrapeAll()
                    ;
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                  ),
                  child: _isRescraping
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                          ),
                        )
                      : const Icon(Icons.refresh, size: 30,),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 4, top: 4, bottom: 8),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isDownloads = !isDownloads;
                      isSettings = false;
                    });
                    widget.changeWidget(isDownloads ? 'downloads' : 'home');
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
                    const EdgeInsets.only(left: 4, right: 8, top: 4, bottom: 8),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isSettings = !isSettings;
                      isDownloads = false;
                    });
                    widget.changeWidget(isSettings
                        ? 'settings'
                        : 'home');
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
