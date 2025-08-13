import 'package:flutter/foundation.dart';

class BusinessListingsModel {
  bool? ok;
  BusinessListingsData? data;

  BusinessListingsModel({this.ok, this.data});

  BusinessListingsModel.fromJson({
    @required Map<String, dynamic>? json,
    @required String? httpMsg,
  }) {
    if (json != null) {
      ok = json['ok'];
      data = json['data'] != null ? new BusinessListingsData.fromJson(json['data']) : null;
    } else {
      ok = false;
      data = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ok'] = ok;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class BusinessListingsData {
  List<ListingDetails>? active;
  List<ListingDetails>? expired;
  List<ListingDetails>? pending;

  BusinessListingsData({this.active, this.expired});

  BusinessListingsData.fromJson(Map<String, dynamic> json) {
    if (json['active'] != null) {
      active = <ListingDetails>[];
      json['active'].forEach((v) {
        active!.add(new ListingDetails.fromJson(v));
      });
    }
    if (json['expired'] != null) {
      expired = <ListingDetails>[];
      json['expired'].forEach((v) {
        expired!.add(new ListingDetails.fromJson(v));
      });
    }
    if (json['pending'] != null) {
      pending = <ListingDetails>[];
      json['pending'].forEach((v) {
        pending!.add(new ListingDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (active != null) {
      data['active'] = active!.map((v) => v.toJson()).toList();
    }
    if (expired != null) {
      data['expired'] = expired!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListingDetails {
  String? businessId;
  String? businessName;
  String? serviceName;
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
  dynamic rating;
  String? subscriptionId;
  String? subscriptionName;
  String? subscriptionPrice;
  String? subscriptionDurationDays;
  List<String>? subscriptionFeatures;
  String? amountPaid;
  String? paymentMethod;
  String? expiryStatus;
  String? reviewStatus;
  String? datePaid;
  int? daysRemaining;
  String? expiryDate;
  String? paymentReference;
  String? dateCreated;
  String? status;
  List<SubscriptionHistory>? subscriptionHistory;

  ListingDetails({
    this.businessId,
    this.businessName,
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
    this.subscriptionId,
    this.subscriptionName,
    this.subscriptionPrice,
    this.subscriptionDurationDays,
    this.subscriptionFeatures,
    this.amountPaid,
    this.paymentMethod,
    this.expiryStatus,
    this.reviewStatus,
    this.datePaid,
    this.daysRemaining,
    this.expiryDate,
    this.paymentReference,
    this.dateCreated,
    this.status,
    this.subscriptionHistory,
  });

  ListingDetails.fromJson(Map<String, dynamic> json) {
    businessId = json['businessId'];
    businessName = json['businessName'];
    serviceName = json['serviceName'];
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
    rating = json['rating'];
    subscriptionId = json['subscriptionId'];
    subscriptionName = json['subscriptionName'];
    subscriptionPrice = json['subscriptionPrice'];
    subscriptionDurationDays = json['subscriptionDurationDays'];
    subscriptionFeatures = json['subscriptionFeatures'].cast<String>();
    amountPaid = json['amountPaid'];
    paymentMethod = json['paymentMethod'];
    expiryStatus = json['expiryStatus'];
    reviewStatus = json['reviewStatus'];
    datePaid = json['datePaid'];
    daysRemaining = json['daysRemaining'];
    expiryDate = json['expiryDate'];
    paymentReference = json['paymentReference'];
    dateCreated = json['dateCreated'];
    status = json['status'];
    if (json['subscriptionHistory'] != null) {
      subscriptionHistory = <SubscriptionHistory>[];
      json['subscriptionHistory'].forEach((v) {
        subscriptionHistory!.add(new SubscriptionHistory.fromJson(v));

        // sort by datePaid in descending order
        subscriptionHistory!.sort((a, b) => b.datePaid!.compareTo(a.datePaid!));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['businessId'] = businessId;
    data['businessName'] = businessName;
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
    data['subscriptionId'] = subscriptionId;
    data['subscriptionName'] = subscriptionName;
    data['subscriptionPrice'] = subscriptionPrice;
    data['subscriptionDurationDays'] = subscriptionDurationDays;
    data['subscriptionFeatures'] = subscriptionFeatures;
    data['amountPaid'] = amountPaid;
    data['paymentMethod'] = paymentMethod;
    data['expiryStatus'] = expiryStatus;
    data['reviewStatus'] = reviewStatus;
    data['datePaid'] = datePaid;
    data['daysRemaining'] = daysRemaining;
    data['expiryDate'] = expiryDate;
    data['paymentReference'] = paymentReference;
    data['dateCreated'] = dateCreated;
    if (subscriptionHistory != null) {
      data['subscriptionHistory'] = subscriptionHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubscriptionHistory {
  int? id;
  String? subscriptionId;
  String? subscriptionName;
  String? subscriptionPrice;
  String? subscriptionDurationDays;
  List<String>? subscriptionFeatures;
  String? paymentMethod;
  String? paymentReference;
  String? status;
  String? datePaid;
  int? daysLeft;

  SubscriptionHistory(
      {this.id,
      this.subscriptionId,
      this.subscriptionName,
      this.subscriptionPrice,
      this.subscriptionDurationDays,
      this.subscriptionFeatures,
      this.paymentMethod,
      this.paymentReference,
      this.status,
      this.datePaid,
      this.daysLeft});

  SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subscriptionId = json['subscriptionId'];
    subscriptionName = json['subscriptionName'];
    subscriptionPrice = json['subscriptionPrice'];
    subscriptionDurationDays = json['subscriptionDurationDays'];
    subscriptionFeatures = json['subscriptionFeatures'].cast<String>();
    paymentMethod = json['paymentMethod'];
    paymentReference = json['paymentReference'];
    status = json['status'];
    datePaid = json['datePaid'];
    daysLeft = json['daysLeft'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['subscriptionId'] = subscriptionId;
    data['subscriptionName'] = subscriptionName;
    data['subscriptionPrice'] = subscriptionPrice;
    data['subscriptionDurationDays'] = subscriptionDurationDays;
    data['subscriptionFeatures'] = subscriptionFeatures;
    data['paymentMethod'] = paymentMethod;
    data['paymentReference'] = paymentReference;
    data['status'] = status;
    data['datePaid'] = datePaid;
    data['daysLeft'] = daysLeft;
    return data;
  }
}
