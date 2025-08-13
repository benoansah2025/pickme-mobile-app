import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customBackButton.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';
import 'package:pickme_mobile/config/mapFunction.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/geofenceCordinateModel.dart';
import 'package:pickme_mobile/models/geofencesModel.dart';
import 'package:pickme_mobile/models/placeDetailsModel.dart';
import 'package:pickme_mobile/models/placePredictionModel.dart';
import 'package:pickme_mobile/models/ridePickUpModel.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/widget/rideMapBottomWidget.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMultiStopPlaces/rideMultiStopPlaces.dart';
import 'package:pickme_mobile/pages/modules/rides/ridePlaces/setLocationMap.dart';
import 'package:pickme_mobile/providers/geofencesProvider.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/ridePlacesWidget.dart';

class RidePlaces extends StatefulWidget {
  final LatLng? currentLocation;
  final bool isRecent;
  final QuickPlace? storeLocation;

  const RidePlaces({
    super.key,
    required this.currentLocation,
    this.isRecent = false,
    this.storeLocation,
  });

  @override
  State<RidePlaces> createState() => _RidePlacesState();
}

class _RidePlacesState extends State<RidePlaces> {
  Size _topWidgetSize = const Size(0, 200);

  Map<String, dynamic> _whereToMap = {};
  Map<String, dynamic> _pickUpMap = {};

  final TextEditingController _whereToController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();

  FocusNode? _whereToFocusNode, _pickupFocusNode;

  bool _isLoading = false, _isQuickPlaceSecondaryOption = false;

  List<PlacePredictionModel> _placePredictions = [];
  RidePlaceFields _ridePlaceFields = RidePlaceFields.whereTo;
  PlaceDetailsModel? _currentLocationPlaceDetails;
  GeofencesData? _geofencesData;

  Map<dynamic, dynamic> _placesSaved = {};
  QuickPlace? _quickPlace;

  final ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _whereToFocusNode = FocusNode();
    _pickupFocusNode = FocusNode();

