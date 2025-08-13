import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customBackButton.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/config/mapFunction.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/geofenceCordinateModel.dart';
import 'package:pickme_mobile/models/geofencesModel.dart';
import 'package:pickme_mobile/models/placeDetailsModel.dart';
import 'package:pickme_mobile/models/placePredictionModel.dart';
import 'package:pickme_mobile/models/ridePickUpModel.dart';
import 'package:pickme_mobile/pages/modules/rides/ridePlaces/setLocationMap.dart';
import 'package:pickme_mobile/providers/geofencesProvider.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/rideMultiStopPlacesWidget.dart';

class RideMultiStopPlaces extends StatefulWidget {
  final PlaceDetailsModel? currentLocationPlaceDetails;
  final LatLng? currentLocation;

  const RideMultiStopPlaces({
    super.key,
    required this.currentLocationPlaceDetails,
    required this.currentLocation,
  });

  @override
  State<RideMultiStopPlaces> createState() => _RideMultiStopPlacesState();
}

class _RideMultiStopPlacesState extends State<RideMultiStopPlaces> {
  Size _topWidgetSize = const Size(0, 200);

  Map<String, dynamic> _pickUpMap = {};
  final List<Map<String, dynamic>> _multiPlaceList = [];

  final TextEditingController _pickupController = TextEditingController();

  FocusNode? _pickupFocusNode;

  bool _isLoading = false;

  List<PlacePredictionModel> _placePredictions = [];
  RidePlaceFields _ridePlaceFields = RidePlaceFields.whereTo;

  int _currentStopField = 0;

  GeofencesData? _geofencesData;

