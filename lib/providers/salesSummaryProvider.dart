import 'dart:convert';
import 'dart:developer';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/salesSummaryModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

final _fetcher = BehaviorSubject<SalesSummaryModel>();
Stream<SalesSummaryModel> get salesSummaryStream => _fetcher.stream;
SalesSummaryModel? salesSummaryModel;

class SalesSummaryProvider {
  Future<SalesSummaryModel> _fetch() async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.salesSummary,
          "userid": userModel?.data?.user?.userid ?? "",
        },
      ),
    );

    log(httpResult.toString());

    final trips = SalesSummaryModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
    );

    if (httpResult["ok"]) {
      saveStringShare(
        key: "salesSummary",
        data: json.encode(httpResult["data"]),
      );
    }

    return trips;
  }

  Future<void> get({bool isLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasWorkersInfo = prefs.containsKey("salesSummary");

    if (hasWorkersInfo) {
      final encodeData = prefs.getString("salesSummary")!;
      final model = SalesSummaryModel.fromJson(
        json: json.decode(encodeData),
        httpMsg: "Offline data",
      );
      salesSummaryModel = model;
      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await _fetch();
      if (model.ok!) {
        salesSummaryModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  void clear() {
    salesSummaryModel = SalesSummaryModel.fromJson(
      json: null,
      httpMsg: null,
    );
    _fetcher.add(salesSummaryModel!);
  }
}
