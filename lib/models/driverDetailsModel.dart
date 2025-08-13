import 'package:cloud_firestore/cloud_firestore.dart';

class DriverDetailsModel {
  Timestamp? createdat;
  CurrentRideDetails? currentRideDetails;
  CurrentTripDetails? currentTripDetails;
  DriverDetailsData? data;
  Timestamp? goLiveTime;
  DriverPosition? position;
  String? status;
  double? radiusInM;
  String? points;

  DriverDetailsModel({
    this.createdat,
    this.currentRideDetails,
    this.currentTripDetails,
    this.data,
    this.goLiveTime,
    this.position,
    this.status,
    this.radiusInM,
    this.points,  
  });

  DriverDetailsModel.fromJson(Map<dynamic, dynamic> json) {
    createdat = json['createdat'] is Timestamp ? json['createdat'] : null;
    currentRideDetails =
        json['currentRideDetails'] != null ? new CurrentRideDetails.fromJson(json['currentRideDetails']) : null;
    currentTripDetails =
        json['currentTripDetails'] != null ? new CurrentTripDetails.fromJson(json['currentTripDetails']) : null;
    data = json['data'] != null ? new DriverDetailsData.fromJson(json['data']) : null;
    goLiveTime = json['go_live_time'] is Timestamp ? json['go_live_time'] : null;
    position = json['position'] != null ? new DriverPosition.fromJson(json['position']) : null;
    status = json['status'] ?? "INACTIVE";
    radiusInM = json['radius'] ?? 1000;
    points = json['points'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdat'] = createdat;
    if (currentRideDetails != null) {
      data['currentRideDetails'] = currentRideDetails!.toJson();
    }
    if (currentTripDetails != null) {
      data['currentTripDetails'] = currentTripDetails!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['go_live_time'] = goLiveTime;
    data['position'] = position;
    data['status'] = status;
    data['radius'] = radiusInM;
    return data;
  }
}

class CurrentRideDetails {
  dynamic discountPercentage;
  String? riderId;
  String? destinationInText;
  double? destinationDistanceInKm;
  double? destinationDistanceInM;
  int? destinationDuration;
  String? riderPhone;
  String? riderLocationInText;
  String? riderNearbyLocation;
  String? riderFirebaseKey;
  GeoPoint? riderPosition;
  String? paymentMethod;
  GeoPoint? destinationPosition;
  String? promoCode;
  String? riderName;
  List<StopStut>? stops;
  String? serviceType;
  String? destinationGeofenceId;

  CurrentRideDetails({
    this.discountPercentage,
    this.riderId,
    this.destinationInText,
    this.riderPhone,
    this.riderLocationInText,
    this.riderFirebaseKey,
    this.riderPosition,
    this.paymentMethod,
    this.destinationPosition,
    this.promoCode,
    this.riderName,
    this.destinationDistanceInKm,
    this.destinationDistanceInM,
    this.destinationDuration,
    this.stops,
    this.serviceType,
    this.destinationGeofenceId,
    this.riderNearbyLocation,
  });

  CurrentRideDetails.fromJson(Map<String, dynamic> json) {
    try {
      discountPercentage = double.parse(json['discountPercentage'].toString());
    } catch (e) {
      discountPercentage = null;
    }
    riderId = json['riderId'];
    destinationInText = json['destinationInText'];
    riderPhone = json['riderPhone'];
    riderLocationInText = json['riderLocationInText'];
    riderNearbyLocation = json['riderNearbyLocation'] ?? "";
    riderFirebaseKey = json['riderFirebaseKey'];
    riderPosition = json['riderPosition'];
    paymentMethod = json['paymentMethod'];
    destinationPosition = json['destinationPosition'];
    promoCode = json['promoCode'];
    riderName = json['riderName'];
    destinationDistanceInKm = json['destinationDistanceInKm'];
    destinationDistanceInM = json['destinationDistanceInM'];
    destinationDuration = json['destinationDuration'];

    if (json["stops"] != null) {
      stops = <StopStut>[];
      json["stops"].forEach((v) {
        stops!.add(StopStut.fromJson(v));
      });
    }

    serviceType = json["serviceType"] ?? "";
    destinationGeofenceId = json["destinationGeofenceId"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['discountPercentage'] = discountPercentage;
    data['riderId'] = riderId;
    data['destinationInText'] = destinationInText;
    data['riderPhone'] = riderPhone;
    data['riderLocationInText'] = riderLocationInText;
    data['riderNearbyLocation'] = riderNearbyLocation;
    data['riderFirebaseKey'] = riderFirebaseKey;
    data['riderPosition'] = riderPosition;
    data['paymentMethod'] = paymentMethod;
    data['destinationPosition'] = destinationPosition;
    data['promoCode'] = promoCode;
    data['riderName'] = riderName;
    return data;
  }
}

class DriverDetailsData {
  String? vehicleYear;
  String? driverName;
  String? vehicleNumber;
  String? driverPhone;
  String? driverPhoto;
  String? vehicleType;
  String? driverId;
  double? heading;
  String? vehicleMake;
  String? driverFirebaseKey;
  String? vehicleColor;
  String? vehicleModel;
  List<String>? driverServices;

  DriverDetailsData({
    this.vehicleYear,
    this.driverName,
    this.vehicleNumber,
    this.driverPhone,
    this.driverPhoto,
    this.vehicleType,
    this.driverId,
    this.heading,
    this.vehicleMake,
    this.driverFirebaseKey,
    this.vehicleColor,
    this.vehicleModel,
    this.driverServices,
  });

  DriverDetailsData.fromJson(Map<dynamic, dynamic> json) {
    vehicleYear = json['vehicleYear'];
    driverName = json['driverName'];
    vehicleNumber = json['vehicleNumber'];
    driverPhone = json['driverPhone'];
    driverPhoto = json['driverPhoto'];
    vehicleType = json['vehicleType'];
    driverId = json['driverId'];
    heading = json['heading'];
    vehicleMake = json['vehicleMake'];
    driverFirebaseKey = json['driverFirebaseKey'];
    vehicleColor = json['vehicleColor'];
    vehicleModel = json['vehicleModel'];
    driverServices = List<String>.from(json['services'] ?? []);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vehicleYear'] = vehicleYear;
    data['driverName'] = driverName;
    data['vehicleNumber'] = vehicleNumber;
    data['driverPhone'] = driverPhone;
    data['driverPhoto'] = driverPhoto;
    data['vehicleType'] = vehicleType;
    data['driverId'] = driverId;
    data['heading'] = heading;
    data['vehicleMake'] = vehicleMake;
    data['driverFirebaseKey'] = driverFirebaseKey;
    data['vehicleColor'] = vehicleColor;
    data['vehicleModel'] = vehicleModel;
    data['services'] = driverServices;
    return data;
  }
}

class DriverPosition {
  String? geohash;
  GeoPoint? geopoint;
  double? heading;

  DriverPosition({
    this.geohash,
    this.geopoint,
    this.heading,
  });

  DriverPosition.fromJson(Map<String, dynamic> json) {
    geohash = json['geohash'];
    geopoint = json['geopoint'];
    try{
      heading = double.parse(json["heading"].toString());
    } catch(e){
      heading = 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['geohash'] = geohash;
    data['geopoint'] = geopoint;
    return data;
  }
}

class CurrentTripDetails {
  String? tripId;
  String? estimatedTotalAmount;
  String? vehicleTypeBaseFare;

  CurrentTripDetails({
    this.tripId,
    this.estimatedTotalAmount,
    this.vehicleTypeBaseFare,
  });

  CurrentTripDetails.fromJson(Map<String, dynamic> json) {
    tripId = json['tripId'];
    estimatedTotalAmount = json["estimatedTotalAmount"];
    vehicleTypeBaseFare = json["vehicleTypeBaseFare"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tripId'] = tripId;
    return data;
  }
}

class StopStut {
  GeoPoint? geopoint;
  String? address;
  String? name;
  String? geofenceId;

  StopStut({
    this.name,
    this.geopoint,
    this.address,
    this.geofenceId,
  });

  StopStut.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address = json['address'] ?? "";
    geopoint = json['geopoint'];
    geofenceId = json['geofenceId'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    data['geopoint'] = geopoint;
    data['geofenceId'] = geofenceId;
    return data;
  }
}
