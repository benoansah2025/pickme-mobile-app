import 'dart:convert';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/walletTransactionsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

final _fetcher = BehaviorSubject<WalletTransactionsModel>();
Stream<WalletTransactionsModel> get walletTransactionsStream => _fetcher.stream;
WalletTransactionsModel? walletTransactionsModel;

class WalletTransationsProvider {
  Future<WalletTransactionsModel> _fetch() async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.walletTransaction,
          "userid": userModel!.data!.user!.userid,
        },
      ),
    );

    final transactions = WalletTransactionsModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
    );

    if (httpResult["ok"]) {
      saveStringShare(
        key: "walletTransactions",
        data: json.encode(httpResult["data"]),
      );
    }

    return transactions;
  }

  Future<void> get({bool isLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasWorkersInfo = prefs.containsKey("walletTransactions");

    if (hasWorkersInfo) {
      final encodeData = prefs.getString("walletTransactions")!;
      final model = WalletTransactionsModel.fromJson(
        json: json.decode(encodeData),
        httpMsg: "Offline data",
      );
      walletTransactionsModel = model;
      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await _fetch();
      if (model.ok!) {
        walletTransactionsModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  void clear() {
    walletTransactionsModel = WalletTransactionsModel.fromJson(
      json: null,
      httpMsg: null,
    );
    _fetcher.add(walletTransactionsModel!);
  }
}
