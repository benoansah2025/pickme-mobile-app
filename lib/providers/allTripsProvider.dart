import 'dart:convert';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/allTripsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

final _fetcher = BehaviorSubject<AllTripsModel>();
Stream<AllTripsModel> get allTripsStream => _fetcher.stream;
AllTripsModel? allTripsModel;

class AllTripsProvider {
  Future<AllTripsModel> _fetch() async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.trips,
          "userid": userModel?.data?.user?.userid ?? "",
        },
      ),
    );

    // log(httpResult.toString());

    final trips = AllTripsModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
    );

    if (httpResult["ok"]) {
      saveStringShare(
        key: "trips",
        data: json.encode(httpResult["data"]),
      );
    }

    return trips;
  }

  Future<void> get({bool isLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasWorkersInfo = prefs.containsKey("trips");

    if (hasWorkersInfo) {
      final encodeData = prefs.getString("trips")!;
      final model = AllTripsModel.fromJson(
        json: json.decode(encodeData),
        httpMsg: "Offline data",
      );
      allTripsModel = model;
      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await _fetch();
      if (model.ok!) {
        allTripsModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  void clear() {
    allTripsModel = AllTripsModel.fromJson(
      json: null,
      httpMsg: null,
    );
    _fetcher.add(allTripsModel!);
  }
}