    _getRidePlacesHistory();
    _getCurrentLocationDetails();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserUserCurrentGeoFenceData();
    });

    _whereToFocusNode!.addListener(() {
      if (_whereToFocusNode!.hasFocus) {
        _pickupController.text = _pickUpMap["name"];
        if (mounted) setState(() {});
      }
    });

    if (widget.storeLocation != null) {
      _onSecondaryQuickTap(widget.storeLocation!);
    }
  }

  @override
  void dispose() {
    _whereToFocusNode!.dispose();
    _pickupFocusNode!.dispose();
    super.dispose();
  }

  void _unFocusAllNodes() {
    _whereToFocusNode!.unfocus();
    _pickupFocusNode!.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (invoke) {
        if (invoke) return;
        _onBack();
      },
      child: Scaffold(
        backgroundColor: BColors.background,
        appBar: AppBar(
          backgroundColor: BColors.background,
          leading: customBackButton(() => _onBack()),
          leadingWidth: 150,
        ),
        body: Stack(
          children: [
            ridePlacesWidget(
              context: context,
              onAddMultiStopsPlaces: () => _onAddMultiStopsPlaces(),
              onTopWidgetSize: (Size size) => _onTopWidgetSize(size),
              topWidgetSize: _topWidgetSize,
              onQuickPlace: (QuickPlace place) => _onQuickPlace(place),
              onRecentPlace: (String name) => _onRecentPlace(name),
              whereToController: _whereToController,
              whereToFocusNode: _whereToFocusNode!,
              pickupController: _pickupController,
              pickupFocusNode: _pickupFocusNode!,
              onPlaceTyping: (String text, RidePlaceFields type) => _onPlaceTyping(text, type),
              placePredictions: _placePredictions,
              onPlaceSelected: (PlacePredictionModel prediction) => _onPlaceSelected(prediction),
              onClearPickupText: () => _onClearpickupText(),
              placesSaved: _placesSaved,
              scrollController: _scrollController,
              isRecent: widget.isRecent,
              onSecondaryQuickTap: (QuickPlace place) => _onSecondaryQuickTap(place),
              isQuickPlaceSecondaryOption: _isQuickPlaceSecondaryOption,
              pickUpMap: _pickUpMap,
            ),
            if (_isLoading) customLoadingPage(),
          ],
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

  void _onBack() {
    _unFocusAllNodes();
    if (_isQuickPlaceSecondaryOption) {
      _isQuickPlaceSecondaryOption = false;
      setState(() {});
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _onSecondaryQuickTap(QuickPlace place) async {
    _whereToController.clear();
    _unFocusAllNodes();

    _quickPlace = place;
    // toastContainer(text: "Enter ${place == QuickPlace.home ? 'home' : 'work'} location");

    _isQuickPlaceSecondaryOption = true;
    setState(() {});

    await Future.delayed(const Duration(seconds: 1));
    _whereToFocusNode!.requestFocus();
  }

  Future<void> _onQuickPlace(QuickPlace place) async {
    if (place == QuickPlace.setLocation) {
      toastContainer(text: "Drag marker to desired location");
      PlaceDetailsModel? placeDetailsModel = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SetLocationMap(
            currentLocation: widget.currentLocation,
            geofencesData: _geofencesData,
          ),
        ),
      );

      if (placeDetailsModel != null) {
        Map<String, dynamic> picked = {
          "name": placeDetailsModel.name,
          "address": placeDetailsModel.nearbyPlaceName,
          "long": placeDetailsModel.geometry!.location!.lng,
          "lat": placeDetailsModel.geometry!.location!.lat,
          "geofenceId": placeDetailsModel.geofenceId,
        };

        if (_isQuickPlaceSecondaryOption) {
          // saving quick place
          _placesSaved.addAll({
            _quickPlace == QuickPlace.home ? "home" : "work": picked,
          });
          await saveHive(key: "ridePlaces", data: _placesSaved);
          _isQuickPlaceSecondaryOption = false;
          _whereToController.clear();
          setState(() {});
          _unFocusAllNodes();
          await _getRidePlacesHistory();
          setState(() => _isLoading = false);
        } else {
          // saving ride places history
          await _savePlaceToRecent(picked);

          if (_ridePlaceFields == RidePlaceFields.pickUp) {
            _pickUpMap = picked;
            _pickupController.text = picked["name"];
            _goBackToRideMap();
          } else if (_ridePlaceFields == RidePlaceFields.whereTo) {
            // saving quick place
            if (_quickPlace != null) {
              _placesSaved.addAll({
                _quickPlace == QuickPlace.home ? "home" : "work": picked,
              });
              await saveHive(key: "ridePlaces", data: _placesSaved);
            }

            _whereToMap = picked;
            _whereToController.text = picked["name"];
            _goBackToRideMap();
          }
        }

        _placePredictions.clear();
      }
    } else {
      _quickPlace = place;
      String quickType = _quickPlace == QuickPlace.home ? "home" : "work";
      _whereToMap = Map<String, dynamic>.from(_placesSaved[quickType]);
      _whereToController.text = _placesSaved[quickType]["name"];
      _goBackToRideMap();
    }
  }

  Future<void> _onAddMultiStopsPlaces() async {
    if (_currentLocationPlaceDetails == null) {
      setState(() => _isLoading = true);
    }
    RidePickUpModel? model = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RideMultiStopPlaces(
          currentLocationPlaceDetails: _currentLocationPlaceDetails,
          currentLocation: widget.currentLocation,
        ),
      ),
    );
    if (model != null) {
      if (!mounted) return;
      Navigator.pop(context, model);
    }
  }

  void _onRecentPlace(String name) {
    _whereToMap = Map<String, dynamic>.from(_placesSaved["recents"][name]);
    _whereToController.text = name;
    _goBackToRideMap();
  }

  void _onClearpickupText() {
    _pickupController.clear();
    setState(() {});
    _pickupFocusNode!.requestFocus();
  }

  Future<void> _onPlaceTyping(String text, RidePlaceFields type) async {
    if (text.isEmpty) {
      setState(() => _placePredictions = []);
      return;
    }

    _ridePlaceFields = type;

    // Convert geofences data to required format
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

      if (!_isQuickPlaceSecondaryOption) {
        // saving ride places history
        await _savePlaceToRecent(picked);
      }

      if (_ridePlaceFields == RidePlaceFields.pickUp) {
        _pickUpMap = picked;
        _pickupController.text = picked["name"];
        _goBackToRideMap();
      } else if (_ridePlaceFields == RidePlaceFields.whereTo) {
        _whereToMap = picked;
        _whereToController.text = picked["name"];

        if (_isQuickPlaceSecondaryOption) {
          // saving quick place
          _placesSaved.addAll({
            _quickPlace == QuickPlace.home ? "home" : "work": picked,
          });
          await saveHive(key: "ridePlaces", data: _placesSaved);
          _isQuickPlaceSecondaryOption = false;
          _whereToController.clear();
          setState(() {});
          _unFocusAllNodes();
          await _getRidePlacesHistory();
          setState(() => _isLoading = false);
        } else {
          _goBackToRideMap();
        }
      }

      _placePredictions.clear();

      if (!mounted) return;
      setState(() {});
    } on Exception catch (_, e) {
      setState(() => _isLoading = false);
      log("Place picker => ${e.toString()}");
    }
  }

  Future<void> _savePlaceToRecent(Map<String, dynamic> picked) async {
    // saving ride places history
    if (_placesSaved.containsKey("recents")) {
      (_placesSaved["recents"] as Map).addAll({picked["name"]: picked});
    } else {
      _placesSaved.addAll({
        "recents": {picked["name"]: picked}
      });
    }
    await saveHive(key: "ridePlaces", data: _placesSaved);
  }

  Future<void> _goBackToRideMap() async {
    if (_whereToController.text.isNotEmpty && _pickupController.text.isNotEmpty) {
      List<LatLng> locations = [];
      locations.addAll([
        LatLng(_pickUpMap["lat"], _pickUpMap["long"]),
        LatLng(_whereToMap["lat"], _whereToMap["long"]),
      ]);

      Map<String, dynamic> meta = {
        "pickup": _pickUpMap,
        "whereTo": _whereToMap,
        "busStops": [],
        "geofenceId": _whereToMap["geofenceId"] ?? "",
      };
      log(meta.toString());
      RidePickUpModel model = RidePickUpModel.fromJson(meta);

      if (!mounted) return;
      Navigator.pop(context, model);
    }
  }

  void _onTopWidgetSize(Size size) {
    _topWidgetSize = size;
    setState(() {});
  }

  Future<void> _getCurrentLocationDetails() async {
    // setState(() => _isLoading = true);
    _pickupController.text = "My current location";
    _currentLocationPlaceDetails = await getPlaceDetailsFromCoordinatesHomepage(
      widget.currentLocation!.latitude,
      widget.currentLocation!.longitude,
    );
    // setState(() => _isLoading = false);

    if (_currentLocationPlaceDetails != null) {
      Map<String, dynamic> picked = {
        "name": _currentLocationPlaceDetails?.name,
        "address": _currentLocationPlaceDetails!.nearbyPlaceName,
        "long": widget.currentLocation!.longitude,
        "lat": widget.currentLocation!.latitude,
      };

      isCodePlaceName(picked["name"])
          ? picked["name"] = _currentLocationPlaceDetails!.formattedAddress
          : picked["name"] = picked["name"];
      _pickUpMap = picked;
    }

    _pickupController.text = _pickUpMap["name"];

    if (widget.isRecent) {
      _scrollController.animateTo(
        _scrollController.positions.last.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.ease,
      );
    } else {
      _whereToFocusNode!.requestFocus();
    }
  }

  Future<void> _getRidePlacesHistory() async {
    // setState(() => _isLoading = true);
    _placesSaved = (await getHive("ridePlaces")) ?? {};
    setState(() {});
    log("$_placesSaved");
  }
}
