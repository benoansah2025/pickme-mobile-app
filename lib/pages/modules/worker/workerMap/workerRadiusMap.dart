import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customBackButton.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';
import 'dart:ui' as ui;

class WorkerRadiusMap extends StatefulWidget {
  final LatLng? currentLocation;
  final double radius;

  const WorkerRadiusMap({
    super.key,
    required this.currentLocation,
    this.radius = 1000,
  });

  @override
  State<WorkerRadiusMap> createState() => _WorkerRadiusMapState();
}

class _WorkerRadiusMapState extends State<WorkerRadiusMap> {
  final FirebaseService _firebaseService = new FirebaseService();

  GoogleMapController? _mapController;
  Marker? _marker;
  Circle? _radiusCircle;
  BitmapDescriptor? _currentLocationIcon;
  double _currentRadius = 1000.0; // Initial radius of 1 km (1000 meters)

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentRadius = widget.radius;
    _loadCustomMarkerAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.currentLocation!,
              zoom: 14.4746,
            ),
            markers: _marker != null ? {_marker!} : {},
            circles: _radiusCircle != null ? {_radiusCircle!} : {},
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _updateCircle(); // Initialize the circle
              _adjustCamera();
            },
            zoomControlsEnabled: false,
          ),
          SafeArea(child: customBackButton(() => Navigator.pop(context))),
          if (_isLoading) customLoadingPage(),
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: BColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: BColors.black.withOpacity(.1),
              spreadRadius: .1,
              blurRadius: 20,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You will get jobs within",
              style: Styles.h5BlackBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: BColors.background,
                    child: IconButton(
                      onPressed: () {
                        _decreaseRadius();
                      },
                      icon: const Icon(Icons.remove),
                    ),
                  ),
                  Text("${(_currentRadius / 1000).toStringAsFixed(1)} Km", style: Styles.h3BlackBold),
                  CircleAvatar(
                    backgroundColor: BColors.background,
                    child: IconButton(
                      onPressed: () {
                        _increaseRadius();
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            button(
              onPressed: () => _onSaveRadius(),
              text: "Save",
              color: BColors.primaryColor,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSaveRadius() async {
    Map<String, dynamic> reqBody = {
      "driverId": userModel!.data!.user!.userid,
      "radius": _currentRadius,
    };

    setState(() => _isLoading = true);
    Response response = await _firebaseService.saveWorkerRadius(reqBody);

    int statusCode = response.statusCode;
    Map<String, dynamic> body = jsonDecode(response.body);

    log(body.toString());
    setState(() => _isLoading = false);
    if (statusCode == 200) {
      if (!mounted) return;
      Navigator.pop(context);
      // coolAlertDialog(
      //   context: context,
      //   type: PanaraDialogType.success,
      //   text: body["msg"],
      //   confirmBtnText: "Ok",
      //   onConfirmBtnTap: () async {

      //   },
      // );
    } else {
      log(body["error"].toString());
      if (!mounted) return;
      infoDialog(
        context: context,
        type: PanaraDialogType.error,
        text: body["msg"],
        confirmBtnText: "Ok",
      );
    }
  }

  // Update the circle based on the current radius
  void _updateCircle() {
    setState(() {
      _radiusCircle = Circle(
        circleId: const CircleId("radiusCircle"),
        center: widget.currentLocation!,
        radius: _currentRadius,
        fillColor: BColors.primaryColor1.withOpacity(0.3),
        strokeWidth: 1,
        strokeColor: BColors.primaryColor1,
      );
    });
  }

  // Increase the radius and update the circle
  void _increaseRadius() {
    if (_currentRadius < 5000) {
      setState(() {
        _currentRadius += 500; // Increase by 0.5 km
        _updateCircle();
        _adjustCamera();
      });
    }
  }

  // Decrease the radius and update the circle
  void _decreaseRadius() {
    if (_currentRadius > 500) {
      setState(() {
        _currentRadius -= 500; // Decrease by 0.5 km
        _updateCircle();
        _adjustCamera();
      });
    }
  }

  // Adjust the camera to fit the current location and the radius
  void _adjustCamera() {
    if (_mapController == null) return;

    // Calculate bounds using the radius
    final double distanceInDegrees = _radiusToLatLngDegrees(_currentRadius);
    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        widget.currentLocation!.latitude - distanceInDegrees,
        widget.currentLocation!.longitude - distanceInDegrees,
      ),
      northeast: LatLng(
        widget.currentLocation!.latitude + distanceInDegrees,
        widget.currentLocation!.longitude + distanceInDegrees,
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50)); // Padding of 50
  }

  // Convert radius from meters to latitude/longitude degrees
  double _radiusToLatLngDegrees(double radiusInMeters) {
    const double earthRadius = 6371000; // Earth radius in meters
    return radiusInMeters / earthRadius * (180 / pi);
  }

  Future<void> _loadCustomMarkerAssets() async {
    // loading current location asset image
    final Uint8List cLocationIcon = await _getBytesFromAsset(
      Images.currentLocation2,
      60,
    );
    _currentLocationIcon = BitmapDescriptor.bytes(cLocationIcon);

    _marker = Marker(
      markerId: const MarkerId("currentLocation"),
      position: widget.currentLocation!,
      icon: _currentLocationIcon!,
      anchor: const Offset(0.5, 0.5),
    );

    setState(() {});
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await DefaultAssetBundle.of(context).load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }
}
