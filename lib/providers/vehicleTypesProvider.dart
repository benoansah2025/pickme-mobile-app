import 'dart:convert';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/vehicleTypesModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

final _fetcher = BehaviorSubject<VehicleTypesModel>();
Stream<VehicleTypesModel> get vehicleTypesStream => _fetcher.stream;
VehicleTypesModel? vehicleTypesModel;

class VehicleTypesProvider {
  Future<VehicleTypesModel> _fetch() async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.vehicleTypes,
        },
      ),
    );

    // log(httpResult.toString());

    final vehicleTypes = VehicleTypesModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
    );

    if (httpResult["ok"]) {
      saveStringShare(
        key: "vehicleTypes",
        data: json.encode(httpResult["data"]),
      );
    }

    return vehicleTypes;
  }

  Future<void> get({bool isLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasWorkersInfo = prefs.containsKey("vehicleTypes");

    if (hasWorkersInfo) {
      final encodeData = prefs.getString("vehicleTypes")!;
      final model = VehicleTypesModel.fromJson(
        json: json.decode(encodeData),
        httpMsg: "Offline data",
      );
      vehicleTypesModel = model;
      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await _fetch();
      if (model.ok!) {
        vehicleTypesModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  void clear() {
    vehicleTypesModel = VehicleTypesModel.fromJson(
      json: null,
      httpMsg: null,
    );
    _fetcher.add(vehicleTypesModel!);
  }
}
