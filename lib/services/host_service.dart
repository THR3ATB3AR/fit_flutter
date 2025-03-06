import 'package:fit_flutter/services/download_plugins/fucking_fast_co.dart';

class HostService {
  dynamic getDownloadPlugin(String url) async {
    switch (url) {
      case String url when url.contains('fuckingfast.co'):
        return await FuckingFastCo().getDownloadInfo(url);
      default:
        return 'UnknownPlugin';
    }
  }
}
