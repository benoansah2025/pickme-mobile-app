class PlacemarkModel {
  String? name;
  String? street;
  String? isoCountryCode;
  String? country;
  String? postalCode;
  String? administrativeArea;
  String? subAdministrativeArea;
  String? locality;
  String? subLocality;
  String? thoroughfare;
  String? subThoroughfare;

  PlacemarkModel(
      {this.name,
      this.street,
      this.isoCountryCode,
      this.country,
      this.postalCode,
      this.administrativeArea,
      this.subAdministrativeArea,
      this.locality,
      this.subLocality,
      this.thoroughfare,
      this.subThoroughfare});

  PlacemarkModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    street = json['street'];
    isoCountryCode = json['isoCountryCode'];
    country = json['country'];
    postalCode = json['postalCode'];
    administrativeArea = json['administrativeArea'];
    subAdministrativeArea = json['subAdministrativeArea'];
    locality = json['locality'];
    subLocality = json['subLocality'];
    thoroughfare = json['thoroughfare'];
    subThoroughfare = json['subThoroughfare'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['street'] = street;
    data['isoCountryCode'] = isoCountryCode;
    data['country'] = country;
    data['postalCode'] = postalCode;
    data['administrativeArea'] = administrativeArea;
    data['subAdministrativeArea'] = subAdministrativeArea;
    data['locality'] = locality;
    data['subLocality'] = subLocality;
    data['thoroughfare'] = thoroughfare;
    data['subThoroughfare'] = subThoroughfare;
    return data;
  }
}
