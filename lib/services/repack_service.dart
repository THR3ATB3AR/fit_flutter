import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fit_flutter/data/repack.dart';
import 'package:path_provider/path_provider.dart';

class RepackService {
  RepackService._privateConstructor();
  static final RepackService _instance = RepackService._privateConstructor();
  static RepackService get instance => _instance;

  final StreamController<void> _controller = StreamController<
      void>.broadcast(); 
  Stream<void> get repacksStream => _controller.stream;

  List<Repack> newRepacks = [];
  List<Repack> popularRepacks = [];
  List<Repack> updatedRepacks = [];
  List<Repack> everyRepack = [];
  Map<String, String> allRepacksNames = {};

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

  Future<void> savePopularRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\popular_repack_list.json');
    final jsonList = popularRepacks.map((repack) => repack.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    _controller.add(null);
  }

  Future<void> saveNewRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\new_repack_list.json');
    final jsonList = newRepacks.map((repack) => repack.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    _controller.add(null);
  }

  Future<void> saveUpdatedRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\updated_repack_list.json');
    final jsonList = updatedRepacks.map((repack) => repack.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    _controller.add(null);
  }

  Future<void> saveAllRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\all_repack_list.json');
    final jsonMap = allRepacksNames.map((key, value) => MapEntry(key, value));
    await file.writeAsString(jsonEncode(jsonMap));
    _controller.add(null);
  }

  Future<void> saveEveryRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\every_repack_list.json');
    final jsonList = everyRepack.map((repack) => repack.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
    _controller.add(null);
  }

  Future<void> loadOldPopularRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\popular_repack_list.json');
    if (await file.exists()) {
      final jsonList = jsonDecode(await file.readAsString()) as List<dynamic>;
      popularRepacks = jsonList
          .map((json) => Repack.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> loadOldNewRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\new_repack_list.json');
    if (await file.exists()) {
      final jsonList = jsonDecode(await file.readAsString()) as List<dynamic>;
      newRepacks = jsonList
          .map((json) => Repack.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> loadOldUpdatedRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\updated_repack_list.json');
    if (await file.exists()) {
      final jsonList = jsonDecode(await file.readAsString()) as List<dynamic>;
      updatedRepacks = jsonList
          .map((json) => Repack.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> loadOldAllRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\all_repack_list.json');
    if (await file.exists()) {
      final jsonMap =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      allRepacksNames =
          jsonMap.map((key, value) => MapEntry(key, value as String));
    }
  }

  Future<void> loadOldEveryRepackList() async {
    final path = await _getAppDataPath();
    final file = File('$path\\every_repack_list.json');
    if (await file.exists()) {
      final jsonList = jsonDecode(await file.readAsString()) as List<dynamic>;
      everyRepack = jsonList
          .map((json) => Repack.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> loadAllData() async {
    await loadOldPopularRepackList();
    await loadOldNewRepackList();
    // await loadOldUpdatedRepackList();
    await loadOldAllRepackList();
    await loadOldEveryRepackList();
    _controller.add(null);
  }
}
