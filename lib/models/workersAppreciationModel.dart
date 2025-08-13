import 'package:flutter/foundation.dart';

class WorkersAppreciationModel {
  bool? ok;
  List<Data>? data;

  WorkersAppreciationModel({this.ok, this.data});

  WorkersAppreciationModel.fromJson({
    @required Map<String, dynamic>? json,
    @required String? httpMsg,
  }) {
    if (json != null) {
      ok = json['ok'];
      if (json['data'] != null) {
        data = <Data>[];
        json['data'].forEach((v) {
          data!.add(new Data.fromJson(v));
        });
      }
    } else {
      ok = false;
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

class Data {
  String? userid;
  dynamic workerName;
  String? serviceName;
  String? description;
  dynamic rating;
  String? dateCreated;
  String? workerImage;

  Data({
    this.userid,
    this.workerName,
    this.serviceName,
    this.description,
    this.rating,
    this.dateCreated,
    this.workerImage,
  });

  Data.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    workerName = json['workerName'] ?? "N/A";
    serviceName = json['serviceName'] ?? "N/A";
    description = json['description'] ?? "N/A";
    rating = json['rating'] ?? "0";
    dateCreated = json['dateCreated'];
    workerImage = json['workerImage'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userid'] = userid;
    data['workerName'] = workerName;
    data['serviceName'] = serviceName;
    data['description'] = description;
    data['rating'] = rating;
    data['dateCreated'] = dateCreated;
    return data;
  }
}
