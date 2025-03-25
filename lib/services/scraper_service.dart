import 'dart:io';
import 'package:fit_flutter/data/repack.dart';
import 'package:fit_flutter/services/repack_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';

class ScraperService {
  ScraperService._privateConstructor();
  static final ScraperService _instance = ScraperService._privateConstructor();
  static ScraperService get instance => _instance;

  bool isRescraping = false;
  final RepackService _repackService = RepackService.instance;
  final ValueNotifier<double> loadingProgress = ValueNotifier<double>(0.0);

  Future<void> rescrapeNewRepacks() async {
    _repackService.newRepacks = await scrapeNewRepacks(onProgress: (i, e) {});
  }

  Future<void> rescrapePopularRepacks() async {
    _repackService.popularRepacks =
        (await scrapePopularRepacks(onProgress: (i, e) {}));
  }

  Future<void> rescrapeAllRepacksNames() async {
    _repackService.allRepacksNames =
        await scrapeAllRepacksNames(onProgress: (i, e) {});
  }


  Future<bool> checkImageUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }


  Future<Repack> deleteInvalidScreenshots(Repack repack) async {
    final List<String> validScreenshots = [];
    final bool isCoverValid = await checkImageUrl(repack.cover);
    if (isCoverValid) {
      repack.cover = repack.cover;
    } else {
      repack.cover = 'https://github.com/THR3ATB3AR/fit_flutter/blob/repack-library/images/noposter.png?raw=true';
    }
    for (int i = 0; i < repack.screenshots.length; i++) {
      final bool isScreenshotValid = await checkImageUrl(repack.screenshots[i]);
      if (isScreenshotValid) {
        validScreenshots.add(repack.screenshots[i]);
      }
    }
    repack.screenshots = validScreenshots;
    return repack;
  }

  Future<List<Repack>> scrapeEveryRepack({required Function(int, int) onProgress}) async {
    List<Repack> repacks = [];
    for (var entry in _repackService.allRepacksNames.entries.take(100)) {
      try {
        final repack = await scrapeRepackFromSearch(entry.value);
        repacks.add(repack);
      } catch (e) {
        print('Failed to scrape repack: ${entry.key}, error: $e');
      }
      loadingProgress.value = repacks.length / _repackService.allRepacksNames.length;
      onProgress(repacks.length, _repackService.allRepacksNames.length);
    }
    return repacks;
  }


  Future<void> scrapeMissingRepacks() async {
  final everyRepackUrls = _repackService.everyRepack.map((repack) => repack.url).toSet();
  final allRepackUrls = _repackService.allRepacksNames.values.toSet();
  final missingRepackUrls = allRepackUrls.difference(everyRepackUrls);
  var d =0;
  for (var url in missingRepackUrls) {
    try {
      final repack = await scrapeRepackFromSearch(url);
      print('Scraped repack: ${repack.title} $d / ${missingRepackUrls.length - _repackService.failedRepacks.length} ${d / (missingRepackUrls.length - _repackService.failedRepacks.length) * 100}%'); // Debugowanie
      d++;
      _repackService.everyRepack.add(repack);
      await _repackService.saveSingleEveryRepack(repack); // Zapisz do bazy danych
      _repackService.notifyListeners(); // Emituj zmiany przez strumień
    } catch (e) {
      _repackService.failedRepacks[url] = _repackService.allRepacksNames.entries.firstWhere((element) => element.value == url).key;
      _repackService.saveFailedRepack(_repackService.failedRepacks[url]!, url);
      print('Failed to scrape repack: $url, error: $e');
    }
  }
  _repackService.deleteFailedRepacksFromAllRepackNames();
  _repackService.everyRepack.sort((a,b) => a.title.compareTo(b.title));
  print('scrapeMissingRepacks finished'); // Debugowanie
}

  Future<Map<String, String>> scrapeAllRepacksNames(
      {required Function(int, int) onProgress}) async {
    Map<String, String> repacks = {};
    final url = Uri.parse('https://fitgirl-repacks.site/all-my-repacks-a-z/');
    final response = await _fetchWithRetry(url);
    dom.Document html = dom.Document.html(response.body);
    final pages = html
        .querySelectorAll('ul.lcp_paginator > li > a:not([class])')
        .map((element) => int.parse(element.attributes['title']!))
        .toList();

    for (int i = 1; i < pages[pages.length - 1] + 1; i++) {
      final url = Uri.parse(
          'https://fitgirl-repacks.site/all-my-repacks-a-z/?lcp_page0=$i#lcp_instance_0/');
      final response = await _fetchWithRetry(url);
      dom.Document html = dom.Document.html(response.body);

      final titles =
          html.querySelectorAll('ul.lcp_catlist > li > a').map((element) {
        final title = element.innerHtml.trim();
        final index = title.indexOf(RegExp(r'[–+]'));
        return index != -1 ? title.substring(0, index).trim() : title;
      }).toList();
      final links = html
          .querySelectorAll('ul.lcp_catlist > li > a')
          .map((element) => element.attributes['href']!.trim())
          .toList();

      for (int i = 0; i < titles.length; i++) {
        repacks[titles[i]] = links[i];
      }
      // print(i);
      loadingProgress.value = i / pages[pages.length - 1];
      onProgress(i, pages[pages.length - 1]);
    }

    return repacks;
  }

  Future<Repack> scrapeRepackFromSearch(String search) async {
    final url = Uri.parse(search);
    final response = await _fetchWithRetry(url);
    dom.Document html = dom.Document.html(response.body);
    final article = html.querySelector('article.category-lossless-repack');
    return await deleteInvalidScreenshots(scrapeRepack(article!, url: search));
  }

  Future<List<Repack>> scrapeNewRepacks(
      {required Function(int, int) onProgress}) async {
    int pages = 2;
    List<Repack> repacks = [];
    for (int i = 0; i < pages; i++) {
      try {
        final url = Uri.parse(
            'https://fitgirl-repacks.site/category/lossless-repack/page/${i + 1}/');
        final response = await _fetchWithRetry(url);
        dom.Document html = dom.Document.html(response.body);
        html
            .querySelectorAll('article.category-lossless-repack')
            .forEach((article) async {
          repacks.add(await deleteInvalidScreenshots(scrapeRepack(article)));
        });
        loadingProgress.value = i / pages;
        onProgress(i, pages - 1);
      } catch (e) {
        print(e);
        rethrow;
      }
    }
    return repacks;
  }

  Future<List<Repack>> scrapePopularRepacks(
      {required Function(int, int) onProgress}) async {
    List<Repack> repacks = [];
    final url = Uri.parse('https://fitgirl-repacks.site/popular-repacks/');
    final response = await _fetchWithRetry(url);
    dom.Document html = dom.Document.html(response.body);
    final pages = html
        .querySelectorAll(
            'article > div.entry-content > div.jetpack_top_posts_widget > div.widgets-grid-layout > div.widget-grid-view-image > a')
        .map((element) => element.attributes['href']!.trim())
        .toList();

    for (int i = 0; i < 20; i++) {
      try {
        final url = Uri.parse(pages[i]);
        final response = await _fetchWithRetry(url);
        dom.Document html = dom.Document.html(response.body);

        html
            .querySelectorAll('article.category-lossless-repack')
            .forEach((article) async {
          repacks.add(await deleteInvalidScreenshots(scrapeRepack(article, url: url.toString())));
        });
        loadingProgress.value = i / 20;
        onProgress(i, 20);
      } catch (e) {
        print(e);
      }
    }

    return repacks;
  }


  Repack scrapeRepack(dom.Element article, {String url = ''}) {
    Repack repack;

    dom.Document html = dom.Document.html(article.outerHtml);

    final List<dom.Element> h3Elements =
        html.querySelectorAll('div.entry-content h3');
    List<Map<String, String>> repackSections = [];

    if (url == '') {
      url = html.querySelector('header > h1 > a')!.attributes['href']!.trim();    
    }

    for (int i = 0; i < h3Elements.length; i++) {
      final dom.Element h3Element = h3Elements[i];
      h3Element.querySelector('span')?.remove(); // Remove span if it exists
      final String h3Text = h3Element.text.trim();
      final StringBuffer sectionContent = StringBuffer();

      // Collect all elements under the current h3 until the next h3
      dom.Element? nextSibling = h3Element.nextElementSibling;
      while (nextSibling != null && nextSibling.localName != 'h3') {
        sectionContent.write(nextSibling.outerHtml);
        nextSibling = nextSibling.nextElementSibling;
      }

      repackSections.add({
        'title': h3Text,
        'content': sectionContent.toString(),
      });
    }

    final String title = repackSections[0]['title'] ?? '';
    final DateTime releaseDate = DateFormat('dd/MM/yyyy').parse(html
        .querySelector(
            'header.entry-header > div.entry-meta > span.entry-date > a > time')!
        .text
        .trim());
    final cover = repackSections[0]['content']!.contains('<img')
        ? repackSections[0]['content']!.substring(
            repackSections[0]['content']!.indexOf('src="') + 5,
            repackSections[0]['content']!.indexOf(
                '"', repackSections[0]['content']!.indexOf('src="') + 5))
        : '';
    final dom.Element? infoElement = html.querySelector('div.entry-content p');
    String genres = '';
    String company = '';
    String language = '';
    String originalSize = '';
    String repackSize = '';

    Map<String, String> infoMap =
        infoElement!.innerHtml.split('<br>\n').sublist(1).map((element) {
      final parts = element.split(':');
      final key = parts[0].trim().toLowerCase();
      final value = parts[1]
          .replaceAll('<strong>', '')
          .replaceAll('</strong>', '')
          .trim();
      return MapEntry(key, value);
    }).fold({}, (previousValue, element) {
      previousValue[element.key] = element.value;
      return previousValue;
    });
    genres = infoMap['genres/tags'] ?? infoMap['genres'] ?? 'N/A';
    language = infoMap['languages'] ?? infoMap['language'] ?? 'N/A';
    company = infoMap['companies'] ?? infoMap['company'] ?? 'N/A';
    originalSize = infoMap['original size'] ?? 'N/A';
    repackSize = infoMap['repack size'] ?? 'N/A';

    Map<String, List<Map<String, String>>> sectionDownloadLinks = {};
    for (var section in repackSections) {
      if (section['title']!.toLowerCase().contains('download')) {
        final links = dom.Document.html(section['content']!)
            .querySelectorAll('a[href]')
            .map((element) => {
                  'hostName': element.text.trim(),
                  'url': element.attributes['href']!.trim()
                })
            .where((link) =>
                // (link['url']!.startsWith('https://paste.fitgirl-repacks.site') ||
                (link['url']!.startsWith('magnet:')) &&
                link['hostName']!.toLowerCase() != '.torrent file only')
            .toList();
        if (links.isNotEmpty) {
          sectionDownloadLinks[section['title']!] = links;
        }
      }
      final fuckingFastLinks = dom.Document.html(section['content']!)
          .querySelectorAll('a[href]')
          .map((element) => element.attributes['href']!.trim())
          .where((url) => url.startsWith('https://fuckingfast'))
          .toList();
      if (fuckingFastLinks.isNotEmpty) {
        final ddd = {
          'hostName': 'FuckingFast',
          'url': fuckingFastLinks.join(', ')
        };
        sectionDownloadLinks['FuckingFast'] = [ddd];
      }
    }

    final String repackFeatures = repackSections
        .where((section) =>
            section['title']!.toLowerCase().contains('repack features'))
        .map((section) => section['content'])
        .expand((content) {
          final document = dom.Document.html(content!);
          document.querySelectorAll('div.su-spoiler').forEach((element) {
            element.remove();
          });
          return document
              .querySelectorAll('li')
              .map((element) => '\u2022${element.innerHtml.trim()}');
        })
        .toList()
        .join('\n');

    final descriptionHelper =
        dom.Document.html('${repackSections.expand((section) {
      final document = dom.Document.html(section['content']!);
      return document
          .querySelectorAll('div.su-spoiler')
          .map((element) => element.innerHtml.trim().split('</div>'))
          .where((list) =>
              list.isNotEmpty &&
              list[0].toLowerCase().contains('game description'));
    }).toList()[0][1]}</div>');
    final description = descriptionHelper
        .querySelector('div')!
        .innerHtml
        .trim()
        .replaceAll('<p>', '')
        .replaceAll('</p>', '\n')
        .replaceAll('<b>', '')
        .replaceAll('</b>', '')
        .replaceAll('<ul>', '')
        .replaceAll('</ul>', '')
        .replaceAll('<li>', '\u2022')
        .replaceAll('</li>', '')
        .replaceAll('<br>', '');

    final List<String> screenshots = repackSections
        .where((section) =>
            section['title']!.toLowerCase().contains('screenshots'))
        .map((section) => section['content']!)
        .expand((content) {
      return dom.Document.html(content).querySelectorAll('img').map((element) {
        try {
          String src = element.attributes['src']!.trim();
          if (src.endsWith('.240p.jpg')) {
            src = src.substring(0, src.length - '.240p.jpg'.length);
          }
          return src;
        } catch (e) {
          print(e);
          return '';
        }
      });
    }).toList();

    repack = Repack(
        title: title,
        url: url,
        releaseDate: releaseDate,
        cover: cover,
        genres: genres,
        language: language,
        company: company,
        originalSize: originalSize,
        repackSize: repackSize,
        downloadLinks: sectionDownloadLinks,
        repackFeatures: repackFeatures,
        description: description,
        screenshots: screenshots);

    return repack;
  }

  Future<http.Response> _fetchWithRetry(Uri url, {int retries = 3}) async {
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          return response;
        } else {
          throw http.ClientException(
              'Failed to load data: ${response.statusCode}');
        }
      } on http.ClientException {
        if (attempt == retries - 1) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 2));
      } on SocketException {
        if (attempt == retries - 1) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    throw http.ClientException('Failed to load data after $retries attempts');
  }
}
