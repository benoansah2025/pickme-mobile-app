import 'dart:math';

import 'package:flutter/foundation.dart';

class VendorsModel {
  bool? ok;
  List<Data>? data;

  VendorsModel({this.ok, this.data});

  VendorsModel.fromJson({
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

  // Method to calculate distance between two lat/long points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371e3; // Earth radius in meters
    double phi1 = lat1 * pi / 180;
    double phi2 = lat2 * pi / 180;
    double deltaPhi = (lat2 - lat1) * pi / 180;
    double deltaLambda = (lon2 - lon1) * pi / 180;

    double a =
        sin(deltaPhi / 2) * sin(deltaPhi / 2) + cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in meters
  }

  // Method to sort vendors by proximity
  void sortVendorsByProximity(double currentLat, double currentLon) {
    if (data != null && data!.isNotEmpty) {
      data!.sort((a, b) {
        // Check if either a or b has null latitude/longitude and handle accordingly
        if (a.latitude == null || a.longitude == null) {
          return 1; // Move vendors with null lat/long to the end
        } else if (b.latitude == null || b.longitude == null) {
          return -1; // Move vendors with null lat/long to the end
        } else {
          // If both have valid lat/long, calculate the distance
          double distanceA = _calculateDistance(
            currentLat,
            currentLon,
            double.parse(a.latitude!),
            double.parse(a.longitude!),
          );
          double distanceB = _calculateDistance(
            currentLat,
            currentLon,
            double.parse(b.latitude!),
            double.parse(b.longitude!),
          );
          return distanceA.compareTo(distanceB);
        }
      });
    }
  }
}

class Data {
  String? vendorId;
  String? vendorName;
  dynamic serviceName;
  String? phone;
  String? email;
  String? region;
  String? district;
  String? town;
  String? streetname;
  String? gpsaddress;
  String? latitude;
  String? longitude;
  String? picture;
  int? rating;
  String? status;
  String? subscriptionId;
  String? subscriptionName;
  String? subscriptionPrice;
  String? subscriptionDurationDays;
  int? subscriptionVisibilityFrequency;
  List<String>? subscriptionFeatures;
  String? amountPaid;
  String? paymentMethod;
  String? expiryStatus;
  String? datePaid;
  int? daysRemaining;
  String? expiryDate;
  String? paymentReference;
  String? dateCreated;

  Data({
    this.vendorId,
    this.vendorName,
    this.serviceName,
    this.phone,
    this.email,
    this.region,
    this.district,
    this.town,
    this.streetname,
    this.gpsaddress,
    this.latitude,
    this.longitude,
    this.picture,
    this.rating,
    this.status,
    this.subscriptionId,
    this.subscriptionName,
    this.subscriptionPrice,
    this.subscriptionDurationDays,
    this.subscriptionVisibilityFrequency,
    this.subscriptionFeatures,
    this.amountPaid,
    this.paymentMethod,
    this.expiryStatus,
    this.datePaid,
    this.daysRemaining,
    this.expiryDate,
    this.paymentReference,
    this.dateCreated,
  });

  Data.fromJson(Map<String, dynamic> json) {
    vendorId = json['vendorId'];
    vendorName = json['vendorName'];
    serviceName = json['serviceName'] ?? "N/A";
    phone = json['phone'];
    email = json['email'];
    region = json['region'];
    district = json['district'];
    town = json['town'];
    streetname = json['streetname'];
    gpsaddress = json['gpsaddress'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    picture = json['picture'];
    try {
      rating = int.parse(json['rating'].toString());
    } catch (e) {
      rating = 5;
    }
    status = json['status'];
    subscriptionId = json['subscriptionId'];
    subscriptionName = json['subscriptionName'];
    subscriptionPrice = json['subscriptionPrice'];
    subscriptionDurationDays = json['subscriptionDurationDays'];
    subscriptionVisibilityFrequency = json['subscriptionVisibilityFrequency'] ?? 0;
    subscriptionFeatures = json['subscriptionFeatures'].cast<String>();
    amountPaid = json['amountPaid'];
    paymentMethod = json['paymentMethod'];
    expiryStatus = json['expiryStatus'];
    datePaid = json['datePaid'];
    daysRemaining = json['daysRemaining'];
    expiryDate = json['expiryDate'];
    paymentReference = json['paymentReference'];
    dateCreated = json['dateCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vendorId'] = vendorId;
    data['vendorName'] = vendorName;
    data['serviceName'] = serviceName;
    data['phone'] = phone;
    data['email'] = email;
    data['region'] = region;
    data['district'] = district;
    data['town'] = town;
    data['streetname'] = streetname;
    data['gpsaddress'] = gpsaddress;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['picture'] = picture;
    data['rating'] = rating;
    data['status'] = status;
    data['subscriptionId'] = subscriptionId;
    data['subscriptionName'] = subscriptionName;
    data['subscriptionPrice'] = subscriptionPrice;
    data['subscriptionDurationDays'] = subscriptionDurationDays;
    data['subscriptionVisibilityFrequency'] = subscriptionVisibilityFrequency;
    data['subscriptionFeatures'] = subscriptionFeatures;
    data['amountPaid'] = amountPaid;
    data['paymentMethod'] = paymentMethod;
    data['expiryStatus'] = expiryStatus;
    data['datePaid'] = datePaid;
    data['daysRemaining'] = daysRemaining;
    data['expiryDate'] = expiryDate;
    data['paymentReference'] = paymentReference;
    data['dateCreated'] = dateCreated;
    return data;
  }
}
