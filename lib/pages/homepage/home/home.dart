import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/homepage/home/widget/homeDeliveryOptionsWidget.dart';
import 'package:pickme_mobile/pages/modules/deliveries/deliveryRunner/deliveryRunnerType/deliveryRunnerType.dart';
import 'package:pickme_mobile/pages/modules/deliveries/personalShopper/personalShopping/personalShopping.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/rideMap.dart';
import 'package:pickme_mobile/providers/locationProdiver.dart';
import 'package:pickme_mobile/spec/properties.dart';

import 'widget/homeWidget.dart';

class Home extends StatefulWidget {
  final Position currentLocation;
  final VoidCallback onProfile;

  const Home({
    super.key,
    required this.currentLocation,
    required this.onProfile,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = false;

  Position? _currentLocation;
  TripDetailsModel? _tripDetailsModel;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.currentLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
      _loadCurrentTrip();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          homeWidget(
            context: context,
            onSos: (String? tap) => _onSOS(tap),
            onNotification: () => navigation(context: context, pageName: "notifications"),
            onRide: () => _onRide(),
            onDelivery: () => _onDelivery(),
            currentLocation: _currentLocation,
            onProfile: widget.onProfile,
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  void _onSOS(String? tap) {
    if (tap == "openEmergency") {
      navigation(context: context, pageName: "emergency");
    } else {
      callLauncher("tel: ${Properties.contactDetails["phone"]}");
    }
  }

  Future<void> _getCurrentLocation() async {
    // setState(() => _isLoading = true);
    _currentLocation = await Geolocator.getCurrentPosition();

    LocationProvider().getPositionStream().listen((Position position) {
      _currentLocation = position;
      if (mounted) {
        // setState(() {});
      }
    });
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _onRide() async {
    if (_currentLocation == null) {
      toastContainer(text: "Please wait, we are fetching your location", backgroundColor: Colors.red);
      return;
    }

    if (_tripDetailsModel != null && _tripDetailsModel?.tripId != null) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RideMap(
            currentLocation: _currentLocation,
            onGoingTripDetails: _tripDetailsModel,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideMap(currentLocation: _currentLocation!),
      ),
    );
  }

  void _onDelivery() {
    showModalBottomSheet(
      context: context,
      builder: (context) => homeDeliveryOptionsWidget(
        context: context,
        onDelivery: (String type) {
          if (type == "personalShopper") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PersonalShopping(),
              ),
            );
          } else if (type == "deliveryRunner") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DeliveryRunnerType(),
              ),
            );
          } else {
            navigation(context: context, pageName: "vendors");
          }
        },
      ),
    );
  }

  Future<void> _loadCurrentTrip() async {
    _tripDetailsModel = await FirebaseService().userOnGoingTrip(userModel!.data!.user!.userid!);
    setState(() {});
  }
}
