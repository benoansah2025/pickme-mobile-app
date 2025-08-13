import 'package:cloud_firestore/cloud_firestore.dart';

import 'driverDetailsModel.dart';

class TripDetailsModel {
  int? tries;
  Timestamp? updateAt;
  String? destinationLocation;
  double? destinationDistanceInKm;
  double? destinationDistanceInM;
  int? destinationDuration;
  String? discountAmount;
  String? tripId;
  String? subTotal;
  String? tripKm;
  String? driverCommission;
  Timestamp? createAt;
  String? discountPercentage;
  String? riderId;
  String? totalMinCharged;
  double? pickupLat;
  String? vehicleYear;
  String? vehicleModel;
  String? vehicleNumber;
  String? promoCode;
  double? destinationLat;
  String? vehicleType;
  String? vehicleColor;
  String? pickmePercentage;
  String? grandTotal;
  String? totalKmCharged;
  String? pickupLocation;
  String? vehicleMake;
  String? driverId, driverPhoto, driverName, driverPhone;
  String? totalMinutes;
  double? pickupLog;
  String? paymentMethod;
  double? destinationLog;
  String? pickmeCommission;
  String? periodStart;
  String? periodEnd;
  String? status;
  String? estimatedTotalAmount;
  String? vehicleTypeBaseFare;
  String? riderFirebaseKey;
  String? driverFirebaseKey;
  String? serviceType;
  List<StopStut>? stops;
  String? destinationGeofenceId;

  TripDetailsModel({
    this.tries,
    this.updateAt,
    this.destinationLocation,
    this.discountAmount,
    this.tripId,
    this.subTotal,
    this.tripKm,
    this.driverCommission,
    this.createAt,
    this.discountPercentage,
    this.riderId,
    this.totalMinCharged,
    this.pickupLat,
    this.vehicleYear,
    this.vehicleModel,
    this.vehicleNumber,
    this.promoCode,
    this.destinationLat,
    this.vehicleType,
    this.vehicleColor,
    this.pickmePercentage,
    this.grandTotal,
    this.totalKmCharged,
    this.pickupLocation,
    this.vehicleMake,
    this.driverId,
    this.totalMinutes,
    this.pickupLog,
    this.paymentMethod,
    this.destinationLog,
    this.pickmeCommission,
    this.periodStart,
    this.periodEnd,
    this.status,
    this.estimatedTotalAmount,
    this.driverPhoto,
    this.driverName,
    this.destinationDistanceInKm,
    this.destinationDistanceInM,
    this.destinationDuration,
    this.driverFirebaseKey,
    this.riderFirebaseKey,
    this.driverPhone,
    this.vehicleTypeBaseFare,
    this.serviceType,
    this.stops,
    this.destinationGeofenceId,
  });

  TripDetailsModel.fromJson(Map<dynamic, dynamic> json) {
    tries = json['tries'];
    updateAt = json['updateAt'];
    destinationLocation = json['destinationLocation'];
    discountAmount = json['discountAmount'];
    tripId = json['tripId'];
    subTotal = json['subTotal'];
    tripKm = json['tripKm'].toString();
    driverCommission = json['driverCommission'];
    createAt = json['createAt'];
    discountPercentage = json['discountPercentage'].toString();
    riderId = json['riderId'];
    totalMinCharged = json['totalMinCharged'];
    pickupLat = json['pickupLat'];
    vehicleYear = json['vehicleYear'] ?? "";
    vehicleModel = json['vehicleModel'];
    vehicleNumber = json['vehicleNumber'];
    promoCode = json['promoCode'];
    destinationLat = json['destinationLat'];
    vehicleType = json['vehicleType'];
    vehicleColor = json['vehicleColor'];
    pickmePercentage = json['pickmePercentage'];
    grandTotal = json['grandTotal'];
    totalKmCharged = json['totalKmCharged'];
    pickupLocation = json['pickupLocation'];
    vehicleMake = json['vehicleMake'];
    driverId = json['driverId'];
    driverPhoto = json['driverPhoto'] ?? "";
    driverName = json['driverName'] ?? "N/A";
    driverPhone = json['driverPhone'] ?? "";
    totalMinutes = json['totalMinutes'].toString();
    pickupLog = json['pickupLog'];
    paymentMethod = json['paymentMethod'];
    destinationLog = json['destinationLog'];
    pickmeCommission = json['pickmeCommission'];
    periodStart = json['periodStart'];
    periodEnd = json['periodEnd'];
    status = json['status'];
    estimatedTotalAmount = json['estimatedTotalAmount'].toString();
    vehicleTypeBaseFare = json['vehicleTypeBaseFare'].toString();
    destinationDistanceInKm = json['destinationDistanceInKm'] ?? 0.0;
    destinationDistanceInM = json['destinationDistanceInM'] ?? 0.0;
    destinationDuration = json['destinationDuration'] ?? 0;
    driverFirebaseKey = json['driverFirebaseKey'] ?? "";
    riderFirebaseKey = json['riderFirebaseKey'] ?? "";
    serviceType = json['serviceType'] ?? "";

    if (json["stops"] != null) {
      stops = <StopStut>[];
      json["stops"].forEach((v) {
        stops!.add(StopStut.fromJson(v));
      });
    }
    destinationGeofenceId = json["destinationGeofenceId"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tries'] = tries;
    data['updateAt'] = updateAt;
    data['destinationLocation'] = destinationLocation;
    data['discountAmount'] = discountAmount;
    data['tripId'] = tripId;
    data['subTotal'] = subTotal;
    data['tripKm'] = tripKm;
    data['driverCommission'] = driverCommission;
    data['createAt'] = createAt;
    data['discountPercentage'] = discountPercentage;
    data['riderId'] = riderId;
    data['totalMinCharged'] = totalMinCharged;
    data['pickupLat'] = pickupLat;
    data['vehicleYear'] = vehicleYear;
    data['vehicleModel'] = vehicleModel;
    data['vehicleNumber'] = vehicleNumber;
    data['promoCode'] = promoCode;
    data['destinationLat'] = destinationLat;
    data['vehicleType'] = vehicleType;
    data['vehicleColor'] = vehicleColor;
    data['pickmePercentage'] = pickmePercentage;
    data['grandTotal'] = grandTotal;
    data['totalKmCharged'] = totalKmCharged;
    data['pickupLocation'] = pickupLocation;
    data['vehicleMake'] = vehicleMake;
    data['driverId'] = driverId;
    data['totalMinutes'] = totalMinutes;
    data['pickupLog'] = pickupLog;
    data['paymentMethod'] = paymentMethod;
    data['destinationLog'] = destinationLog;
    data['pickmeCommission'] = pickmeCommission;
    data['periodStart'] = periodStart;
    data['status'] = status;
    return data;
  }
}
