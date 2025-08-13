import 'dart:convert';
import 'dart:developer';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/investmentModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

final _fetcher = BehaviorSubject<InvestmentModel>();
Stream<InvestmentModel> get investmentStream => _fetcher.stream;
InvestmentModel? investmentModel;

class InvestmentProvider {
  Future<InvestmentModel> _fetch() async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.investment,
        },
      ),
    );

    log(httpResult.toString());

    final model = InvestmentModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
    );

    if (httpResult["ok"]) {
      saveStringShare(
        key: "investment",
        data: json.encode(httpResult["data"]),
      );
    }

    return model;
  }

  Future<void> get({bool isLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasWorkersInfo = prefs.containsKey("investment");

    if (hasWorkersInfo) {
      final encodeData = prefs.getString("investment")!;
      final model = InvestmentModel.fromJson(
        json: json.decode(encodeData),
        httpMsg: "Offline data",
      );
      investmentModel = model;
      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await _fetch();
      if (model.ok!) {
        investmentModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  void clear() {
    investmentModel = InvestmentModel.fromJson(
      json: null,
      httpMsg: null,
    );
    _fetcher.add(investmentModel!);
  }
}
