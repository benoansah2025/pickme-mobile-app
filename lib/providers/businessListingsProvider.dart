import 'dart:convert';
import 'dart:developer';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/businessListingsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

final _fetcher = BehaviorSubject<BusinessListingsModel>();
Stream<BusinessListingsModel> get businessListingsStream => _fetcher.stream;
BusinessListingsModel? busniessListingsModel;

class BusinesslistingsProvider {
  Future<BusinessListingsModel> _fetch() async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.myBusinessListings,
          "userid": userModel?.data?.user?.userid ?? "",
        },
      ),
    );

    log(httpResult.toString());

    final model = BusinessListingsModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
    );

    if (httpResult["ok"]) {
      saveStringShare(
        key: "myBusinessListings",
        data: json.encode(httpResult["data"]),
      );
    }

    return model;
  }

  Future<void> get({bool isLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasWorkersInfo = prefs.containsKey("myBusinessListings");

    if (hasWorkersInfo) {
      final encodeData = prefs.getString("myBusinessListings")!;
      final model = BusinessListingsModel.fromJson(
        json: json.decode(encodeData),
        httpMsg: "Offline data",
      );
      busniessListingsModel = model;
      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await _fetch();
      if (model.ok!) {
        busniessListingsModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  void clear() {
    busniessListingsModel = BusinessListingsModel.fromJson(
      json: null,
      httpMsg: null,
    );
    _fetcher.add(busniessListingsModel!);
  }
}
