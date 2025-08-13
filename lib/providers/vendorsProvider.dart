import 'dart:convert';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/vendorsModel.dart';
import 'package:pickme_mobile/providers/locationProdiver.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

final _fetcher = BehaviorSubject<VendorsModel>();
Stream<VendorsModel> get vendorsStream => _fetcher.stream;
VendorsModel? vendorsModel;

class VendorsProvider {
  Future<VendorsModel> _fetch() async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.vendors,
        },
      ),
    );

    final vendors = VendorsModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
    );

    if (httpResult["ok"]) {
      saveStringShare(
        key: "vendors",
        data: json.encode(httpResult["data"]),
      );
    }

    return vendors;
  }

  Future<void> get({bool isLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasWorkersInfo = prefs.containsKey("vendors");

    if (hasWorkersInfo) {
      final encodeData = prefs.getString("vendors")!;
      final model = VendorsModel.fromJson(
        json: json.decode(encodeData),
        httpMsg: "Offline data",
      );
      model.sortVendorsByProximity(cachedLocation?.latitude ?? 0, cachedLocation?.longitude ?? 0);
      vendorsModel = model;

      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await _fetch();
      if (model.ok!) {
        model.sortVendorsByProximity(cachedLocation?.latitude ?? 0, cachedLocation?.longitude ?? 0);
        vendorsModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  void clear() {
    vendorsModel = VendorsModel.fromJson(
      json: null,
      httpMsg: null,
    );
    _fetcher.add(vendorsModel!);
  }
}
