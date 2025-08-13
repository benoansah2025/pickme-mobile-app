import 'dart:convert';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/models/walletBalanceModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

final _fetcher = BehaviorSubject<WalletBalanceModel>();
Stream<WalletBalanceModel> get walletBalanceStream => _fetcher.stream;
WalletBalanceModel? walletBalanceModel;

class WalletBalanceProvider {
  Future<WalletBalanceModel> _fetch() async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.walletBalance,
          "userid": userModel!.data!.user!.userid,
        },
      ),
    );

    final walletBalance = WalletBalanceModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
    );

    if (httpResult["ok"]) {
      saveStringShare(
        key: "walletBalance",
        data: json.encode(httpResult["data"]),
      );
    }

    return walletBalance;
  }

  Future<void> get({bool isLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasWorkersInfo = prefs.containsKey("walletBalance");

    if (hasWorkersInfo) {
      final encodeData = prefs.getString("walletBalance")!;
      final model = WalletBalanceModel.fromJson(
        json: json.decode(encodeData),
        httpMsg: "Offline data",
      );
      walletBalanceModel = model;
      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await _fetch();
      if (model.ok!) {
        walletBalanceModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  void clear() {
    walletBalanceModel = WalletBalanceModel.fromJson(
      json: null,
      httpMsg: null,
    );
    _fetcher.add(walletBalanceModel!);
  }
}
