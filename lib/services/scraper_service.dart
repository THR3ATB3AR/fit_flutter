import 'dart:convert';
import 'dart:io';
import 'package:fit_flutter/data_classes/repack.dart';
import 'package:fit_flutter/data_classes/scrape_status.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ScraperService {

  ScraperService._privateConstructor();
  static final ScraperService _instance = ScraperService._privateConstructor();
  static ScraperService get instance => _instance;

  final ValueNotifier<double> popularLoadingProgress =
      ValueNotifier<double>(0.0);
  final ValueNotifier<double> newLoadingProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<double> updatedLoadingProgress =
      ValueNotifier<double>(0.0);
  final ValueNotifier<double> allLoadingProgress = ValueNotifier<double>(0.0);

  List<Repack> popularRepackList = [];
  List<Repack> newRepackList = [];
  List<Repack> updatedRepackList = [];
  Map<String, String> allRepackList = {};

  List<Repack> oldPopularRepackList = [];
  List<Repack> oldNewRepackList = [];
  List<Repack> oldUpdatedRepackList = [];
  Map<String, String> oldAllRepackList = {};

  Future<String> _getAppDataPath() async {
    final appDataDir = await getApplicationSupportDirectory();
    final directory = Directory('${appDataDir.path}\\FitFlutter\\cache');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  Future<bool> _fileExists(String fileName) async {
    final path = await _getAppDataPath();
    final file = File('$path\\$fileName');
    return await file.exists();
  }

  Future<bool> allFilesExist() async {
    final popularExists = await _fileExists('popular_repack_list.json');
    final newExists = await _fileExists('new_repack_list.json');
    // final updatedExists = await _fileExists('updated_repack_list.json');
    final allExists = await _fileExists('all_repack_list.json');

    return popularExists && newExists && allExists;
  }

  Future<void> deleteFiles() async {
    final path = await _getAppDataPath();
    final popularFile = File('$path\\popular_repack_list.json');
    final newFile = File('$path\\new_repack_list.json');
    final updatedFile = File('$path\\updated_repack_list.json');
    final allFile = File('$path\\all_repack_list.json');

    if (await popularFile.exists()) {
      await popularFile.delete();
    }
    if (await newFile.exists()) {
      await newFile.delete();
    }
    if (await updatedFile.exists()) {
      await updatedFile.delete();
    }
    if (await allFile.exists()) {
      await allFile.delete();
    }
  }

  Future<ScrapeStatus> scrapeEverything() async {
    try {
      deleteFiles();
      await scrapeNewRepacks(onProgress: (current, total) {
        newLoadingProgress.value = current / total;
      });

      await scrapePopularRepacks(onProgress: (current, total) {
        popularLoadingProgress.value = current / total;
      });

      // await scrapeUpdatedRepacks(onProgress: (current, total) {
      //   updatedLoadingProgress.value = current / total;
      // });

      await scrapeAllRepacksNames(onProgress: (current, total) {
        allLoadingProgress.value = current / total;
      });

      return ScrapeStatus.finished;
    } catch (e) {
      print('Error during scraping: $e');
      return ScrapeStatus.error;
    }
  }

  Future<void> loadCashedRepacks() async {
    await loadOldNewRepackList();
    await loadOldPopularRepackList();
    await loadOldAllRepackList();
    // await loadOldUpdatedRepackList();
  }

  Future<void> loadOldPopularRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path/popular_repack_list.json');
    if (await file.exists()) {
      final jsonList = jsonDecode(await file.readAsString()) as List<dynamic>;
      oldPopularRepackList = jsonList
          .map((json) => Repack.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> loadOldNewRepackList() async {
  final path = await _getAppDataPath();
  final file = File('$path/new_repack_list.json');
  if (await file.exists()) {
    final jsonList = jsonDecode(await file.readAsString()) as List<dynamic>;
    oldNewRepackList = jsonList.map((json) => Repack.fromJson(json as Map<String, dynamic>)).toList();
  }
}

  Future<void> loadOldUpdatedRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path/updated_repack_list.json');
    if (await file.exists()) {
      final jsonList = jsonDecode(await file.readAsString()) as List<dynamic>;
      oldUpdatedRepackList = jsonList
          .map((json) => Repack.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> loadOldAllRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path/all_repack_list.json');
    if (await file.exists()) {
      final jsonMap =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      oldAllRepackList =
          jsonMap.map((key, value) => MapEntry(key, value as String));
    }
  }

  Future<void> savePopularRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\popular_repack_list.json');
    final jsonList =
        popularRepackList.map((repack) => repack.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<void> saveNewRepackList() async {
  final path = await _getAppDataPath();
  final file = File('$path/new_repack_list.json');
  final jsonList = newRepackList.map((repack) => repack.toJson()).toList();
  await file.writeAsString(jsonEncode(jsonList));
}

  Future<void> saveUpdatedRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\updated_repack_list.json');
    final jsonList =
        updatedRepackList.map((repack) => repack.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<void> saveAllRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\all_repack_list.json');
    final jsonMap = allRepackList.map((key, value) => MapEntry(key, value));
    await file.writeAsString(jsonEncode(jsonMap));
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
    for (int i = 0; i < repack.screenshots.length; i++) {
      final bool isValid = await checkImageUrl(repack.screenshots[i]);
      if (isValid) {
        validScreenshots.add(repack.screenshots[i]);
      }
    }
    repack.screenshots = validScreenshots;
    return repack;
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
      allLoadingProgress.value = i / pages[pages.length - 1];
      onProgress(i, pages[pages.length - 1]);
    }
    allRepackList = repacks;
    saveAllRepackList();
    return repacks;
  }

  Future<Repack> scrapeRepackFromSearch(String search) async {
    final url = Uri.parse(search);
    final response = await _fetchWithRetry(url);
    dom.Document html = dom.Document.html(response.body);
    final article = html.querySelector('article.category-lossless-repack');
    return await deleteInvalidScreenshots(scrapeRepack(article!));
  }

  Future<List<Repack>> scrapeNewRepacks({required Function(int, int) onProgress}) async {
  int pages = 2;
  List<Repack> repacks = [];
  for (int i = 0; i < pages; i++) {
    try {
      final url = Uri.parse('https://fitgirl-repacks.site/category/lossless-repack/page/${i + 1}/');
      final response = await _fetchWithRetry(url);
      dom.Document html = dom.Document.html(response.body);
      final articles = html.querySelectorAll('article.category-lossless-repack');
      final futures = articles.map((article) async {
        final repack = await deleteInvalidScreenshots(scrapeRepack(article));
        repacks.add(repack);
      }).toList();
      await Future.wait(futures);
      newLoadingProgress.value = i / pages;
      onProgress(i, pages - 1);
    } catch (e) {
      print(e);
    }
  }
  newRepackList = repacks;
  await saveNewRepackList();
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
          repacks.add(await deleteInvalidScreenshots(scrapeRepack(article)));
        });
        popularLoadingProgress.value = i / 20;
        onProgress(i, 20);
      } catch (e) {
        print(e);
      }
    }
    popularRepackList = repacks;
    savePopularRepackList();
    return repacks;
  }

  Future<List<Repack>> scrapeUpdatedRepacks(
      {required Function(int, int) onProgress}) async {
    List<Repack> repacks = [];
    final url =
        Uri.parse('https://fitgirl-repacks.site/category/updates-digest/');
    final response = await _fetchWithRetry(url);
    dom.Document html = dom.Document.html(response.body);

    final pages1 = html
        .querySelectorAll('article > div.entry-content ')
        .map((element) => element.outerHtml.trim())
        .toList();
    print(pages1);

    final pages = html
        .querySelectorAll(
            'article > div.entry-content > div.su-spoiler > div.su-spoiler-content > a')
        .where((element) => element.innerHtml.trim() == 'Repack page')
        .map((element) => element.attributes['href']!.trim())
        .toList();

    for (int i = 0; i < 20; i++) {
      try {
        final url = Uri.parse(pages[i]);
        final response = await _fetchWithRetry(url);
        dom.Document html = dom.Document.html(response.body);
        final article = html.querySelector('article');
        repacks.add(await deleteInvalidScreenshots(scrapeRepack(article!)));
        updatedLoadingProgress.value = i / 20;
        onProgress(i, 20);
      } catch (e) {
        print(e);
      }
    }
    updatedRepackList = repacks;
    saveUpdatedRepackList();
    return repacks;
  }

  Repack scrapeRepack(dom.Element article) {
    Repack repack;

    dom.Document html = dom.Document.html(article.outerHtml);

    final List<dom.Element> h3Elements =
        html.querySelectorAll('div.entry-content h3');
    List<Map<String, String>> repackSections = [];

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
    // print(releaseDate);
    final cover = repackSections[0]['content']!.contains('<img')
        ? repackSections[0]['content']!.substring(
            repackSections[0]['content']!.indexOf('src="') + 5,
            repackSections[0]['content']!.indexOf(
                '"', repackSections[0]['content']!.indexOf('src="') + 5))
        : '';
    // print(cover);
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
    // print(infoMap);
    genres = infoMap['genres/tags'] ?? infoMap['genres'] ?? 'N/A';
    language = infoMap['languages'] ?? infoMap['language'] ?? 'N/A';
    company = infoMap['companies'] ?? infoMap['company'] ?? 'N/A';
    originalSize = infoMap['original size'] ?? 'N/A';
    repackSize = infoMap['repack size'] ?? 'N/A';

    // Map<String, List<Map<String, dynamic>>> sectionDownloadLinks = {};
    // for (var section in repackSections) {
    //   if (section['title']!.toLowerCase().contains('download')) {
    //   final links = dom.Document.html(section['content']!)
    //     .querySelectorAll('a[href]')
    //     .map((element) => {
    //         'hostName': element.text.trim(),
    //         'url': element.attributes['href']!.trim()
    //       })
    //     .where((link) =>
    //       // (link['url']!.startsWith('https://paste.fitgirl-repacks.site') ||
    //       (link['url']!.startsWith('magnet:')) &&
    //       link['hostName']!.toLowerCase() != '.torrent file only')
    //     .toList();
    //   sectionDownloadLinks[section['title']!] = links;
    //   print(sectionDownloadLinks);
    //   }
    // }

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
        String src = element.attributes['src']!.trim();
        if (src.endsWith('.240p.jpg')) {
          src = src.substring(0, src.length - '.240p.jpg'.length);
        }
        return src;
      });
    }).toList();

    repack = Repack(
        title: title,
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
