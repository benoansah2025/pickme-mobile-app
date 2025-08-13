import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/allTripsModel.dart';
import 'package:pickme_mobile/models/driverRequestModel.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/homepage/bookings/widget/completedTripDialog.dart';
import 'package:pickme_mobile/pages/modules/worker/workerMap/workerMap.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'widget/workerBookingsWidget.dart';

class WorkerBookings extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Position currentLocation;

  const WorkerBookings({
    super.key,
    required this.scaffoldKey,
    required this.currentLocation,
  });

  @override
  State<WorkerBookings> createState() => _WorkerBookingsState();
}

class _WorkerBookingsState extends State<WorkerBookings> {
  final Repository _repo = new Repository();
  final FirebaseService _firebaseService = new FirebaseService();

  TripDetailsModel? _tripDetailsModel;

  @override
  void initState() {
    super.initState();
    _repo.fetchAllTrips(true);
    _loadCurrentTrip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BColors.primaryColor,
        leading: IconButton(
          onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu),
          color: BColors.white,
        ),
        title: Text("My Requests", style: Styles.h4WhiteBold),
      ),
      body: workerBookingsWidget(
        context: context,
        onCompletedTrip: (AllTripsData trip) => _onCompletedTrip(trip),
        onOnGoingTrip: (TripDetailsModel model) => _onOnGoingTrip(model),
        tripDetailsModel: _tripDetailsModel,
      ),
    );
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
        isRider: false,
      ),
    );
  }

  void _onOnGoingTrip(TripDetailsModel model) {
    _firebaseService
        .getDriverRequest(userModel!.data!.user!.userid!, widget.currentLocation)
        .take(1)
        .listen((DriverRequestModel? model) async {
      if (model == null) return;

      WorkerMapNextAction action;
      switch (model.status) {
        case "ACCEPTED":
          action = WorkerMapNextAction.accept;
          break;
        case "ARRIVED-PICKUP":
          action = WorkerMapNextAction.arrived;
          break;
        case "TRIP-STARTED":
          action = WorkerMapNextAction.startTrip;
          break;
        case "TRIP-ENDED":
          action = WorkerMapNextAction.endTrip;
          break;
        default:
          action = WorkerMapNextAction.accept;
          break;
      }

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WorkerMap(
            currentLocation: widget.currentLocation,
            mapNextAction: action,
            servicePurpose: ServicePurpose.ride, // TODO: check service purpose
            requestModel: model,
          ),
        ),
      );
      if (mounted) setState(() {});
    });
    return;
  }

  Future<void> _loadCurrentTrip() async {
    _tripDetailsModel = await FirebaseService().userOnGoingTrip(userModel!.data!.user!.userid!);
    setState(() {});
  }
}
