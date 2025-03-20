import 'package:fit_flutter/data/download_info.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

class FuckingFastCo {
  Future<DownloadInfo> getDownloadInfo(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 404) {
      throw Exception('File not found');
    }

    dom.Document document = parser.parse(response.body);

    String? fileName =
        document.querySelector('meta[name="title"]')?.attributes['content'];
    if (fileName != null) {
      fileName = fileName.trim();
    } else {
      fileName = 'unknown';
    }

    final regex = RegExp(r'window\.open\("https?://[^\"]+');
    final match = regex.firstMatch(response.body);
    if (match == null) {
      throw Exception('Download link not found');
    }

    String dllink = match.group(0)!.replaceFirst('window.open("', '');

    try {
      final fid = url.split('/').last;
      final serversideDlStartedLink = '/f/$fid/dl';
      final brcResponse = await http.post(Uri.parse(serversideDlStartedLink));
      if (brcResponse.statusCode != 200) {
        throw Exception('Failed to start download on server side');
      }
    } catch (e) {
      // print(e);
      // print('chuj');
    }

    return DownloadInfo(downloadLink: dllink, fileName: fileName);
  }
}
