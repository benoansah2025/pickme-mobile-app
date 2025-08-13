import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/allTripsModel.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/homepage/bookings/widget/completedTripDialog.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/rideMap.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/bookingsWidget.dart';

class Bookings extends StatefulWidget {
  final Position currentLocation;

  const Bookings({
    super.key,
    required this.currentLocation,
  });

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  FocusNode? _searchFocusNode;

  final Repository _repo = new Repository();

  String _searchText = "";

  TripDetailsModel? _tripDetailsModel;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = new FocusNode();
    _repo.fetchAllTrips(true);
    _loadCurrentTrip();
  }

  @override
  void dispose() {
    _searchFocusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bookingsWidget(
        context: context,
        searchFocusNode: _searchFocusNode,
        onSearchChange: (String text) => _onSearchChange(text),
        onBookingFilter: () {},
        onOnGoingTrip: (TripDetailsModel model) => _onOnGoingTrip(model),
        onCompletedTrip: (AllTripsData trip) => _onCompletedTrip(trip),
        searchText: _searchText,
        tripDetailsModel: _tripDetailsModel,
      ),
    );
  }

  Future<void> _loadCurrentTrip() async {
    _tripDetailsModel = await FirebaseService().userOnGoingTrip(userModel!.data!.user!.userid!);
    setState(() {});
  }

  Future<void> _onCompletedTrip(AllTripsData trip) async {
    List<LatLng> pathCoordinates = [
      LatLng(double.parse(trip.pickupLat.toString()), double.parse(trip.pickupLng.toString())),
      ...[for (var t in trip.stops!) LatLng(t.latitude, t.longitude)],
      LatLng(double.parse(trip.destinationLat.toString()), double.parse(trip.destinationLng.toString())),
    ];

    if (!mounted) return;
    showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: BColors.white,
      builder: (context) => CompletedTripDialog(
        trip: trip,
        pathCoordinates: pathCoordinates,
      ),
    );
  }

  Future<void> _onOnGoingTrip(TripDetailsModel model) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideMap(
          currentLocation: widget.currentLocation,
          onGoingTripDetails: model,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  void _onSearchChange(String text) {
    _searchText = text;
    setState(() {});
  }
}
