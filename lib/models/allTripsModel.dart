import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AllTripsModel {
  bool? ok;
  String? msg;
  List<AllTripsData>? data;
  int? totalTrip;
  double? totalDistance;

  AllTripsModel({
    this.ok,
    this.msg,
    this.data,
    this.totalTrip,
  });

  AllTripsModel.fromJson({
    @required Map<String, dynamic>? json,
    @required String? httpMsg,
  }) {
    if (json != null) {
      ok = json['ok'];
      msg = json['msg'];
      if (json['data'] != null) {
        data = <AllTripsData>[];
        json['data'].forEach((v) {
          data!.add(AllTripsData.fromJson(v));
        });

        // Sort the data list by dateCreated in descending order (newest first)
        data!.sort((a, b) {
          DateTime dateA = DateTime.parse(a.periodEnd ?? "2024-09-17 20:03:37");
          DateTime dateB = DateTime.parse(b.periodEnd ?? "2024-09-17 20:03:37");
          return dateB.compareTo(dateA); // Sort in descending order
        });

        totalTrip = data?.length ?? 0;
        totalDistance = 0;
        for (var d in data!) {
          try {
            totalDistance = totalDistance! + double.parse(d.totalKm.toString());
          } catch (e) {
            debugPrint(e.toString());
          }
        }
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
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Map<String, List<AllTripsData>> groupTripsByMonthYear() {
    Map<String, List<AllTripsData>> groupedTrips = {};

    data?.forEach((trip) {
      String monthYear = formatDate(trip.periodStart!);
      if (!groupedTrips.containsKey(monthYear)) {
        groupedTrips[monthYear] = [];
      }
      groupedTrips[monthYear]?.add(trip);
    });

    return groupedTrips;
  }

  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final outputFormat = DateFormat("MMMM yyyy");
      return outputFormat.format(dateTime);
    } catch (e) {
      debugPrint("Error parsing date: $dateString, Error: $e");
      return "Unknown Date";
    }
  }
}

class AllTripsData {
  String? tripId;
  String? pickupLocation;
  String? pickupLat;
  String? pickupLng;
  String? destinationLocation;
  String? destinationLat;
  String? destinationLng;
  String? riderId;
  String? riderName;
  String? riderPhone;
  String? driverId;
  String? driverName;
  String? driverPhone;
  String? vehicleType;
  String? vehicleMake;
  String? vehicleModel;
  String? vehicleYear;
  String? vehicleNumber;
  String? vehicleColor;
  String? status;
  dynamic riderRating;
  dynamic riderReview;
  dynamic driverReview;
  dynamic waitMin;
  dynamic totalWaitCharged;
  dynamic totalKm;
  dynamic totalKmCharged;
  dynamic totalMinutes;
  dynamic totalMinCharged;
  dynamic subTotal;
  dynamic grandTotal;
  dynamic cancellationFee;
  dynamic pickmeCommission;
  dynamic driverCommission;
  String? periodStart;
  String? periodEnd;
  String? dateCreated;
  List<dynamic>? stops;
  String? serviceType;
  bool? isPass24Hours;
  String? pickupNearbyLocation;

  AllTripsData({
    this.tripId,
    this.pickupLocation,
    this.pickupLat,
    this.pickupLng,
    this.destinationLocation,
    this.destinationLat,
    this.destinationLng,
    this.riderId,
    this.riderName,
    this.driverId,
    this.driverName,
    this.vehicleType,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleYear,
    this.vehicleNumber,
    this.vehicleColor,
    this.status,
    this.riderRating,
    this.riderReview,
    this.driverReview,
    this.waitMin,
    this.totalWaitCharged,
    this.totalKm,
    this.totalKmCharged,
    this.totalMinutes,
    this.totalMinCharged,
    this.subTotal,
    this.grandTotal,
    this.cancellationFee,
    this.pickmeCommission,
    this.driverCommission,
    this.periodStart,
    this.periodEnd,
    this.dateCreated,
    this.stops,
    this.serviceType,
    this.driverPhone,
    this.riderPhone,
    this.isPass24Hours,
    this.pickupNearbyLocation,
  });

  AllTripsData.fromJson(Map<String, dynamic> json) {
    tripId = json['tripId'];
    pickupLocation = json['pickupLocation'];
    pickupLat = json['pickupLat'];
    pickupLng = json['pickupLng'];
    destinationLocation = json['destinationLocation'];
    destinationLat = json['destinationLat'];
    destinationLng = json['destinationLng'];
    riderId = json['riderId'];
    riderName = json['riderName'];
    driverId = json['driverId'];
    driverName = json['driverName'];
    vehicleType = json['vehicleType'];
    vehicleMake = json['vehicleMake'];
    vehicleModel = json['vehicleModel'];
    vehicleYear = json['vehicleYear'];
    vehicleNumber = json['vehicleNumber'];
    vehicleColor = json['vehicleColor'];
    status = json['status'];
    riderRating = json['riderRating'];
    riderReview = json['riderReview'];
    driverReview = json['driverReview'];
    waitMin = json['waitMin'];
    totalWaitCharged = json['totalWaitCharged'];
    totalKm = json['totalKm'];
    totalKmCharged = json['totalKmCharged'];
    totalMinutes = json['totalMinutes'];
    try {
      totalMinutes = int.parse(totalMinutes.toString());
    } catch (e) {
      totalMinutes = 0;
    }
    totalMinCharged = json['totalMinCharged'];
    subTotal = json['subTotal'];
    grandTotal = json['grandTotal'];
    cancellationFee = json['cancellationFee'];
    pickmeCommission = json['pickmeCommission'];
    driverCommission = json['driverCommission'];
    periodStart = json['periodStart'];
    periodEnd = json['periodEnd'];
    dateCreated = json['dateCreated'];
    stops = json["stops"] is List
        ? json["stops"]
        : json["stops"] is String
            ? (jsonDecode(json["stops"]) is List ? jsonDecode(json["stops"]) : [])
            : [];
    serviceType = json["serviceType"] ?? "";
    driverPhone = json["driverPhone"] ?? "N/A";
    riderPhone = json["riderPhone"] ?? "N/A";

    isPass24Hours = false;
    pickupNearbyLocation = json["pickupNearbyLocation"] ?? "";

    if (periodEnd != null) {
      DateTime date = DateTime.parse(periodEnd!);
      DateTime currentDate = DateTime.now();
      Duration timeDiff = currentDate.difference(date);
      if (timeDiff.inHours >= 24) {
        isPass24Hours = true;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tripId'] = tripId;
    data['pickupLocation'] = pickupLocation;
    data['pickupLat'] = pickupLat;
    data['pickupLng'] = pickupLng;
    data['destinationLocation'] = destinationLocation;
    data['destinationLat'] = destinationLat;
    data['destinationLng'] = destinationLng;
    data['riderId'] = riderId;
    data['riderName'] = riderName;
    data['driverId'] = driverId;
    data['driverName'] = driverName;
    data['vehicleType'] = vehicleType;
    data['vehicleMake'] = vehicleMake;
    data['vehicleModel'] = vehicleModel;
    data['vehicleYear'] = vehicleYear;
    data['vehicleNumber'] = vehicleNumber;
    data['vehicleColor'] = vehicleColor;
    data['status'] = status;
    data['riderRating'] = riderRating;
    data['riderReview'] = riderReview;
    data['driverReview'] = driverReview;
    data['waitMin'] = waitMin;
    data['totalWaitCharged'] = totalWaitCharged;
    data['totalKm'] = totalKm;
    data['totalKmCharged'] = totalKmCharged;
    data['totalMinutes'] = totalMinutes;
    data['totalMinCharged'] = totalMinCharged;
    data['subTotal'] = subTotal;
    data['grandTotal'] = grandTotal;
    data['cancellationFee'] = cancellationFee;
    data['pickmeCommission'] = pickmeCommission;
    data['driverCommission'] = driverCommission;
    data['periodStart'] = periodStart;
    data['periodEnd'] = periodEnd;
    data['dateCreated'] = dateCreated;
    data['pickupNearbyLocation'] = pickupNearbyLocation;
    return data;
  }
}
