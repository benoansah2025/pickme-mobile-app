import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

//saving
saveBoolShare({@required String? key, @required var data}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(key!, data);
}

saveStringShare({@required String? key, @required var data}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key!, data);
}

//getting
Future<bool> getShareAuthData() async {
  bool ret;
  SharedPreferences? prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("auth")) {
    ret = prefs.getBool("auth")!;
  } else {
    saveBoolShare(key: "auth", data: false);
    ret = prefs.getBool("auth")!;
  }
  return ret;
}

Future<String> getShareUserTypeData() async {
  String? data;
  SharedPreferences? prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("userType")) {
    data = prefs.getString("userType")!;
  } else {
    data = null;
  }
  return data!;
}

//deleting
Future<void> deleteShareUserData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(key)) {
    Future<bool> delete = prefs.remove(key);
    delete.whenComplete(() {
      if (kDebugMode) {
        print("Deleted $key : true");
      }
    });
  }
}
