import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customBackButton.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/config/mapFunction.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/models/geofenceCordinateModel.dart';
import 'package:pickme_mobile/models/geofencesModel.dart';
import 'package:pickme_mobile/models/placeDetailsModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

class SetLocationMap extends StatefulWidget {
  final LatLng? currentLocation;
  final GeofencesData? geofencesData;

  const SetLocationMap({
    super.key,
    required this.currentLocation,
    required this.geofencesData,
  });

  @override
  State<SetLocationMap> createState() => _SetLocationMapState();
}

class _SetLocationMapState extends State<SetLocationMap> {
  // GoogleMapController? _mapController;

  LatLng? _newPosition;
  Marker? _marker;

  PlaceDetailsModel? _placeDetailsModel;

  // bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _marker = Marker(
      markerId: const MarkerId('marker'),
      position: widget.currentLocation!,
      draggable: true,
      onDragEnd: (LatLng newPosition) {
        debugPrint('New position: ${newPosition.latitude}, ${newPosition.longitude}');
        _newPosition = newPosition;
        if (mounted) setState(() {});
        _getPlaceName();
      },
    );
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
            markers: {_marker!},
            onMapCreated: (GoogleMapController controller) {
              // _mapController = controller;
            },
            onTap: (LatLng latLng) {
              setState(() {
                _marker = _marker!.copyWith(
                  positionParam: latLng,
                  onDragEndParam: (LatLng newPosition) {
                    debugPrint('New position: ${newPosition.latitude}, ${newPosition.longitude}');
                    _newPosition = newPosition;
                    if (mounted) setState(() {});
                    _getPlaceName();
                  },
                );
              });
            },
          ),
          SafeArea(child: customBackButton(() => Navigator.pop(context))),
          // if (_isLoading) customLoadingPage(),
        ],
      ),
      bottomNavigationBar: _placeDetailsModel == null && _newPosition == null
          ? null
          : AnimatedContainer(
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
                  if (_placeDetailsModel == null && _newPosition != null) loadingDoubleBounce(BColors.primaryColor),
                  if (_placeDetailsModel != null) ...[
                    Text(
                      _placeDetailsModel!.nearbyPlaceName!,
                      style: Styles.h3BlackBold,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    button(
                      onPressed: () {
                        Navigator.pop(context, _placeDetailsModel);
                      },
                      text: "Done",
                      color: BColors.primaryColor,
                      context: context,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Future<void> _getPlaceName() async {
    if (widget.geofencesData == null) {
      if (!mounted) return;
      infoDialog(
        context: context,
        type: PanaraDialogType.error,
        text: "Unable to load geofences, please report.",
        confirmBtnText: "Ok",
        barrierDismissible: false,
        onConfirmBtnTap: () => navigation(context: context, pageName: "back"),
      );

      return;
    }

    // Convert geofences data to required format
    List<List<GeofenceCordinateModel>> allGeofencesList = [];

    List<LatLng> coordinates =
        widget.geofencesData!.coordinates!.map((coord) => LatLng(coord.lat!, coord.lng!)).toList();

    LatLng center = calculateCenter(coordinates);
    double radius = calculateRadiusFromCoordinates(coordinates);

    List<GeofenceCordinateModel> geofenceList = coordinates
        .map(
          (coord) => GeofenceCordinateModel(
            coord.latitude,
            coord.longitude,
            radius,
            center,
            widget.geofencesData!.baseFee,
            widget.geofencesData!.driverPercentage,
            widget.geofencesData!.pricePerKm,
            widget.geofencesData!.pricePerMinute,
            widget.geofencesData!.services,
            widget.geofencesData!.vehicles,
            widget.geofencesData!.id,
          ),
        )
        .toList();

    allGeofencesList.add(geofenceList);

    PlaceDetailsModel model = await getPlaceDetailsFromCoordinates(_newPosition!.latitude, _newPosition!.longitude);
    LatLng placeLocation = LatLng(model.geometry!.location!.lat!, model.geometry!.location!.lng!);

    for (var geofence in allGeofencesList) {
      // First, quick check using circular radius
      double distanceToCenter = calculateDistance(
        placeLocation,
        geofence.first.center,
      );

      if (distanceToCenter <= geofence.first.radius) {
        // If within radius, do precise polygon check
        List<LatLng> polygonPoints = [];
        GeofenceCordinateModel? geofenceCordinateModel;

        for (var coord in geofence) {
          polygonPoints.add(LatLng(coord.latitude, coord.longitude));
          geofenceCordinateModel = coord;
        }

        if (isPointInPolygon(placeLocation, polygonPoints)) {
          // initialize PlaceDetailsModel with geofenceId
          _placeDetailsModel = setGeofenceIdPlaceDetails(model, geofenceCordinateModel!.estimateId.toString());
          setState(() {});

          return;
        } else {
          if (!mounted) return;
          infoDialog(
            context: context,
            type: PanaraDialogType.error,
            text: "Location is outside of our service area.",
            confirmBtnText: "Ok",
            barrierDismissible: false,
            onConfirmBtnTap: () => navigation(context: context, pageName: "back"),
          );
          return;
        }
      } else {
        if (!mounted) return;
        infoDialog(
          context: context,
          type: PanaraDialogType.error,
          text: "Location is outside of our service area.",
          confirmBtnText: "Ok",
          barrierDismissible: false,
          onConfirmBtnTap: () => navigation(context: context, pageName: "back"),
        );
        return;
      }
    }
  }
}
