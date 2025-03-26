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

  Future<void> _rescrapeAll() async {
    if (_scraperService.isRescraping) return;

    setState(() {
      _scraperService.isRescraping = true;
    });

    try {
      await Future.wait([
        _scraperService.rescrapeNewRepacks(),
        _scraperService.rescrapePopularRepacks(),
        _scraperService.rescrapeAllRepacksNames(),
        // _repackService.rescrapeUpdatedRepacks(),
      ]);
      _repackService.saveAllRepackList();
      _repackService.saveNewRepackList();
      _repackService.savePopularRepackList();
    } catch (e) {
      print("Błąd podczas rescrape'owania: $e");
    } finally {
      // _repackService.saveUpdatedRepackList;

      setState(() {
        _scraperService.isRescraping = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _rescrapeAll();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0, top: 8.0),
          child: ElevatedButton(
            onPressed: () {
              widget.changeWidget('failed');
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 21.0),
            ),
            child: const Icon(Icons.error_outline_outlined,
                size: 30.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0, top: 4.0),
          child: ElevatedButton(
            onPressed: () {
              _scraperService.isRescraping ? null : _rescrapeAll();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 21.0),
            ),
            child: _scraperService.isRescraping
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(),
                  )
                : const Icon(
                    Icons.refresh,
                    size: 30,
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0, top: 4.0),
          child: ElevatedButton(
            onPressed: () {
              widget.changeWidget('downloads');
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 21.0),
            ),
            child: const Icon(Icons.downloading_outlined,
                size: 30.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0, top: 4.0),
          child: ElevatedButton(
            onPressed: () {
              widget.changeWidget('settings');
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 21.0),
            ),
            child: const Icon(Icons.settings, size: 30.0),
          ),
        ),
      ],
    );
  }
}
