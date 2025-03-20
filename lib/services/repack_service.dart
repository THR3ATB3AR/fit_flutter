import 'package:fit_flutter/data/repack.dart';

class RepackService {

  RepackService._privateConstructor();
  static final RepackService _instance = RepackService._privateConstructor();
  static RepackService get instance => _instance;

  late List<Repack> newRepacks;
  late List<Repack> popularRepacks;
  late List<Repack> updatedRepacks;
  late Map<String, String> allRepacksNames;

  
}
