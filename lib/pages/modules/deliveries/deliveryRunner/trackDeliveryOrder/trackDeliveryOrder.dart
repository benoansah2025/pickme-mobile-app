import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pickme_mobile/pages/modules/rides/rateRide/rateRide.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/rideMap.dart';
import 'package:pickme_mobile/spec/arrays.dart';

import 'widget/trackDeliveryOrderWidget.dart';

class TrackDeliveryOrder extends StatefulWidget {
  final ServicePurpose servicePurpose;
  final Map<dynamic, dynamic> deliveryAddresses;

  const TrackDeliveryOrder({
    super.key,
    required this.servicePurpose,
    required this.deliveryAddresses,
  });

  @override
  State<TrackDeliveryOrder> createState() => _TrackDeliveryOrderState();
}

class _TrackDeliveryOrderState extends State<TrackDeliveryOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: trackDeliveryOrderWidget(
        context: context,
        onTrackOnMap: () => _onTrackOnMap(),
        onCall: () {},
        onChat: () {},
        onDone: () => _onDone(),
      ),
    );
  }

  void _onDone() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => RateRide(
            servicePurpose: widget.servicePurpose,
          ),
        ),
        (Route<dynamic> route) => false);
  }

  void _onTrackOnMap() {
    LatLng pickUpLocation = LatLng(
      widget.deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["lat"],
      widget.deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["long"],
    );
    LatLng whereToLocation = LatLng(
      widget.deliveryAddresses[DeliveryAccessLocation.whereToLocation]["lat"],
      widget.deliveryAddresses[DeliveryAccessLocation.whereToLocation]["long"],
    );
    List<LatLng> trackingPositions = [pickUpLocation, whereToLocation];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideMap(
          currentLocation: null,
          servicePurpose: widget.servicePurpose,
          mapNextAction: RideMapNextAction.trackDriver,
          trackingPositions: trackingPositions,
        ),
      ),
    );
  }
}