  @override
  void initState() {
    super.initState();
    _pickupFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserUserCurrentGeoFenceData();
    });

    Map<String, dynamic> picked = {
      "name": widget.currentLocationPlaceDetails?.name,
      "address": widget.currentLocationPlaceDetails!.nearbyPlaceName,
      "long": widget.currentLocation!.longitude,
      "lat": widget.currentLocation!.latitude,
    };

    isCodePlaceName(picked["name"])
        ? picked["name"] = widget.currentLocationPlaceDetails?.formattedAddress
        : picked["name"] = picked["name"];

    _pickUpMap = picked;
    _pickupController.text = _pickUpMap["name"] ?? "My current location";

    _onAddStopsTextBox(true);
    _onAddStopsTextBox(false);
  }

  @override
  void dispose() {
    _pickupFocusNode!.dispose();
    super.dispose();
  }

  void _unFocusAllNodes() {
    _pickupFocusNode!.unfocus();
    for (var data in _multiPlaceList) {
      (data["focus"] as FocusNode).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.background,
      appBar: AppBar(
        backgroundColor: BColors.background,
        leading: customBackButton(() {
          Navigator.pop(context);
        }),
        leadingWidth: 150,
      ),
      body: Stack(
        children: [
          rideMultiStopPlacesWidget(
            context: context,
            onRemoveStopOver: (int index) => _onRemoveStopOver(index),
            onTopWidgetSize: (Size size) => _onTopWidgetSize(size),
            topWidgetSize: _topWidgetSize,
            pickupController: _pickupController,
            pickupFocusNode: _pickupFocusNode!,
            onPlaceTyping: (String text, RidePlaceFields type, int? index) => _onPlaceTyping(text, type, index),
            placePredictions: _placePredictions,
            onPlaceSelected: (PlacePredictionModel prediction) => _onPlaceSelected(prediction),
            onClearPickupText: () => _onClearpickupText(),
            multiPlaceList: _multiPlaceList,
            onClearStopText: (int index) => _onClearStopText(index),
            onMapPickerStop: (RidePlaceFields type, int index) => _onMapPickerStop(type, index),
            pickUpMap: _pickUpMap,
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
      bottomNavigationBar: Container(
        color: BColors.white,
        padding: const EdgeInsets.all(10),
        child: button(
          onPressed: () => _goBackToRideMap(),
          text: "Done",
          color: BColors.primaryColor,
          context: context,
        ),
      ),
    );
  }

  Future<void> _getUserUserCurrentGeoFenceData() async {
    // get geofences
    if (geofencesModel == null) {
      setState(() => _isLoading = true);
      final repo = new Repository();
      await repo.fetchGeofences(true);
      setState(() => _isLoading = false);
    }

    if (geofencesModel!.data == null) {
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

    // _geofencesData = geofencesModel!.data!.first;
    // return;

    setState(() => _isLoading = true);
    GeofencesData? data = GeofencesProvider().getUserCurrentGeoFenceData(widget.currentLocation!);
    _geofencesData = data;
    setState(() => _isLoading = false);

    if (_geofencesData == null) {
      if (!mounted) return;
      navigation(context: context, pageName: "back");
      toastContainer(
        text: "Service not available in your location",
        backgroundColor: BColors.red,
      );
    }
  }

  Future<void> _onMapPickerStop(RidePlaceFields type, int index) async {
    _unFocusAllNodes();

    toastContainer(text: "Drag marker to desired location $index");
    PlaceDetailsModel? placeDetailsModel = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetLocationMap(
          currentLocation: widget.currentLocation,
          geofencesData: _geofencesData,
        ),
      ),
    );

    _ridePlaceFields = type;
    _currentStopField = index;

    if (placeDetailsModel != null) {
      Map<String, dynamic> picked = {
        "name": placeDetailsModel.name,
        "address": placeDetailsModel.nearbyPlaceName,
        "long": placeDetailsModel.geometry!.location!.lng,
        "lat": placeDetailsModel.geometry!.location!.lat,
        "geofenceId": placeDetailsModel.geofenceId,
      };

      if (_ridePlaceFields == RidePlaceFields.pickUp) {
        _pickUpMap = picked;
        _pickupController.text = picked["name"];
      } else if (_ridePlaceFields == RidePlaceFields.stopOvers) {
        (_multiPlaceList[_currentStopField]["place"] as TextEditingController).text = picked["name"];
        _multiPlaceList[_currentStopField]["lat"] = placeDetailsModel.geometry!.location!.lat;
        _multiPlaceList[_currentStopField]["long"] = placeDetailsModel.geometry!.location!.lng;
        _multiPlaceList[_currentStopField]["showClose"] = true;

        if (_currentStopField == _multiPlaceList.length - 1) {
          _onAddStopsTextBox(false);
        }
        setState(() {});
      }

      _placePredictions.clear();
      if (!mounted) return;
      setState(() {});
    }
  }

  void _onClearStopText(int index) {
    (_multiPlaceList[index]["place"] as TextEditingController).clear();
    _multiPlaceList[index]["lat"] = 0;
    _multiPlaceList[index]["long"] = 0;
    setState(() {});
  }

  void _onClearpickupText() {
    _pickupController.clear();
    setState(() {});
    _pickupFocusNode!.requestFocus();
  }

  Future<void> _onPlaceTyping(String text, RidePlaceFields type, int? index) async {
    _ridePlaceFields = type;

    List<List<GeofenceCordinateModel>> allGeofencesList = [];

    List<LatLng> coordinates = _geofencesData!.coordinates!.map((coord) => LatLng(coord.lat!, coord.lng!)).toList();

    LatLng center = calculateCenter(coordinates);
    double radius = calculateRadiusFromCoordinates(coordinates);

    List<GeofenceCordinateModel> geofenceList = coordinates
        .map(
          (coord) => GeofenceCordinateModel(
            coord.latitude,
            coord.longitude,
            radius,
            center,
            _geofencesData!.baseFee,
            _geofencesData!.driverPercentage,
            _geofencesData!.pricePerKm,
            _geofencesData!.pricePerMinute,
            _geofencesData!.services,
            _geofencesData!.vehicles,
            _geofencesData!.id,
          ),
        )
        .toList();

    allGeofencesList.add(geofenceList);

    _placePredictions = await getPlacePredictions(
      text,
      widget.currentLocation!,
      allGeofences: allGeofencesList,
      geoAreaName: _geofencesData!.name!,
    );

    _currentStopField = index ?? _currentStopField;
    setState(() {});
  }

  void _onRemoveStopOver(int index) {
    _multiPlaceList.removeAt(index);
    setState(() {});
  }

  Future<void> _onPlaceSelected(PlacePredictionModel prediction) async {
    _unFocusAllNodes();
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      Map<String, dynamic> picked = {
        "name": prediction.name,
        "address": prediction.plusCode?.compoundCode ?? "",
        "long": prediction.geometry!.location!.lng,
        "lat": prediction.geometry!.location!.lat,
        "geofenceId": prediction.geofenceId,
      };

      if (_ridePlaceFields == RidePlaceFields.pickUp) {
        _pickUpMap = picked;
        _pickupController.text = picked["name"];
      } else if (_ridePlaceFields == RidePlaceFields.stopOvers) {
        (_multiPlaceList[_currentStopField]["place"] as TextEditingController).text = picked["name"];
        _multiPlaceList[_currentStopField]["lat"] = prediction.geometry!.location!.lat;
        _multiPlaceList[_currentStopField]["long"] = prediction.geometry!.location!.lng;
        _multiPlaceList[_currentStopField]["showClose"] = true;
        _multiPlaceList[_currentStopField]["address"] = prediction.plusCode?.compoundCode;
        _multiPlaceList[_currentStopField]["geofenceId"] = prediction.geofenceId;

        if (_currentStopField == _multiPlaceList.length - 1) {
          _onAddStopsTextBox(false);
        }
        setState(() {});
      }

      _placePredictions.clear();

      if (!mounted) return;
      setState(() {});
    } on Exception catch (_, e) {
      setState(() => _isLoading = false);
      log("Place picker => ${e.toString()}");
    }
  }

  Future<void> _goBackToRideMap() async {
    if (_pickupController.text.isNotEmpty) {
      Map<String, dynamic> whereToMap = {};
      final List<Map<String, dynamic>> busStopsList = [];
      List<LatLng> busStopList = [];
      for (var data in _multiPlaceList) {
        if (data["lat"] != 0 && data["long"] != 0) {
          busStopsList.add({
            "name": (data["place"] as TextEditingController).text,
            "address": data["address"],
            "long": data["long"],
            "lat": data["lat"],
            "geofenceId": data["geofenceId"],
          });
          busStopList.add(LatLng(data["lat"], data["long"]));
        }
      }

      if (busStopsList.isNotEmpty) {
        whereToMap = busStopsList.last;
        busStopsList.removeAt(busStopsList.length - 1);
      } else {
        toastContainer(text: "Enter destination", backgroundColor: BColors.red);
        return;
      }

      List<LatLng> locations = [];
      locations.addAll([
        LatLng(_pickUpMap["lat"], _pickUpMap["long"]),
        ...busStopList,
        LatLng(whereToMap["lat"], whereToMap["long"]),
      ]);

      Map<String, dynamic> meta = {
        "pickup": _pickUpMap,
        "whereTo": whereToMap,
        "busStops": busStopsList,
        "geofenceId": whereToMap["geofenceId"] ?? "",
      };
      logStatement(meta);
      RidePickUpModel model = RidePickUpModel.fromJson(meta);

      if (!mounted) return;
      Navigator.pop(context, model);
    }
  }

  void _onTopWidgetSize(Size size) {
    _topWidgetSize = size;
    setState(() {});
  }

  void _onAddStopsTextBox(bool showClose) {
    Map<String, dynamic> meta = {
      "place": TextEditingController(),
      "focus": FocusNode(),
      "lat": 0,
      "long": 0,
      "showClose": showClose
    };

    _multiPlaceList.add(meta);

    for (var data in _multiPlaceList) {
      (data["focus"] as FocusNode).addListener(() {
        _pickupController.text = _pickUpMap["name"] ?? "My current location";
        if (mounted) setState(() {});
      });
    }
  }
}
