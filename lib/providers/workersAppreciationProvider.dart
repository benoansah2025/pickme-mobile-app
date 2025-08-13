import 'dart:convert';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/workersAppreciationModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';
import '../config/sharePreference.dart';

final _fetcher = BehaviorSubject<WorkersAppreciationModel>();
Stream<WorkersAppreciationModel> get workersAppreciationStream => _fetcher.stream;
WorkersAppreciationModel? workersAppreciationModel;

class WorkersAppreciationProvider {
  Future<WorkersAppreciationModel> _fetch() async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.workerAppreciation,
        },
      ),
    );

    final workerAppreciation = WorkersAppreciationModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
    );

    if (httpResult["ok"]) {
      saveStringShare(
        key: "workerAppreciation",
        data: json.encode(httpResult["data"]),
      );
    }

    return workerAppreciation;
  }

  Future<void> get({bool isLoad = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasWorkersInfo = prefs.containsKey("workerAppreciation");

    if (hasWorkersInfo) {
      final encodeData = prefs.getString("workerAppreciation")!;
      final model = WorkersAppreciationModel.fromJson(
        json: json.decode(encodeData),
        httpMsg: "Offline data",
      );
      workersAppreciationModel = model;

      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await _fetch();
      if (model.ok!) {
        workersAppreciationModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  void clear() {
    workersAppreciationModel = WorkersAppreciationModel.fromJson(
      json: null,
      httpMsg: null,
    );
    _fetcher.add(workersAppreciationModel!);
  }
}
