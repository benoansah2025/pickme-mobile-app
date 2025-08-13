import 'geofencesModel.dart';

class PlacePredictionModel {
  String? businessStatus;
  Geometry? geometry;
  String? icon;
  String? iconBackgroundColor;
  String? iconMaskBaseUri;
  String? name;
  OpeningHours? openingHours;
  List<Photos>? photos;
  String? placeId;
  PlusCode? plusCode;
  dynamic rating;
  String? reference;
  String? scope;
  List<String>? types;
  int? userRatingsTotal;
  String? vicinity;
  int? geofenceId;
  int? baseFee;
  int? driverPercentage;
  int? pricePerKm;
  double? pricePerMinute;
  List<String>? services;
  List<Vehicles>? vehicles;
  double? distance;
  String? distanceInKm;

  PlacePredictionModel({
    this.businessStatus,
    this.geometry,
    this.icon,
    this.iconBackgroundColor,
    this.iconMaskBaseUri,
    this.name,
    this.openingHours,
    this.photos,
    this.placeId,
    this.plusCode,
    this.rating,
    this.reference,
    this.scope,
    this.types,
    this.userRatingsTotal,
    this.vicinity,
    this.baseFee,
    this.driverPercentage,
    this.pricePerKm,
    this.pricePerMinute,
    this.services,
    this.vehicles,
    this.geofenceId,
    this.distance,
    this.distanceInKm,
  });

  PlacePredictionModel.fromJson(Map<String, dynamic> json) {
    businessStatus = json['business_status'];
    geometry = json['geometry'] != null ? new Geometry.fromJson(json['geometry']) : null;
    icon = json['icon'];
    iconBackgroundColor = json['icon_background_color'];
    iconMaskBaseUri = json['icon_mask_base_uri'];
    name = json['name'];
    openingHours = json['opening_hours'] != null ? new OpeningHours.fromJson(json['opening_hours']) : null;
    if (json['photos'] != null) {
      photos = <Photos>[];
      json['photos'].forEach((v) {
        photos!.add(new Photos.fromJson(v));
      });
    }
    placeId = json['place_id'];
    plusCode = json['plus_code'] != null ? new PlusCode.fromJson(json['plus_code']) : null;
    rating = json['rating'];
    reference = json['reference'];
    scope = json['scope'];
    types = json['types'] != null ? json['types'].cast<String>() : [];
    userRatingsTotal = json['user_ratings_total'];
    vicinity = json['vicinity'];
    baseFee = json['baseFee'] ?? 0;
    driverPercentage = json['driverPercentage'] ?? 0;
    pricePerKm = json['pricePerKm'] ?? 0;
    pricePerMinute = json['pricePerMinute'] ?? 0.0;
    services = List<String>.from(json['services'] ?? []);
    vehicles = json['vehicles'] != null
        ? json['vehicles'] is List<Map<String, dynamic>>
            ? (json['vehicles'] as List<dynamic>?)?.map((e) => Vehicles.fromJson(e as Map<String, dynamic>)).toList()
            : json['vehicles']
        : [];
    geofenceId = json['estimateId'] ?? 0;
    distance = json["distance"] ?? 0;
    distanceInKm = (distance! / 1000).toStringAsFixed(2);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['business_status'] = businessStatus;
    if (geometry != null) {
      data['geometry'] = geometry!.toJson();
    }
    data['icon'] = icon;
    data['icon_background_color'] = iconBackgroundColor;
    data['icon_mask_base_uri'] = iconMaskBaseUri;
    data['name'] = name;
    if (openingHours != null) {
      data['opening_hours'] = openingHours!.toJson();
    }
    if (photos != null) {
      data['photos'] = photos!.map((v) => v.toJson()).toList();
    }
    data['place_id'] = placeId;
    if (plusCode != null) {
      data['plus_code'] = plusCode!.toJson();
    }
    data['rating'] = rating;
    data['reference'] = reference;
    data['scope'] = scope;
    data['types'] = types;
    data['user_ratings_total'] = userRatingsTotal;
    data['vicinity'] = vicinity;
    data['baseFee'] = baseFee;
    data['driverPercentage'] = driverPercentage;
    data['pricePerKm'] = pricePerKm;
    data['pricePerMinute'] = pricePerMinute;
    data['services'] = services;
    data['vehicles'] = vehicles?.map((e) => e.toJson()).toList();
    data["estimateId"] = geofenceId;
    return data;
  }
}

class Geometry {
  Location? location;
  Viewport? viewport;

  Geometry({this.location, this.viewport});

  Geometry.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null ? new Location.fromJson(json['location']) : null;
    viewport = json['viewport'] != null ? new Viewport.fromJson(json['viewport']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (viewport != null) {
      data['viewport'] = viewport!.toJson();
    }
    return data;
  }
}

class Location {
  double? lat;
  double? lng;

  Location({this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json) {
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

class Viewport {
  Location? northeast;
  Location? southwest;

  Viewport({this.northeast, this.southwest});

  Viewport.fromJson(Map<String, dynamic> json) {
    northeast = json['northeast'] != null ? new Location.fromJson(json['northeast']) : null;
    southwest = json['southwest'] != null ? new Location.fromJson(json['southwest']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (northeast != null) {
      data['northeast'] = northeast!.toJson();
    }
    if (southwest != null) {
      data['southwest'] = southwest!.toJson();
    }
    return data;
  }
}

class OpeningHours {
  bool? openNow;

  OpeningHours({this.openNow});

  OpeningHours.fromJson(Map<String, dynamic> json) {
    openNow = json['open_now'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['open_now'] = openNow;
    return data;
  }
}

class Photos {
  int? height;
  List<String>? htmlAttributions;
  String? photoReference;
  int? width;

  Photos({this.height, this.htmlAttributions, this.photoReference, this.width});

  Photos.fromJson(Map<String, dynamic> json) {
    height = json['height'];
    htmlAttributions = json['html_attributions'].cast<String>();
    photoReference = json['photo_reference'];
    width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['height'] = height;
    data['html_attributions'] = htmlAttributions;
    data['photo_reference'] = photoReference;
    data['width'] = width;
    return data;
  }
}

class PlusCode {
  String? compoundCode;
  String? globalCode;

  PlusCode({this.compoundCode, this.globalCode});

  PlusCode.fromJson(Map<String, dynamic> json) {
    compoundCode = json['compound_code'];
    globalCode = json['global_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['compound_code'] = compoundCode;
    data['global_code'] = globalCode;
    return data;
  }
}
