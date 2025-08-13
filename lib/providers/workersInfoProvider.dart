import 'dart:convert';
import 'dart:developer';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:rxdart/rxdart.dart';

import '../config/http/httpChecker.dart';
import '../config/http/httpRequester.dart';

final _fetcher = BehaviorSubject<WorkersInfoModel>();
Stream<WorkersInfoModel> get workersInfoStream => _fetcher.stream;
WorkersInfoModel? workersInfoModel;

class WorkersInfoProvider {
  Future<WorkersInfoModel> fetch({String? userId}) async {
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.workersInfo,
          "userid": userId ?? userModel?.data?.user?.userid ?? "",
        },
      ),
    );

    // log(httpResult.toString());

    final workersInfo = WorkersInfoModel.fromJson(
      json: httpResult["data"],
      httpMsg: httpResult["ok"] ? httpResult["data"]["msg"] : httpResult["error"],
    );

    if (httpResult["ok"] && userId == null) {
      await saveHive(key: "workersInfo", data: json.encode(httpResult["data"]));

      // check if worker info is save in user collection else save it
      try {
        if (workersInfo.data!.services!.isNotEmpty && userId == null) {
          Map<String, dynamic> reqBody = {
            "userId": userModel!.data!.user!.userid,
            "services": workersInfo.data!.services,
          };
          await FirebaseService().saveWorkerServices(reqBody, isNewUser: true);
        }
      } catch (error, stackTrace) {
        FirebaseService().reportErrors(error.toString(), stackTrace.toString());
      }
    } 

    return workersInfo;
  }

  Future<void> get({bool isLoad = false}) async {
    final encodeData = await getHive("workersInfo");
    log( "workersInfoProvider: $encodeData");

    if (encodeData != null) {
      final model = WorkersInfoModel.fromJson(json: json.decode(encodeData), httpMsg: "Offline data");
      workersInfoModel = model;
      _fetcher.add(model);
    }

    if (isLoad) {
      final model = await fetch();
      if (model.ok!) {
        workersInfoModel = model;
        _fetcher.add(model);
      } else {
        await get(isLoad: false);
      }
    }
  }

  void clear() {
    workersInfoModel = WorkersInfoModel.fromJson(
      json: null,
      httpMsg: null,
    );
    _fetcher.add(workersInfoModel!);
  }
}
