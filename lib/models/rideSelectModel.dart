class RideSelectModel {
  bool? ok;
  String? msg;
  RiderSelectData? data;

  RideSelectModel({this.ok, this.msg, this.data});

  RideSelectModel.fromJson(Map<String, dynamic> json) {
    ok = json['ok'];
    msg = json['msg'];
    data = json['data'] != null ? new RiderSelectData.fromJson(json['data']) : null;
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

class RiderSelectData {
  List<Rides>? drivers;

  RiderSelectData({this.drivers});

  RiderSelectData.fromJson(Map<String, dynamic> json) {
    if (json['drivers'] != null) {
      drivers = <Rides>[];
      json['drivers'].forEach((v) {
        drivers!.add(new Rides.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (drivers != null) {
      data['drivers'] = drivers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Rides {
  String? driverId;
  double? distanceInKm;
  double? distanceInM;
  int? duration;
  double? latitute;
  double? heading;
  double? longitude;
  String? totalFee;
  String? vehicleTypeBaseFare;
  RideExtraData? data;

  Rides({
    this.driverId,
    this.distanceInKm,
    this.distanceInM,
    this.duration,
    this.latitute,
    this.longitude,
    this.data,
    this.heading,
    this.totalFee,
    this.vehicleTypeBaseFare,
  });

  Rides.fromJson(Map<String, dynamic> json) {
    driverId = json['driverId'];
    distanceInKm = json['distanceInKm'];
    distanceInM = json['distanceInM'];
    duration = json['duration'];
    latitute = json['latitute'];
    longitude = json['longitude'];
    heading = json['heading'];
    data = json['data'] != null ? new RideExtraData.fromJson(json['data']) : null;
    totalFee = (json["totalFee"] ?? "").toString();
    vehicleTypeBaseFare = (json["vehicleTypeBaseFare"] ?? "").toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['driverId'] = driverId;
    data['distanceInKm'] = distanceInKm;
    data['distanceInM'] = distanceInM;
    data['duration'] = duration;
    data['latitute'] = latitute;
    data['longitude'] = longitude;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class RideExtraData {
  String? vehicleColor;
  String? vehicleYear;
  String? driverId;
  double? heading;
  String? driverPhoto;
  String? vehicleNumber;
  String? vehicleModel;
  String? driverName;
  String? driverPhone;
  String? driverFirebaseKey;
  String? vehicleMake;
  String? vehicleType;

  RideExtraData(
      {this.vehicleColor,
      this.vehicleYear,
      this.driverId,
      this.heading,
      this.driverPhoto,
      this.vehicleNumber,
      this.vehicleModel,
      this.driverName,
      this.driverPhone,
      this.driverFirebaseKey,
      this.vehicleMake,
      this.vehicleType});

  RideExtraData.fromJson(Map<String, dynamic> json) {
    vehicleColor = json['vehicleColor'];
    vehicleYear = json['vehicleYear'];
    driverId = json['driverId'];
    heading = json['heading'];
    driverPhoto = json['driverPhoto'];
    vehicleNumber = json['vehicleNumber'];
    vehicleModel = json['vehicleModel'];
    driverName = json['driverName'];
    driverPhone = json['driverPhone'];
    driverFirebaseKey = json['driverFirebaseKey'];
    vehicleMake = json['vehicleMake'];
    vehicleType = json['vehicleType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vehicleColor'] = vehicleColor;
    data['vehicleYear'] = vehicleYear;
    data['driverId'] = driverId;
    data['heading'] = heading;
    data['driverPhoto'] = driverPhoto;
    data['vehicleNumber'] = vehicleNumber;
    data['vehicleModel'] = vehicleModel;
    data['driverName'] = driverName;
    data['driverPhone'] = driverPhone;
    data['driverFirebaseKey'] = driverFirebaseKey;
    data['vehicleMake'] = vehicleMake;
    data['vehicleType'] = vehicleType;
    return data;
  }
}
