import 'package:flutter/foundation.dart';

class SubscriptionsModel {
  bool? ok;
  List<SubscriptionData>? data;

  SubscriptionsModel({this.ok, this.data});

  SubscriptionsModel.fromJson({
    @required Map<String, dynamic>? json,
    @required String? httpMsg,
  }) {
    if (json != null) {
      ok = json['ok'];
      if (json['data'] != null) {
        data = <SubscriptionData>[];
        json['data'].forEach((v) {
          data!.add(new SubscriptionData.fromJson(v));
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

class SubscriptionData {
  dynamic id;
  String? name;
  String? description;
  dynamic price;
  int? durationDays;
  String? dateCreated;
  List<String>? features;

  SubscriptionData({
    this.id,
    this.name,
    this.description,
    this.price,
    this.durationDays,
    this.dateCreated,
    this.features,
  });

  SubscriptionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    durationDays = json['durationDays'];
    dateCreated = json['dateCreated'];
    features = json['features'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    data['durationDays'] = durationDays;
    data['dateCreated'] = dateCreated;
    data['features'] = features;
    return data;
  }
}
