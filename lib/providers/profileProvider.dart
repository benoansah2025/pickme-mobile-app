import 'dart:convert';
import 'dart:developer';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

class ProfileProvider {
  Future<UserModel?> get({String? userId}) async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.auth,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.profile,
          "userid": userId ?? userModel!.data!.user!.userid,
        },
      ),
    );

    log(httpResult.toString());

    if (httpResult["ok"]) {
      SharedPreferences? prefs = await SharedPreferences.getInstance();
      String encodedData = prefs.getString("userDetails")!;
      var decodedData = json.decode(encodedData);
      decodedData["data"]["user"] = httpResult["data"]["data"]["user"];

      if (userId == null) {
        await saveStringShare(key: "userDetails", data: jsonEncode(decodedData));
        userModel = UserModel.fromJson(decodedData);
        return userModel;
      } else {
        return UserModel.fromJson(decodedData);
      }
    }

    return null;
  }
}
