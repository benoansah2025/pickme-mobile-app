import 'package:flutter/foundation.dart';

class WorkersInfoModel {
  bool? ok;
  String? msg;
  WorkersInfoData? data;

  WorkersInfoModel({this.ok, this.msg, this.data});

  WorkersInfoModel.fromJson({
    @required Map<String, dynamic>? json,
    @required String? httpMsg,
  }) {
    if (json != null) {
      ok = json['ok'];
      msg = json['msg'];
      data = json['data'] != null ? new WorkersInfoData.fromJson(json['data']) : null;
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

class WorkersInfoData {
  String? name;
  String? dob;
  String? gender;
  String? picture;
  String? licenseNumber;
  String? expiryDate;
  String? licenseFront;
  String? licenseBack;
  String? ghanacardNo;
  String? ghanaCardFront;
  String? ghanaCardBack;
  String? vehicleTypeId;
  String? vehicleType;
  String? pickmeRollNo;
  String? vehicleMake;
  String? vehicleModel;
  String? vehicleYear;
  String? vehicleNumber;
  String? vehicleColor;
  String? insuranceExpiryDate;
  String? roadWorthyExpiryDate;
  String? insuranceImage;
  String? roadWorthyImage;
  List<String>? services;
  String? mainService;
  String? status;
  dynamic rating;
  dynamic amountToPayDaily;
  dynamic tripCount;
  dynamic tripsCancelled;
  dynamic todaySales;
  String? dateCreated;

  WorkersInfoData(
      {this.name,
      this.dob,
      this.gender,
      this.picture,
      this.licenseNumber,
      this.expiryDate,
      this.licenseFront,
      this.licenseBack,
      this.ghanacardNo,
      this.ghanaCardFront,
      this.ghanaCardBack,
      this.vehicleTypeId,
      this.vehicleType,
      this.pickmeRollNo,
      this.vehicleMake,
      this.vehicleModel,
      this.vehicleYear,
      this.vehicleNumber,
      this.vehicleColor,
      this.insuranceExpiryDate,
      this.roadWorthyExpiryDate,
      this.insuranceImage,
      this.roadWorthyImage,
      this.services,
      this.mainService,
      this.status,
      this.rating,
      this.amountToPayDaily,
      this.tripCount,
      this.tripsCancelled,
      this.todaySales,
      this.dateCreated});

  WorkersInfoData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    dob = json['dob'];
    gender = json['gender'];
    picture = json['picture'];
    licenseNumber = json['licenseNumber'];
    expiryDate = json['expiryDate'];
    licenseFront = json['licenseFront'];
    licenseBack = json['licenseBack'];
    ghanacardNo = json['ghanacardNo'];
    ghanaCardFront = json['ghanaCardFront'];
    ghanaCardBack = json['ghanaCardBack'];
    vehicleTypeId = json['vehicleTypeId'];
    vehicleType = json['vehicleType'];
    pickmeRollNo = json['pickmeRollNo'];
    vehicleMake = json['vehicleMake'];
    vehicleModel = json['vehicleModel'];
    vehicleYear = json['vehicleYear'];
    vehicleNumber = json['vehicleNumber'];
    vehicleColor = json['vehicleColor'];
    insuranceExpiryDate = json['insuranceExpiryDate'];
    roadWorthyExpiryDate = json['roadWorthyExpiry_date'];
    insuranceImage = json['insuranceImage'];
    roadWorthyImage = json['roadWorthyImage'];
    services = json['services'].cast<String>();
    mainService = json['mainService'];
    status = json['status'];
    rating = json['rating'];
    amountToPayDaily = json['amountToPayDaily'];
    tripCount = json['tripCount'];
    tripsCancelled = json['tripsCancelled'];
    todaySales = json['todaySales'];
    dateCreated = json['dateCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['dob'] = dob;
    data['gender'] = gender;
    data['picture'] = picture;
    data['licenseNumber'] = licenseNumber;
    data['expiryDate'] = expiryDate;
    data['licenseFront'] = licenseFront;
    data['licenseBack'] = licenseBack;
    data['ghanacardNo'] = ghanacardNo;
    data['ghanaCardFront'] = ghanaCardFront;
    data['ghanaCardBack'] = ghanaCardBack;
    data['vehicleTypeId'] = vehicleTypeId;
    data['vehicleType'] = vehicleType;
    data['pickmeRollNo'] = pickmeRollNo;
    data['vehicleMake'] = vehicleMake;
    data['vehicleModel'] = vehicleModel;
    data['vehicleYear'] = vehicleYear;
    data['vehicleNumber'] = vehicleNumber;
    data['vehicleColor'] = vehicleColor;
    data['insuranceExpiryDate'] = insuranceExpiryDate;
    data['roadWorthyExpiry_date'] = roadWorthyExpiryDate;
    data['insuranceImage'] = insuranceImage;
    data['roadWorthyImage'] = roadWorthyImage;
    data['services'] = services;
    data['mainService'] = mainService;
    data['status'] = status;
    data['rating'] = rating;
    data['amountToPayDaily'] = amountToPayDaily;
    data['tripCount'] = tripCount;
    data['tripsCancelled'] = tripsCancelled;
    data['todaySales'] = todaySales;
    data['dateCreated'] = dateCreated;
    return data;
  }
}