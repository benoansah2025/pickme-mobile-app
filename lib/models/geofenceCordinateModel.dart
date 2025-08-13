import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pickme_mobile/models/geofencesModel.dart';

class GeofenceCordinateModel {
  final LatLng center;
  final double radius; // in meters
  final double latitude;
  final double longitude;
  final int? baseFee;
  final int? driverPercentage;
  final int? pricePerKm;
  final double? pricePerMinute;
  final List<String>? services;
  final List<Vehicles>? vehicles;
  final int? estimateId;

  GeofenceCordinateModel(
    this.latitude,
    this.longitude,
    this.radius,
    this.center,
    this.baseFee,
    this.driverPercentage,
    this.pricePerKm,
    this.pricePerMinute,
    this.services,
    this.vehicles,
    this.estimateId,
  );
}

