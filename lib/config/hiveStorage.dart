import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:pickme_mobile/spec/properties.dart';

Future<void> saveHive({@required String? key, @required var data}) async {
  final box = Hive.lazyBox(Properties.hiveBox);
  await box.put(key, data);
  if (kDebugMode) {
    print("Info save in map $key, ${Properties.hiveBox} box");
  }
}

Future<dynamic> getHive(String key) async {
  final box = Hive.lazyBox(Properties.hiveBox);
  return box.get(key);
}

Future<void> deleteHive(String key) async {
  final box = Hive.lazyBox(Properties.hiveBox);
  return box.delete(key);
}
