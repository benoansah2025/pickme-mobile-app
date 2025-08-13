import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/mapFunction.dart';
import 'package:pickme_mobile/models/geofencesModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

final _fetcher = BehaviorSubject<GeofencesModel>();
Stream<GeofencesModel> get geofencesStream => _fetcher.stream;
GeofencesModel? geofencesModel;

class GeofencesProvider {
  Future<GeofencesModel> _fetch() async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.geofences,
        },
      ),
    );

    // log(httpResult.toString());

    final geofences = GeofencesModel.fromJson(httpResult["data"]);

    if (httpResult["ok"]) {
      saveStringShare(
        key: "geofences",
        data: json.encode(httpResult["data"]),
      );
    }

    return geofences;
  }

  Future<void> get({bool isLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasWorkersInfo = prefs.containsKey("geofences");

    if (hasWorkersInfo) {
      final encodeData = prefs.getString("geofences")!;
      final model = GeofencesModel.fromJson(json.decode(encodeData));
      geofencesModel = model;
      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await _fetch();
      if (model.ok!) {
        geofencesModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  GeofencesData? getUserCurrentGeoFenceData(LatLng latLng) {
    final geofences = geofencesModel!.data!;
    for (final geofence in geofences) {
      final coordinates = geofence.coordinates!;
      final isInside = isPointInPolygon(
        latLng,
        [for (var cord in coordinates) LatLng(cord.lat!, cord.lng!)],
      );
      if (isInside) {
        return geofence;
      }
    }
    return null;
  }
}
