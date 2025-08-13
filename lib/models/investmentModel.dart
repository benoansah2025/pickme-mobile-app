import 'package:flutter/foundation.dart';

class InvestmentModel {
  bool? ok;
  List<InvestmentData>? data;

  InvestmentModel({this.ok, this.data});

  InvestmentModel.fromJson({
    @required Map<String, dynamic>? json,
    @required String? httpMsg,
  }) {
    if (json != null) {
      ok = json['ok'];
      if (json['data'] != null) {
        data = <InvestmentData>[];
        json['data'].forEach((v) {
          data!.add(new InvestmentData.fromJson(v));
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

class InvestmentData {
  String? title;
  String? flyer;
  String? description;
  String? dateCreated;

  InvestmentData({this.title, this.flyer, this.description, this.dateCreated});

  InvestmentData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    flyer = json['flyer'];
    description = json['description'];
    dateCreated = json['dateCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['flyer'] = flyer;
    data['description'] = description;
    data['dateCreated'] = dateCreated;
    return data;
  }
}
