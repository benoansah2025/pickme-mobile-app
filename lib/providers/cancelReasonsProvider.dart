import 'dart:convert';
import 'dart:developer';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/cancelReasonsModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

final _fetcher = BehaviorSubject<CancelReasonsModel>();
Stream<CancelReasonsModel> get cancelReasonsStream => _fetcher.stream;
CancelReasonsModel? cancelReasonsModel;

class CancelReasonsProvider {
  Future<CancelReasonsModel> _fetch() async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.cancelReasons,
        },
      ),
    );

    log(httpResult.toString());

    final cancelReasons = CancelReasonsModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
    );

    if (httpResult["ok"]) {
      saveStringShare(
        key: "cancelReasons",
        data: json.encode(httpResult["data"]),
      );
    }

    return cancelReasons;
  }

  Future<void> get({bool isLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasWorkersInfo = prefs.containsKey("cancelReasons");

    if (hasWorkersInfo) {
      final encodeData = prefs.getString("cancelReasons")!;
      final model = CancelReasonsModel.fromJson(
        json: json.decode(encodeData),
        httpMsg: "Offline data",
      );
      cancelReasonsModel = model;
      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await _fetch();
      if (model.ok!) {
        cancelReasonsModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  void clear() {
    cancelReasonsModel = CancelReasonsModel.fromJson(
      json: null,
      httpMsg: null,
    );
    _fetcher.add(cancelReasonsModel!);
  }
}
