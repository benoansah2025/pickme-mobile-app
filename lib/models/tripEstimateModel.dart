import 'package:flutter/foundation.dart';

class TripEstimateModel {
  bool? ok;
  String? msg;
  Data? data;

  TripEstimateModel({this.ok, this.msg, this.data});

  TripEstimateModel.fromJson({
    @required Map<String, dynamic>? json,
    @required String? httpMsg,
    required String duration,
    required String distanceKm,
  }) {
    if (json != null) {
      ok = json['ok'];
      msg = json['msg'];
      data = json['data'] != null
          ? new Data.fromJson(
              json['data'],
              duration,
              distanceKm,
            )
          : null;
    } else {
      ok = false;
      msg = httpMsg;
      data = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ok'] = ok;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Car? car;
  Car? okada;
  Car? bike;
  Car? pragia;
  String? duration, distanceKm;

  Data({
    this.car,
    this.okada,
    this.distanceKm,
    this.duration,
  });

  Data.fromJson(Map<String, dynamic> json, String this.duration, String this.distanceKm) {
    car = json['Car'] != null ? new Car.fromJson(json['Car']) : null;
    okada = json['Okada'] != null ? new Car.fromJson(json['Okada']) : null;
    bike = json['bike'] != null ? new Car.fromJson(json['bike']) : null;
    pragia = json['Pragia'] != null ? new Car.fromJson(json['Pragia']) : null;
    try {
      distanceKm = double.parse(distanceKm!).toStringAsFixed(2);
    } catch (e) {
       distanceKm = distanceKm;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (car != null) {
      data['Car'] = car!.toJson();
    }
    if (okada != null) {
      data['Okada'] = okada!.toJson();
    }
    if (bike != null) {
      data['bike'] = bike!.toJson();
    }
    if (pragia != null) {
      data['Pragia'] = pragia!.toJson();
    }
    data["duration"] = duration;
    data["distanceKm"] = distanceKm;
    return data;
  }
}

class Car {
  String? totalFee;
  String? vehicleTypeBaseFare;
  dynamic baseFee;
  dynamic kmFee;
  dynamic minuteFee;
  String? vehicleTypeId;

  Car({this.totalFee, this.vehicleTypeBaseFare, this.baseFee, this.kmFee, this.minuteFee, this.vehicleTypeId});

  Car.fromJson(Map<String, dynamic> json) {
    totalFee = json['totalFee'].toString();
    vehicleTypeBaseFare = json['vehicleTypeBaseFare'].toString();
    baseFee = json['baseFee'];
    try {
      baseFee = double.parse(json['baseFee'].toString()).toStringAsFixed(2);
    } catch (e) {
      baseFee = json['baseFee'];
    }
    kmFee = json['kmFee'];
    try {
      kmFee = double.parse(json['kmFee'].toString()).toStringAsFixed(2);
    } catch (e) {
      kmFee = json['kmFee'];
    }
    minuteFee = json['minuteFee'];
    try {
      minuteFee = double.parse(json['minuteFee'].toString()).toStringAsFixed(2);
    } catch (e) {
      minuteFee = json['minuteFee'];
    }
    vehicleTypeId = json['vehicleTypeId'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalFee'] = totalFee;
    data['vehicleTypeBaseFare'] = vehicleTypeBaseFare;
    data['baseFee'] = baseFee;
    data['kmFee'] = kmFee;
    data['minuteFee'] = minuteFee;
    data['vehicleTypeId'] = vehicleTypeId;
    return data;
  }
}
