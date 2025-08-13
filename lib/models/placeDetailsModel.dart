class PlaceDetailsModel {
  List<AddressComponents>? addressComponents;
  String? adrAddress;
  String? formattedAddress;
  Geometry? geometry;
  String? icon;
  String? iconBackgroundColor;
  String? iconMaskBaseUri;
  String? name;
  String? placeId;
  String? reference;
  List<String>? types;
  String? url;
  int? utcOffset;
  String? vicinity;
  String? geofenceId;
  String? nearbyPlaceName;

  PlaceDetailsModel({
    this.addressComponents,
    this.adrAddress,
    this.formattedAddress,
    this.geometry,
    this.icon,
    this.iconBackgroundColor,
    this.iconMaskBaseUri,
    this.name,
    this.placeId,
    this.reference,
    this.types,
    this.url,
    this.utcOffset,
    this.vicinity,
    this.geofenceId,
    this.nearbyPlaceName,
  });

  PlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    var result = json['result'] ?? json;
    if (result['address_components'] != null) {
      addressComponents = <AddressComponents>[];
      result['address_components'].forEach((v) {
        addressComponents!.add(new AddressComponents.fromJson(v));
      });
    }
    adrAddress = result['adr_address'];
    formattedAddress = result['formatted_address'];
    geometry = result['geometry'] != null ? new Geometry.fromJson(result['geometry']) : null;
    icon = result['icon'];
    iconBackgroundColor = result['icon_background_color'];
    iconMaskBaseUri = result['icon_mask_base_uri'];
    name = result['name'];
    placeId = result['place_id'];
    reference = result['reference'];
    types = result['types'] != null ? result['types'].cast<String>() : [];
    url = result['url'];
    utcOffset = result['utc_offset'];
    vicinity = result['vicinity'];
    nearbyPlaceName = json["nearbyPlaceName"] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (addressComponents != null) {
      data['address_components'] = addressComponents!.map((v) => v.toJson()).toList();
    }
    data['adr_address'] = adrAddress;
    data['formatted_address'] = formattedAddress;
    if (geometry != null) {
      data['geometry'] = geometry!.toJson();
    }
    data['icon'] = icon;
    data['icon_background_color'] = iconBackgroundColor;
    data['icon_mask_base_uri'] = iconMaskBaseUri;
    data['name'] = name;
    data['place_id'] = placeId;
    data['reference'] = reference;
    data['types'] = types;
    data['url'] = url;
    data['utc_offset'] = utcOffset;
    data['vicinity'] = vicinity;
    data['nearbyPlaceName'] = nearbyPlaceName;
    return data;
  }
}

class AddressComponents {
  String? longName;
  String? shortName;
  List<String>? types;

  AddressComponents({this.longName, this.shortName, this.types});

  AddressComponents.fromJson(Map<dynamic, dynamic> json) {
    longName = json['long_name'];
    shortName = json['short_name'];
    types = json['types'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['long_name'] = longName;
    data['short_name'] = shortName;
    data['types'] = types;
    return data;
  }
}

class Geometry {
  Location? location;
  Viewport? viewport;

  Geometry({this.location, this.viewport});

  Geometry.fromJson(Map<dynamic, dynamic> json) {
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

  Location.fromJson(Map<dynamic, dynamic> result) {
    lat = result['lat'];
    lng = result['lng'];
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

  Viewport.fromJson(Map<dynamic, dynamic> json) {
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

PlaceDetailsModel setGeofenceIdPlaceDetails(PlaceDetailsModel placeDetailsModel, String geofenceId) {
  placeDetailsModel.geofenceId = geofenceId;
  return placeDetailsModel;
}