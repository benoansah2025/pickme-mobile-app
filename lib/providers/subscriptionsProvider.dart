import 'dart:convert';
import 'dart:developer';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/subscriptionsModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

final _fetcher = BehaviorSubject<SubscriptionsModel>();
Stream<SubscriptionsModel> get subscriptionsStream => _fetcher.stream;
SubscriptionsModel? subscriptionsModel;

class SubscriptionsProvider {
  Future<SubscriptionsModel> _fetch() async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.subscriptionPlans,
        },
      ),
    );

    log(httpResult.toString());

    final model = SubscriptionsModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
    );

    if (httpResult["ok"]) {
      saveStringShare(
        key: "subscriptionPlans",
        data: json.encode(httpResult["data"]),
      );
    }

    return model;
  }

  Future<void> get({bool isLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasWorkersInfo = prefs.containsKey("subscriptionPlans");

    if (hasWorkersInfo) {
      final encodeData = prefs.getString("subscriptionPlans")!;
      final model = SubscriptionsModel.fromJson(
        json: json.decode(encodeData),
        httpMsg: "Offline data",
      );
      subscriptionsModel = model;
      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await _fetch();
      if (model.ok!) {
        subscriptionsModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  void clear() {
    subscriptionsModel = SubscriptionsModel.fromJson(
      json: null,
      httpMsg: null,
    );
    _fetcher.add(subscriptionsModel!);
  }
}
