import 'package:flutter/foundation.dart';

class CancelReasonsModel {
  bool? ok;
  List<CancelReasonData>? data;
  String? msg;

  CancelReasonsModel({this.ok, this.data, this.msg});

  CancelReasonsModel.fromJson({
    @required Map<String, dynamic>? json,
    @required String? httpMsg,
  }) {
    if (json != null) {
      ok = json['ok'];
      if (json['data'] != null) {
        data = <CancelReasonData>[];
        json['data'].forEach((v) {
          data!.add(new CancelReasonData.fromJson(v));
        });
      }
    } else {
      ok = false;
      msg = httpMsg;
      data = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ok'] = ok;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CancelReasonData {
  int? id;
  String? title;

  CancelReasonData({this.id, this.title});

  CancelReasonData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    return data;
  }
}
