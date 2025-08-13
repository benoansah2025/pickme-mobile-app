import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pickme_mobile/pages/modules/deliveries/personalShopper/trackShopperOrder/widget/trackShopperOrderWidget.dart';
import 'package:pickme_mobile/pages/modules/rides/rateRide/rateRide.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/rideMap.dart';
import 'package:pickme_mobile/spec/arrays.dart';

class TrackShopperOrder extends StatefulWidget {
  const TrackShopperOrder({super.key});

  @override
  State<TrackShopperOrder> createState() => _TrackShopperOrderState();
}

class _TrackShopperOrderState extends State<TrackShopperOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: trackShopperOrderWidget(
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
          builder: (context) => const RateRide(
            servicePurpose: ServicePurpose.personalShopper,
          ),
        ),
        (Route<dynamic> route) => false);
  }

  void _onTrackOnMap() {
    List<LatLng> trackingPositions = [
      // deliveryLocation
      const LatLng(5.6037432, -0.1895328),
      // driver location
      const LatLng(5.6044586, -0.2104522),
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideMap(
          currentLocation: null,
          servicePurpose: ServicePurpose.personalShopper,
          mapNextAction: RideMapNextAction.trackDriver,
          trackingPositions: trackingPositions,
        ),
      ),
    );
  }
}
