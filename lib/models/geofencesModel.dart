import 'dart:convert';

class GeofencesModel {
  bool? ok;
  List<GeofencesData>? data;

  GeofencesModel({this.ok, this.data});

  GeofencesModel.fromJson(Map<String, dynamic> json) {
    ok = json['ok'];
    if (json['data'] != null) {
      data = <GeofencesData>[];
      json['data'].forEach((v) {
        data!.add(new GeofencesData.fromJson(v));
      });
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

class GeofencesData {
  int? id;
  String? name;
  List<Coordinates>? coordinates;
  int? baseFee;
  int? driverPercentage;
  int? pricePerKm;
  double? pricePerMinute;
  List<String>? services;
  List<Vehicles>? vehicles;

  GeofencesData(
      {this.id,
      this.name,
      this.coordinates,
      this.baseFee,
      this.driverPercentage,
      this.pricePerKm,
      this.pricePerMinute,
      this.services,
      this.vehicles});

  GeofencesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['coordinates'] != null) {
      coordinates = <Coordinates>[];
      jsonDecode(json['coordinates']).forEach((v) {
        coordinates!.add(new Coordinates.fromJson(v));
      });
    }
    baseFee = json['base_fee'];
    driverPercentage = json['driver_percentage'];
    pricePerKm = json['price_per_km'];
    pricePerMinute = json['price_per_minute'];
    services = json['services'].cast<String>();
    if (json['vehicles'] != null) {
      vehicles = <Vehicles>[];
      json['vehicles'].forEach((v) {
        vehicles!.add(new Vehicles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (coordinates != null) {
      data['coordinates'] = coordinates!.map((v) => v.toJson()).toList();
    }
    data['base_fee'] = baseFee;
    data['driver_percentage'] = driverPercentage;
    data['price_per_km'] = pricePerKm;
    data['price_per_minute'] = pricePerMinute;
    data['services'] = services;
    if (vehicles != null) {
      data['vehicles'] = vehicles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Coordinates {
  double? lat;
  double? lng;

  Coordinates({this.lat, this.lng});

  Coordinates.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

class Vehicles {
  String? id;
  String? name;

  Vehicles({this.id, this.name});

  Vehicles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
