import 'package:pickme_mobile/models/tripEstimateModel.dart';

class RidePickUpModel {
  PickUpStut? pickup;
  PickUpStut? whereTo;
  List<PickUpStut>? busStops;
  TripEstimateModel? tripEstimateModel;
  String? geofenceId;

  RidePickUpModel({this.pickup, this.whereTo, this.busStops});

  RidePickUpModel.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      pickup = json['pickup'] != null ? new PickUpStut.fromJson(json['pickup']) : null;
      whereTo = json['whereTo'] != null ? new PickUpStut.fromJson(json['whereTo']) : null;
      if (json['busStops'] != null) {
        busStops = <PickUpStut>[];
        json['busStops'].forEach((v) {
          busStops!.add(new PickUpStut.fromJson(v));
        });
      }
      tripEstimateModel = json['estimate'];
      geofenceId = json['geofenceId'].toString();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pickup != null) {
      data['pickup'] = pickup!.toJson();
    }
    if (whereTo != null) {
      data['whereTo'] = whereTo!.toJson();
    }
    if (busStops != null) {
      data['busStops'] = busStops!.map((v) => v.toJson()).toList();
    }
    data['estimate'] = tripEstimateModel;
    data['geofenceId'] = geofenceId;
    return data;
  }
}

class PickUpStut {
  String? name;
  String? address;
  double? long;
  double? lat;
  String? geofenceId;

  PickUpStut({
    this.name,
    this.long,
    this.lat,
    this.address,
    this.geofenceId,
  });

  PickUpStut.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address = json['address'] ?? "";
    long = double.parse(json['long'].toString());
    lat = double.parse(json['lat'].toString());
    geofenceId = json['geofenceId'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    data['long'] = long;
    data['lat'] = lat;
    data['geofenceId'] = geofenceId;
    return data;
  }
}

RidePickUpModel setEstimateRidePickUp({
  required RidePickUpModel model,
  required TripEstimateModel? tripEstimate,
}) {
  model.tripEstimateModel = tripEstimate;
  return model;
}
