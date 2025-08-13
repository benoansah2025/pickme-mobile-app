import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_polyline_points/flutter_polyline_points.dart' hide TravelMode, Route;
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/customMapInfoWindow.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/dummyCordinateGenerator.dart';
import 'package:pickme_mobile/config/firebase/firebaseAuth.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/mapFunction.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/cancelReasonsModel.dart';
import 'package:pickme_mobile/models/driverDetailsModel.dart';
import 'package:pickme_mobile/models/placeDetailsModel.dart';
import 'package:pickme_mobile/models/rideSelectModel.dart';
import 'package:pickme_mobile/models/ridePickUpModel.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/tripEstimateModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/pages/modules/deliveries/deliveryRunner/deliveryRecipient/deliveryRecipientDetails/deliveryRecipientDetails.dart';
import 'package:pickme_mobile/pages/modules/deliveries/deliveryRunner/deliverySingleMultiOption/widget/delierySendReceiveItemMap.dart';
import 'package:pickme_mobile/pages/modules/deliveries/deliveryRunner/trackDeliveryOrder/trackDeliveryOrder.dart';
import 'package:pickme_mobile/pages/modules/deliveries/deliveryRunner/trackDeliveryOrder/widget/trackDeliveryDriverMap.dart';
import 'package:pickme_mobile/pages/modules/deliveries/personalShopper/trackShopperOrder/trackShopperOrder.dart';
import 'package:pickme_mobile/pages/modules/deliveries/personalShopper/trackShopperOrder/widget/trackDriverMap.dart';
import 'package:pickme_mobile/pages/modules/payments/paymentmethod/paymentmethod.dart';
import 'package:pickme_mobile/pages/modules/rides/rideConfirmAmount/rideConfirmAmount.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/widget/cancelRequestDialog.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/widget/confirmRideSuccessDialog.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/widget/driverFoundBottomWidget.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/widget/selectRideBottomWidget.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/widget/yourTripSummary.dart';
import 'package:pickme_mobile/pages/modules/rides/ridePlaces/ridePlaces.dart';
import 'package:pickme_mobile/providers/cancelReasonsProvider.dart';
import 'package:pickme_mobile/providers/homepageListenerProvider.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'dart:ui' as ui;
import 'package:rxdart/rxdart.dart';

import 'widget/rideDetialsDialog.dart';
import 'widget/rideMapBottomWidget.dart';
import 'widget/rideMapWidget.dart';
import 'widget/stopsDialog.dart';

class RideMap extends StatefulWidget {
  final Position? currentLocation;
  final RideMapNextAction mapNextAction;
  final ServicePurpose servicePurpose;
  final List<LatLng>? trackingPositions;
  final Map<dynamic, dynamic>? deliveryAddresses;
  final TripDetailsModel? onGoingTripDetails;

  const RideMap({
    super.key,
    required this.currentLocation,
    this.mapNextAction = RideMapNextAction.selectRide,
    this.servicePurpose = ServicePurpose.ride,
    this.trackingPositions,
    this.deliveryAddresses,
    this.onGoingTripDetails,
  });

  @override
  State<RideMap> createState() => _RideMapState();
}

class _RideMapState extends State<RideMap> with SingleTickerProviderStateMixin {
  final Repository _repo = new Repository();
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  Position? _currentLocationPosition;
  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionStream;

  BitmapDescriptor? _currentLocationIcon,
      _carIcon,
      _carSmallIcon,
      _okadaIcon,
      _okadaSmallIcon,
      _shopperIcon,
      _pinIcon,
      _destinationIcon,
      _liveDriverIcon;

  final double _zoom = 14.4746;

  static const MarkerId _currentLocationMarkerId = MarkerId('currentLocation');
  bool _showCurrentLocationMaker = true, _showSearchPlaceWidget = true;

  final _fetcher = BehaviorSubject<RidePickUpModel>();
  Sink<RidePickUpModel> get ridePickUpfetcherSink => _fetcher.sink;
  Stream<RidePickUpModel> get ridePickUpStream => _fetcher.stream;
  StreamSubscription<RidePickUpModel>? _ridePickUpStreamSubscription;
  StreamSubscription<Response>? _availableCarsSubscription, _rideSelectSubscription, _selectRideMakeSubscription;
  StreamSubscription<DriverDetailsModel?>? _selectedRideTrackingSubscription;

  RideMapNextAction? _rideNextAction;

  List<LatLng> _locationUnableToZoom = [];

  // adding new Address
  final _newAddressHouseNoController = new TextEditingController();
  final _newAddressLandmarkController = new TextEditingController();
  final _newAddressPhoneController = new TextEditingController();

  Map<dynamic, dynamic> _deliveryAddresses = {};
  Map<dynamic, dynamic> _placesSaved = {};
  Map<String, dynamic> _paymentMethod = {
    "paymentMethod": "CASH",
    "promoCode": "",
    "discountPercentage": 0,
  };

  AnimationController? _animationController;
  late Animation<double> _animation;

  bool _initialMoveCameraPosition = true, _isLoading = false, _showCancelButton = true;
  OverlayEntry? _overlayEntry;
  LatLng? _overlayCordinate;
  String _overlayMsg = "", _tripId = "";

  final FirebaseService _firebaseService = new FirebaseService();

  DriverDetailsModel? _driverDetailsModel;
  RideSelectModel? _rideSelectModel;
  RidePickUpModel? _ridePickUpModel;
  TripDetailsModel? _onGoingTripDetails;
  WorkersInfoModel? _workersDetailsInfoModel;
  Car? _selectedCar;
  Rides? _rideSelected;

  final List<String> _onHoldDriverIdList = [];
  String _tripDuration = "", _tripDistance = "";

  double _cameraBearing = 0.0;

  @override
  void initState() {
    super.initState();
    _repo.fetchCancelReasons(true);

    pauseMainTripDetailsStreaming = true;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController!);

    _rideNextAction = widget.mapNextAction;

    if (widget.currentLocation != null) {
      _currentLocationPosition = widget.currentLocation;
      _currentLocation = LatLng(
        _currentLocationPosition!.latitude,
        _currentLocationPosition!.longitude,
      );

      _getCurrentLocation();
    } else if (widget.trackingPositions != null) {
      _currentLocation = LatLng(
        widget.trackingPositions!.first.latitude,
        widget.trackingPositions!.first.longitude,
      );
    } else {
      throw Exception(
        "Current location position or tracking position, can't be null",
      );
    }
    _loadCustomMarkerAssets();

    _getRidePlacesHistory();

    // search ride for personal shopper and delivery runner single
    if ((widget.servicePurpose == ServicePurpose.personalShopper &&
            widget.mapNextAction != RideMapNextAction.trackDriver) ||
        (widget.mapNextAction == RideMapNextAction.searchingDriver &&
            (widget.servicePurpose == ServicePurpose.deliveryRunnerSingle ||
                widget.servicePurpose == ServicePurpose.deliveryRunnerMultiple) &&
            widget.deliveryAddresses != null)) {
      _showSearchPlaceWidget = false;
      _onSearchDeliveryRides();
    }

    if (widget.mapNextAction == RideMapNextAction.trackDriver) {
      _showSearchPlaceWidget = false;
      _trackDriver();
    }

    if (widget.currentLocation != null) {
      _deliveryAddresses = {
        DeliveryAccessLocation.pickUpLocation: {
          "name": "",
          "long": widget.currentLocation!.longitude,
          "lat": widget.currentLocation!.latitude,
        }
      };
    }

    if (widget.mapNextAction == RideMapNextAction.deliverySendItem ||
        widget.mapNextAction == RideMapNextAction.deliveryReceiveItem) {
      _showSearchPlaceWidget = false;
    }

    _onGoingTripDetails = widget.onGoingTripDetails;
    _onOnGoingTrip();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _positionStream = null;
    _ridePickUpStreamSubscription?.cancel();
    _ridePickUpStreamSubscription = null;
    _animationController?.dispose();
    _animationController = null;
    _availableCarsSubscription?.cancel();
    _availableCarsSubscription = null;
    _selectRideMakeSubscription?.cancel();
    _selectRideMakeSubscription = null;
    _selectedRideTrackingSubscription?.cancel();
    _selectRideMakeSubscription = null;
    _rideSelectSubscription?.cancel();
    _rideSelectSubscription = null;

    // Safely remove overlay if it exists
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (e) {
        // Handle or log the error if needed
        debugPrint("Error removing overlay entry: $e");
      }
      _overlayEntry = null;
    }

    pauseMainTripDetailsStreaming = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool invoke) {
        if (invoke) return;
        if (_onGoingTripDetails != null) {
          navigation(context: context, pageName: "back");
        } else {
          if (_showCancelButton) _onBack();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            rideMapWidget(
              context: context,
              currentLocation: _currentLocation!,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) => _onMapCreated(
                controller,
              ),
              zoom: _zoom,
              onBack: () => _onBack(),
              onCurrentLocation: () => _onMoveCameraToCurrentLocation(),
              onQuickPlace: (QuickPlace place) => _onQuickPlace(place),
              showSearchPlace: _showSearchPlaceWidget,
              polylines: _polylines,
              rideNextAction: _rideNextAction!,
              newAddressSave: () => _onNewAddressSave(),
              onChangeDeliveryLocation: (DeliveryAccessLocation value) => _onChangeDeliveryLocation(value),
              newAddressHouseNoController: _newAddressHouseNoController,
              newAddressLandmarkController: _newAddressLandmarkController,
              newAddressPhoneController: _newAddressPhoneController,
              deliveryAddresses: _deliveryAddresses,
              onCameraMove: (CameraPosition position) => _onCameraMove(position),
              showBackButton: _onGoingTripDetails != null ? true : _showCancelButton,
            ),
            if (_isLoading) customLoadingPage(),
          ],
        ),
        bottomNavigationBar: _isLoading
            ? null
            : !_showSearchPlaceWidget
                ? _rideNextAction == RideMapNextAction.deliverySendItem ||
                        _rideNextAction == RideMapNextAction.deliveryReceiveItem
                    ? deliverySendReceiveItemMap(
                        context: context,
                        onChangeLocation: (DeliveryAccessLocation value) => _onChangeDeliveryLocation(
                          value,
                        ),
                        onDeliveryStartProceed: () => _onDeliveryStartProceed(),
                        deliveryAddresses: _deliveryAddresses,
                        rideNextAction: _rideNextAction!,
                      )
                    : _rideNextAction == RideMapNextAction.selectRide
                        ? selectRideBottomWidget(
                            context: context,
                            onPaymentMethod: () => _onPaymentMethod(),
                            onRequest: () => _onSelectRideMakeRequest(),
                            rideSelectModel: _rideSelectModel,
                            onRideSelected: (Rides ride) => _onRideSelected(ride),
                            rideSelected: _rideSelected,
                            paymentMethod: _paymentMethod,
                            ridePickUpModel: _ridePickUpModel,
                          )
                        : _rideNextAction == RideMapNextAction.yourTripSummary
                            ? yourTripSummaryWidget(
                                context: context,
                                onPaymentMethod: () => _onPaymentMethod(),
                                onSearchDrivers: () => _onSearchDrivers(),
                                paymentMethod: _paymentMethod,
                                ridePickUpModel: _ridePickUpModel,
                                onStops: () => _showStopsDialog(),
                                selectedCar: _selectedCar,
                                onSelectCar: (Car data, String? tap) => _onSelectTripCar(data, tap),
                              )
                            : _rideNextAction == RideMapNextAction.trackDriver
                                ? widget.servicePurpose == ServicePurpose.personalShopper
                                    ? trackDriverMap(
                                        context: context,
                                        onCall: () {},
                                        onChat: () {},
                                      )
                                    : trackDeliveryDriverMap(
                                        context: context,
                                        onCall: () {},
                                        onChat: () {},
                                      )
                                : driverFoundBottomWidget(
                                    context: context,
                                    onChat: () {},
                                    onCall: (String phone) => callLauncher("tel: $phone"),
                                    onConfirm: () => _onConfirmDriverFoundDialog(),
                                    rideNextAction: _rideNextAction!,
                                    onCancelRequest: () => _onCancelRequestDialog(),
                                    onConfirmArrivedDestination: () => _onConfirmArrivedDestination(),
                                    servicePurpose: widget.servicePurpose,
                                    onTrackDeliveryOrder: () => _onTrackDeliveryOrder(),
                                    rideSelected: _rideSelected,
                                    driverDetailsModel: _driverDetailsModel,
                                    ridePickUpModel: _ridePickUpModel,
                                    onGoingTripDetails: _onGoingTripDetails,
                                    workersDetailsInfoModel: _workersDetailsInfoModel,
                                    showCancelButton: _showCancelButton,
                                    tripDuration: _tripDuration,
                                    tripDistance: _tripDistance,
                                  )
                : null,
      ),
    );
  }

  final Set<Marker> _carMarkers = {};
  void _showAvailableCars() {
    _tripDistance = "";
    _tripDuration = "";

    // searching for rides
    Map<String, dynamic> reqBody = {
      "action": HttpActions.searchRide,
      "riderId": userModel!.data!.user!.userid,
      "latitude": _currentLocation!.latitude,
      "longitude": _currentLocation!.longitude,
    };

    // stream all available drivers around
    final responseStream = _firebaseService.searchRideStream(reqBody);
    final broadcastStream = responseStream.asBroadcastStream(onCancel: (StreamSubscription<Response> subscription) {
      log("_showAvailableCars cancel $_rideNextAction");
    }, onListen: (StreamSubscription<Response> subscription) {
      log("_showAvailableCars listen $_rideNextAction");
    });

    _availableCarsSubscription = broadcastStream.listen((Response response) {
      int statusCode = response.statusCode;
      Map<String, dynamic> driversBody = jsonDecode(response.body);
      RideSelectModel rideSelectModel = RideSelectModel.fromJson(driversBody);

      log(driversBody["msg"].toString());
      if (statusCode != 200) {
        log(driversBody["error"].toString());
        toastContainer(text: driversBody["msg"]);
        return;
      }

      // display drivers around
      List<Rides> driversList = rideSelectModel.data!.drivers!;

      // Clear only car markers
      _markers.removeWhere((marker) => _carMarkers.contains(marker));
      _carMarkers.clear();

      List<LatLng> carLatLngList = [];
      carLatLngList.clear();

      // Update car markers
      for (int x = 0; x < driversList.length; ++x) {
        double lat = driversList[x].latitute!;
        double long = driversList[x].longitude!;
        double heading = driversList[x].heading!;
        String vehicleType = driversList[x].data!.vehicleType!;

        carLatLngList.add(LatLng(lat, long));

        log("duration ${formatDuration(driversList[x].duration ?? 0)}");

        Marker carMarker = Marker(
          markerId: MarkerId("carsAround$x"),
          position: LatLng(lat, long),
          icon: vehicleType == "1" ? _carSmallIcon! : _okadaSmallIcon!,
          anchor: const Offset(0.5, 0.5),
          rotation: heading,
          infoWindow: InfoWindow(title: "${formatDuration(driversList[x].duration ?? 0)} away"),
        );

        _carMarkers.add(carMarker);
      }

      // Add updated car markers to the main markers set
      _markers.addAll(_carMarkers);

      if (mounted) setState(() {});
    });
  }

  void _onSelectTripCar(Car data, String? tap) {
    if (tap == null) {
      _selectedCar = data;
      setState(() {});
    } else {
      showDialog(
        context: context,
        builder: (context) => rideDetialsDialog(
          context: context,
          onClose: () => Navigator.pop(context),
          data: data,
        ),
      );
    }
  }

  void _showStopsDialog() {
    // hide overlay
    _removeOverlay();
    
    showDialog(
      context: context,
      builder: (context) => stopsDialog(
        context: context,
        ridePickUpModel: _ridePickUpModel!,
      ),
    );
  }

  Future<void> _onOnGoingTrip() async {
    if (_onGoingTripDetails == null) return;

    await _loadCustomMarkerAssets();
    await _onQuickPlace(QuickPlace.onGoingTrip);
    await _onSelectRideMakeRequest();
  }

  Future<void> _getRidePlacesHistory() async {
    setState(() => _isLoading = true);
    _placesSaved = (await getHive("ridePlaces")) ?? {};
    setState(() => _isLoading = false);
  }

  Future<bool> _onCancelRequestDialog({isBack = false}) async {
    if (_rideSelected != null || (_onGoingTripDetails != null && !isBack)) {
      if (cancelReasonsModel == null) {
        await _repo.fetchCancelReasons(true);
      }

      if (!mounted) return false;
      return showDialog<bool>(
        context: context,
        builder: (context) {
          CancelReasonData? reason;
          return StatefulBuilder(builder: (context, dialogSetState) {
            return cancelRequestDialog(
              context: context,
              onCancelRequest: () {
                if (reason == null) {
                  toastContainer(text: "Select reason to continue", backgroundColor: BColors.red);
                  return;
                }
                Navigator.pop(context);
                _onCancelRequest(isBack, cancelReason: reason);
              },
              onSelectReason: (CancelReasonData data) {
                reason = data;
                dialogSetState(() {});
              },
              reason: reason,
            );
          });
        },
      ).then((value) => value ?? false); // Ensure the dialog returns a bool;
    } else {
      if (_onGoingTripDetails == null) {
        return _onCancelRequest(isBack);
      } else {
        navigation(context: context, pageName: "back");
        return false;
      }
    }
  }

  void _onRideSelected(Rides ride) {
    _rideSelected = ride;
    if (!mounted) return;
    setState(() {});
  }

  void _onCameraMove(CameraPosition position) {
    if (_overlayCordinate == null && _controller == null && _overlayEntry == null) return;

    _showCustomInfoWindow();
  }

  Future<void> _onBack() async {
    if (!_showSearchPlaceWidget && widget.servicePurpose == ServicePurpose.ride) {
      _removeOverlay();

      bool cancel = await _onCancelRequestDialog(isBack: true);
      if (!cancel) {
        return;
      }

      _rideSelectSubscription?.cancel();
      _animationController?.stop();
      _initialMoveCameraPosition = true;
      _getCurrentLocation();
      setState(() {});
      return;
    }
    navigation(context: context, pageName: "back");
  }

  void _onTrackDeliveryOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackDeliveryOrder(
          servicePurpose: widget.servicePurpose,
          deliveryAddresses: widget.deliveryAddresses!,
        ),
      ),
    );
  }

  void _onDeliveryStartProceed() {
    if (_deliveryAddresses[DeliveryAccessLocation.pickUpLocation] != null &&
        _deliveryAddresses[DeliveryAccessLocation.whereToLocation] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeliveryRecipientDetails(
            rideMapNextAction: widget.mapNextAction,
            servicePurpose: widget.servicePurpose,
            deliveryAddresses: _deliveryAddresses,
          ),
        ),
      );
    } else {
      toastContainer(
        text: "Enter location to continue",
        backgroundColor: BColors.red,
      );
    }
  }

  Future<void> _onChangeDeliveryLocation(DeliveryAccessLocation value) async {
    // var place = await PluginGooglePlacePicker.showAutocomplete(
    //   mode: PlaceAutocompleteMode.MODE_OVERLAY,
    //   countryCode: "GH",
    // );
    // String placeName = place.name ?? "Null place name!";

    // if (value == DeliveryAccessLocation.pickUpLocation) {
    //   _deliveryAddresses.addAll({
    //     DeliveryAccessLocation.pickUpLocation: {
    //       "name": placeName,
    //       "long": place.longitude,
    //       "lat": place.latitude,
    //     }
    //   });
    // } else {
    //   _deliveryAddresses.addAll({
    //     DeliveryAccessLocation.whereToLocation: {
    //       "name": placeName,
    //       "long": place.longitude,
    //       "lat": place.latitude,
    //     }
    //   });
    // }

    if (widget.mapNextAction == RideMapNextAction.deliverySendItem ||
        widget.mapNextAction == RideMapNextAction.deliveryReceiveItem) {
      LatLng pickUpLocation = LatLng(
        _deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["lat"],
        _deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["long"],
      );
      LatLng? whereToLocation = _deliveryAddresses[DeliveryAccessLocation.whereToLocation] != null
          ? LatLng(
              _deliveryAddresses[DeliveryAccessLocation.whereToLocation]["lat"],
              _deliveryAddresses[DeliveryAccessLocation.whereToLocation]["long"],
            )
          : null;

      Marker pickUpLocationMarker = Marker(
        markerId: const MarkerId("pickUpLocation"),
        position: pickUpLocation,
        infoWindow: InfoWindow(
          title: _deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["name"] != null
              ? "My Current Location"
              : _deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["name"],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      Marker? whereToMarker = whereToLocation != null
          ? Marker(
              markerId: const MarkerId("whereToLocation"),
              position: whereToLocation,
              infoWindow: InfoWindow(
                title: _deliveryAddresses[DeliveryAccessLocation.whereToLocation]["name"],
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet,
              ),
            )
          : null;

      await _setDeliveryMarkersPolylinesCarsToMap(
        pickUpLocationMarker: pickUpLocationMarker,
        whereToMarker: whereToMarker,
        pickUpLocation: pickUpLocation,
        whereToLocation: whereToLocation,
      );
    }
    setState(() {});
  }

  Future<void> _setDeliveryMarkersPolylinesCarsToMap({
    required Marker pickUpLocationMarker,
    required Marker? whereToMarker,
    required LatLng pickUpLocation,
    required LatLng? whereToLocation,
  }) async {
    _markers.clear();
    _showCurrentLocationMaker = false;
    _polylines.clear();

    _markers.addAll({
      pickUpLocationMarker,
      if (whereToMarker != null) whereToMarker,
    });

    if (whereToMarker != null) {
      Set<Polyline>? polySet = await fetchRouteAndSetPolyline(
        polylineKey: 'deliveryPolyline',
        color: BColors.primaryColor,
        locations: [pickUpLocation, whereToLocation!],
      );

      if (polySet != null) {
        _polylines = polySet;
      } else {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('deliveryPolyline'),
            visible: true,
            points: [pickUpLocation, whereToLocation],
            color: BColors.primaryColor,
            width: 5,
          ),
        );
      }
      setState(() {});

      _zoomToFitMarkers(
        point1: pickUpLocation,
        point2: whereToLocation,
        padding: 100,
      );

      Future.delayed(const Duration(seconds: 1), () {
        _controller?.showMarkerInfoWindow(const MarkerId('whereToLocation'));
      });
    }
  }

  Future<void> _trackDriver() async {
    // location 1
    Marker deliveryMarker = Marker(
      markerId: const MarkerId("deliveryLocation"),
      position: widget.trackingPositions![0],
      infoWindow: const InfoWindow(title: "Delivery Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    );

    // loading shopper asset image
    final Uint8List shopperIcon = await _getBytesFromAsset(
      widget.servicePurpose == ServicePurpose.personalShopper ? Images.mapShopper : Images.mapDeliveryRunner,
      100,
    );
    _shopperIcon = BitmapDescriptor.bytes(shopperIcon);
    // location 2
    Marker driverMarker = Marker(
      markerId: const MarkerId("driverLocation"),
      position: widget.trackingPositions![1],
      infoWindow: const InfoWindow(title: "Driver Location"),
      icon: _shopperIcon!,
    );

    _markers.addAll({deliveryMarker, driverMarker});

    Set<Polyline>? polySet = await fetchRouteAndSetPolyline(
      locations: widget.trackingPositions!,
      polylineKey: 'trackingPolyline',
      color: BColors.primaryColor,
    );

    if (polySet != null) {
      _polylines = polySet;
    } else {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('trackingPolyline'),
          visible: true,
          points: [widget.trackingPositions![0], widget.trackingPositions![1]],
          color: BColors.primaryColor,
          width: 5,
        ),
      );
    }
    setState(() {});

    await _zoomToFitMarkers(point1: widget.trackingPositions![0], point2: widget.trackingPositions![1]);
  }

  Future<bool> _onCancelRequest(
    bool isBack, {
    CancelReasonData? cancelReason,
    bool isCancelBySystem = false,
    bool isTimeoutNoDriverFound = false,
  }) async {
    if (widget.servicePurpose == ServicePurpose.deliveryRunnerSingle ||
        widget.servicePurpose == ServicePurpose.deliveryRunnerMultiple) {
      // TODO: ask if this is fexible because booking have being done
      return true;
    }

    // trip cancel
    if (_rideSelected != null || (_onGoingTripDetails != null && !isBack)) {
      Map<String, dynamic> reqBody = {
        "action": HttpActions.bookRide,
        "driverId": _onGoingTripDetails != null ? _onGoingTripDetails!.driverId! : _rideSelected!.driverId,
        "riderId": userModel!.data!.user!.userid,
        "cancelledBy": isTimeoutNoDriverFound || isCancelBySystem ? "SYSTEM" : "RIDER",
      };

      setState(() => _isLoading = true);

      // making cancel request api
      final httpResult = await httpChecker(
        httpRequesting: () => httpRequesting(
          endPoint: HttpServices.noEndPoint,
          method: HttpMethod.post,
          httpPostBody: {
            "action": HttpActions.cancelRequest,
            "customerId": isTimeoutNoDriverFound || isCancelBySystem ? "SYSTEM" : userModel!.data!.user!.userid,
            "cancelReason": isCancelBySystem
                ? "SYSTEM"
                : isTimeoutNoDriverFound
                    ? "TIMEOUT_NO_DRIVER_FOUND"
                    : cancelReason?.title ?? "",
          },
        ),
      );

      log(httpResult.toString());

      Response response = await _firebaseService.cancelTrip(reqBody);
      setState(() => _isLoading = false);

      int statusCode = response.statusCode;
      Map<String, dynamic> body = jsonDecode(response.body);

      log(body.toString());

      if (statusCode == 401) {
        toastContainer(text: body["msg"], backgroundColor: BColors.red);
        return false;
      }
    }

    _availableCarsSubscription?.cancel();
    _availableCarsSubscription = null;
    _selectRideMakeSubscription?.cancel();
    _selectRideMakeSubscription = null;
    _selectedRideTrackingSubscription?.cancel();
    _selectRideMakeSubscription = null;

    _onGoingTripDetails = null;
    _rideSelectModel = null;
    _rideSelected = null;
    _ridePickUpModel = null;
    _rideNextAction = RideMapNextAction.selectRide;
    _markers.clear();
    _polylines.clear();
    _showSearchPlaceWidget = true;
    _showCurrentLocationMaker = true;
    _onMoveCameraToCurrentLocation();

    setState(() {});

    if (widget.servicePurpose == ServicePurpose.personalShopper) {
      if (!mounted) return true;
      navigation(context: context, pageName: "back");
    }
    return true;
  }

  void _onNewAddressSave() {
    //TODO: fix controller values not
    Map<dynamic, dynamic> meta = {
      ..._deliveryAddresses,
      "houseNo": _newAddressHouseNoController.text,
      "landmark": _newAddressLandmarkController.text,
      "phone": _newAddressPhoneController.text,
    };

    Navigator.pop(context, meta);
  }

  void _onConfirmArrivedDestination() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => RideConfirmAmount(tripId: _tripId),
        ),
        (Route<dynamic> route) => false);
  }

  void _trackDeliveryOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TrackShopperOrder(),
      ),
    );
  }

  Future<void> _onSearchDeliveryRides() async {
    _removeOverlay();

    _rideNextAction = RideMapNextAction.searchingDriver;
    setState(() {});

    // TODO: sample code
    await Future.delayed(const Duration(seconds: 3), () async {
      _rideNextAction = RideMapNextAction.driverFound;

      if (widget.servicePurpose == ServicePurpose.personalShopper) {
        // remove current location marker
        _markers.removeWhere(
          (marker) => marker.markerId == _currentLocationMarkerId,
        );
        _showSearchPlaceWidget = false;
        _showCurrentLocationMaker = false;

        Marker myLocationMarker = Marker(
          markerId: const MarkerId("myLocation"),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: "My Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );

        // shop location
        LatLng shopLatLng = const LatLng(5.6095743, -0.2230998);
        Marker shopMarker = Marker(
          markerId: const MarkerId("shopLocation"),
          position: shopLatLng,
          infoWindow: const InfoWindow(title: "Shop location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );

        _markers.addAll({
          myLocationMarker,
          shopMarker,
        });

        Set<Polyline>? polySet = await fetchRouteAndSetPolyline(
          polylineKey: 'pickPolyline',
          color: BColors.primaryColor,
          locations: [_currentLocation!, shopLatLng],
        );

        if (polySet != null) {
          _polylines = polySet;
        } else {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('pickPolyline'),
              visible: true,
              points: [_currentLocation!, shopLatLng],
              color: BColors.primaryColor,
              width: 5,
            ),
          );
        }
        setState(() {});

        // display drivers around
        List<DummyCordinateGenerator> dummyCordinates = generateSurroundingCoordinates(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );
        List<Marker> carsAroundList = [];
        for (int x = 0; x < dummyCordinates.length; ++x) {
          Marker busStopMarker = Marker(
            markerId: MarkerId("carsAround$x"),
            position: LatLng(
              dummyCordinates[x].latitude,
              dummyCordinates[x].longitude,
            ),
            icon: _carIcon!,
            anchor: const Offset(0.5, 0.5),
            rotation: dummyCordinates[x].bearing,
          );
          carsAroundList.add(busStopMarker);
        }
        _markers.addAll({for (Marker carMark in carsAroundList) carMark});

        if (mounted) setState(() {});

        _zoomToFitMarkers(point1: _currentLocation!, point2: shopLatLng);

        Future.delayed(const Duration(seconds: 1), () {
          _controller?.showMarkerInfoWindow(const MarkerId('shopLocation'));
        });
      } else if (widget.servicePurpose == ServicePurpose.deliveryRunnerSingle ||
          widget.servicePurpose == ServicePurpose.deliveryRunnerMultiple) {
        LatLng pickUpLocation = LatLng(
          widget.deliveryAddresses![DeliveryAccessLocation.pickUpLocation]["lat"],
          widget.deliveryAddresses![DeliveryAccessLocation.pickUpLocation]["long"],
        );
        LatLng whereToLocation = LatLng(
          widget.deliveryAddresses![DeliveryAccessLocation.whereToLocation]["lat"],
          widget.deliveryAddresses![DeliveryAccessLocation.whereToLocation]["long"],
        );

        Marker pickUpLocationMarker = Marker(
          markerId: const MarkerId("pickUpLocation"),
          position: pickUpLocation,
          infoWindow: InfoWindow(
            title: widget.deliveryAddresses![DeliveryAccessLocation.pickUpLocation]["name"] != null
                ? "My Current Location"
                : widget.deliveryAddresses![DeliveryAccessLocation.pickUpLocation]["name"],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );

        Marker whereToMarker = Marker(
          markerId: const MarkerId("whereToLocation"),
          position: whereToLocation,
          infoWindow: InfoWindow(
            title: widget.deliveryAddresses![DeliveryAccessLocation.whereToLocation]["name"],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        );

        await _setDeliveryMarkersPolylinesCarsToMap(
          pickUpLocationMarker: pickUpLocationMarker,
          whereToMarker: whereToMarker,
          pickUpLocation: pickUpLocation,
          whereToLocation: whereToLocation,
        );
      }
      setState(() {});
    });
  }

  Future<void> _onSelectRideMakeRequest() async {
    if (_rideSelected == null && _onGoingTripDetails == null) {
      toastContainer(text: "Select ride to proceed", backgroundColor: BColors.red);
      return;
    }

    _removeOverlay();

    _rideNextAction = RideMapNextAction.searchingDriver;
    setState(() {});

    FireAuth firebaseAuth = new FireAuth();
    String? token = await firebaseAuth.getToken();

    String driverId = _rideNextAction == RideMapNextAction.drivingToDestination
        ? _driverDetailsModel!.data!.driverId!
        : _onGoingTripDetails != null
            ? _onGoingTripDetails!.driverId!
            : _rideSelected!.data!.driverId!;

    // searching for rides
    Map<String, dynamic> reqBody = {
      "action": HttpActions.bookRide,
      "riderId": userModel!.data!.user!.userid,
      "riderPhone": userModel!.data!.user!.phone,
      "riderName": userModel!.data!.user!.name,
      "riderPicture": userModel!.data!.user!.picture,
      "riderFirebaseKey": token,
      "riderLocationInText": _ridePickUpModel!.pickup!.name,
      "riderNearbyLocation": _ridePickUpModel!.pickup!.address,
      "riderPosition": {
        "geopoint": [_ridePickUpModel!.pickup!.lat, _ridePickUpModel!.pickup!.long],
      },
      "driverId": _onGoingTripDetails != null ? _onGoingTripDetails!.driverId : _rideSelected!.driverId,
      "driverPhoto": _onGoingTripDetails != null ? _onGoingTripDetails!.driverPhoto : _rideSelected!.data!.driverPhoto,
      "driverName": _onGoingTripDetails != null ? _onGoingTripDetails!.driverName : _rideSelected!.data!.driverName,
      "driverPhone": _onGoingTripDetails != null ? _onGoingTripDetails!.driverPhone : _rideSelected!.data!.driverPhone,
      "destinationPosition": {
        "geopoint": [_ridePickUpModel!.whereTo!.lat, _ridePickUpModel!.whereTo!.long],
      },
      "destinationGeofenceId": _ridePickUpModel!.whereTo!.geofenceId,
      "stops": [
        for (var stop in _ridePickUpModel!.busStops!)
          {
            "geopoint": [stop.lat, stop.long],
            "geofenceId": stop.geofenceId,
            "name": stop.name,
            "address": stop.address,
          }
      ],
      "destinationInText": _ridePickUpModel!.whereTo!.name,
      "paymentMethod":
          _onGoingTripDetails != null ? _onGoingTripDetails!.paymentMethod : _paymentMethod["paymentMethod"],
      "promoCode": _onGoingTripDetails != null ? _onGoingTripDetails!.promoCode : _paymentMethod["promoCode"],
      "discountPercentage":
          _onGoingTripDetails != null ? _onGoingTripDetails!.discountPercentage : _paymentMethod["discountPercentage"],
      "estimatedTotalAmount":
          _onGoingTripDetails != null ? _onGoingTripDetails!.estimatedTotalAmount : _rideSelected!.totalFee,
      "vehicleTypeBaseFare":
          _onGoingTripDetails != null ? _onGoingTripDetails!.vehicleTypeBaseFare : _rideSelected!.vehicleTypeBaseFare,
      "newRideRequest": _onGoingTripDetails == null,
      "onGoingTripId": _onGoingTripDetails?.tripId,
      "serviceType": "ride",
    };

    _workersDetailsInfoModel = await WorkersInfoProvider().fetch(userId: driverId);
    setState(() {});

    final bookResponseStream = _firebaseService.bookRideStream(reqBody);
    final bookBroadcastStream =
        bookResponseStream.asBroadcastStream(onCancel: (StreamSubscription<Response> subscription) {
      log("_onSelectRideMakeRequest bookBroadcastStream cancel ${subscription.toString()}");
    }, onListen: (StreamSubscription<Response> subscription) {
      log("_onSelectRideMakeRequest bookBroadcastStream listen ${subscription.toString()}");
    });

    _selectRideMakeSubscription = bookBroadcastStream.listen(
      (Response response) async {
        if (!mounted) {
          _selectRideMakeSubscription?.cancel();
          _selectRideMakeSubscription = null;
          return;
        }

        int statusCode = response.statusCode;
        Map<String, dynamic> body = jsonDecode(response.body);

        log(body.toString());

        if (statusCode != 200) {
          _selectRideMakeSubscription?.cancel();
          _selectedRideTrackingSubscription?.cancel();

          log(body["error"].toString());

          // search for new driver
          if (statusCode == 300) {
            String onHoldDriverId = body["driverId"];
            _onHoldDriverIdList.add(onHoldDriverId);
            _rideSelectModel = null;
            _onSearchDrivers();
            return;
          }

          // trip timeout
          if (statusCode == 408) {
            // cancel ride request
            await _onCancelRequest(false, isCancelBySystem: true);

            if (!mounted) return;
            infoDialog(
              context: context,
              type: PanaraDialogType.normal,
              text: body["msg"],
              confirmBtnText: "Ok",
            );
            return;
          }

          // cancel ride request
          _onBack();

          if (!mounted) return;
          infoDialog(
            context: context,
            type: statusCode == 401 ? PanaraDialogType.normal : PanaraDialogType.error,
            text: body["msg"],
            confirmBtnText: "Ok",
          );

          return;
        }

        String driverStatus = body["data"]["status"];

        if (driverStatus == "ARRIVED-PICKUP") {
          _rideNextAction = RideMapNextAction.driverArrived;
        } else if (driverStatus == "TRIP-STARTED") {
          _rideNextAction = RideMapNextAction.drivingToDestination;
        } else if (driverStatus == "TRIP-ENDED") {
          _rideNextAction = RideMapNextAction.arrivedDestination;
          _tripId = body["data"]["tripId"];
        } else {
          _rideNextAction = RideMapNextAction.driverFound;
          String actionDate = body["data"]["actionDate"];
          _onCancellationTimer(actionDate);
          if (_onGoingTripDetails == null) _onConfirmDriverFoundDialog();
          _rideNextAction = RideMapNextAction.bookingSuccess;
        }
        if (mounted) setState(() {});
      },
      onError: (error) {
        log("Error in booking stream: $error");
      },
    );

    final locationResposeStream = _firebaseService.getDriverLocationDetails(driverId);
    final locationBroadcastStream =
        locationResposeStream.asBroadcastStream(onCancel: (StreamSubscription<DriverDetailsModel?> subscription) {
      log("_onSelectRideMakeRequest locationResposeStream cancel ${subscription.toString()}");
    }, onListen: (StreamSubscription<DriverDetailsModel?> subscription) {
      log("_onSelectRideMakeRequest locationResposeStream listen ${subscription.toString()}");
    });

    _selectedRideTrackingSubscription = locationBroadcastStream.listen(
      (DriverDetailsModel? model) async {
        if (!mounted) {
          _selectedRideTrackingSubscription?.cancel();
          _selectedRideTrackingSubscription = null;
          return;
        }

        if (model == null) {
          toastContainer(text: "Unable to track driver location", backgroundColor: BColors.red);
          _selectedRideTrackingSubscription!.cancel();
          return;
        }

        _driverDetailsModel = model;
        if (mounted) setState(() {});

        // checking if trip is completed or ended
        if (_rideNextAction == RideMapNextAction.arrivedDestination) {
          _selectedRideTrackingSubscription!.cancel();
          return;
        }

        Set<Marker> carMarkers = {};
        for (var marker in _markers) {
          if (marker.mapsId.value.contains("carsAround")) {
            carMarkers.add(marker);
          }
        }

        // clear any other car on map
        _markers.removeWhere((marker) => carMarkers.contains(marker));
        carMarkers.clear();

        // busstop locations
        List<LatLng> busStopList = [];

        for (int x = 0; x < _driverDetailsModel!.currentRideDetails!.stops!.length; ++x) {
          LatLng bLg = LatLng(
            _driverDetailsModel!.currentRideDetails!.stops![x].geopoint!.latitude,
            _driverDetailsModel!.currentRideDetails!.stops![x].geopoint!.longitude,
          );
          busStopList.add(bLg);
        }

        GeoPoint driverGeopoint = model.position!.geopoint!;
        LatLng driverLatLng = LatLng(driverGeopoint.latitude, driverGeopoint.longitude);

        // String vehicleType = model.data!.vehicleType!;

        Marker carMarker = Marker(
          markerId: const MarkerId("carsAround"),
          position: driverLatLng,
          // icon: vehicleType == "1" ? _carIcon! : _okadaIcon!,
          icon: _liveDriverIcon!,
          anchor: const Offset(0.5, 0.5),
          rotation: model.position!.heading!,
        );
        carMarkers.add(carMarker);

        // Add updated car markers to the main markers set
        _markers.addAll(carMarkers);

        if (mounted) setState(() {});

        GeoPoint riderGeopoint = model.currentRideDetails?.riderPosition ??
            GeoPoint(_currentLocation!.latitude, _currentLocation!.longitude);
        GeoPoint destinationGeopoint = model.currentRideDetails?.destinationPosition ??
            GeoPoint(_ridePickUpModel!.whereTo!.lat!, _ridePickUpModel!.whereTo!.lat!);
        LatLng destinationLatLng = LatLng(destinationGeopoint.latitude, destinationGeopoint.longitude);

        if (_rideNextAction == RideMapNextAction.bookingSuccess ||
            _rideNextAction == RideMapNextAction.searchingDriver ||
            _rideNextAction == RideMapNextAction.driverFound) {
          _zoomToFitMarkers(
            point1: LatLng(riderGeopoint.latitude, riderGeopoint.longitude),
            point2: _currentLocation!,
            additionalPoints: [driverLatLng],
            padding: 130,
          );

          final duration = await getDurationInSeconds([_currentLocation!, driverLatLng]);
          _tripDuration = "${formatDuration(duration)} away";

          final GeoFirePoint pickupLocation = GeoFirePoint(
            GeoPoint(_currentLocation!.latitude, _currentLocation!.longitude),
          );
          final double destinationDistanceInKm = pickupLocation.distanceBetweenInKm(
            geopoint: GeoPoint(driverLatLng.latitude, driverLatLng.longitude),
          );
          _tripDistance = destinationDistanceInKm.toStringAsFixed(2);
          if (mounted) setState(() {});
        } else {
          final duration = await getDurationInSeconds([driverLatLng, destinationLatLng]);
          _tripDuration = "${formatDuration(duration)} away";

          final GeoFirePoint driverLocation = GeoFirePoint(
            GeoPoint(driverLatLng.latitude, driverLatLng.longitude),
          );
          final double destinationDistanceInKm = driverLocation.distanceBetweenInKm(
            geopoint: GeoPoint(destinationLatLng.latitude, destinationLatLng.longitude),
          );
          _tripDistance = destinationDistanceInKm.toStringAsFixed(2);
          if (mounted) setState(() {});

          // ride route
          String polylinePoints = model.points!;

          // Clear existing polylines
          _polylines.clear();

          if (polylinePoints.isNotEmpty) {
            final decodedPath = PolylinePoints.decodePolyline(polylinePoints);

            // Add a polyline to the map
            _polylines.add(Polyline(
              polylineId: const PolylineId('pickPolyline'),
              visible: true,
              points: decodedPath.map((e) => LatLng(e.latitude, e.longitude)).toList(),
              color: BColors.primaryColor,
              width: 5,
            ));

            _updateDirectionCameraBearing(decodedPath, driverLatLng);

            if (mounted) setState(() {});
          }
        }
      },
      onError: (error) {
        log("Error in driver location tracking stream: $error");
      },
    );
  }

  void _updateDirectionCameraBearing(List<PointLatLng> decodedPath, LatLng driverPosition) {
    if (!mounted) return;

    if (decodedPath.length > 1) {
      final firstStep = decodedPath.first;
      double bearing = Geolocator.bearingBetween(
        driverPosition.latitude,
        driverPosition.longitude,
        firstStep.latitude,
        firstStep.longitude,
      );
      if (mounted) {
        setState(() {
          _cameraBearing = bearing;
        });
      }
      _animateDirectionCameraToCurrentLocation(driverPosition);
    }
  }

  Future<void> _animateDirectionCameraToCurrentLocation(LatLng driverPosition) async {
    if (!mounted) return;

    if (_currentLocation != null && _controller != null) {
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              driverPosition.latitude,
              driverPosition.longitude,
            ),
            zoom: 18,
            bearing: _cameraBearing,
          ),
        ),
      );
    }
  }

  void _onCancellationTimer(String actionDate) {
    DateTime inputDate = DateTime.parse(actionDate);

    Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime currentDate = DateTime.now();

      Duration timeDiff = currentDate.difference(inputDate);
      debugPrint("Time difference for ride cancel ${timeDiff.inSeconds} seconds");

      if (timeDiff.inSeconds >= Properties.cancelButtonTimerInSec) {
        _showCancelButton = false;
        timer.cancel();
        setState(() {});
      }
    });
  }

  void _onConfirmDriverFoundDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => confirmRideSuccessDialog(
        context: context,
        onDialogAction: (String action) {
          if (action == "done") {
            if (widget.servicePurpose == ServicePurpose.personalShopper) {
              navigation(context: context, pageName: "homepage");
              return;
            }
            Navigator.pop(context);
            // _completeBookingRide();
          } else if (action == "trackDeliveryOrder") {
            _trackDeliveryOrder();
          } else {
            Navigator.pop(context);
          }
        },
        servicePurpose: widget.servicePurpose,
        rideSelected: _rideSelected,
      ),
    );
  }

  Future<void> _onPaymentMethod() async {
    _removeOverlay();

    Map<dynamic, dynamic>? method = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Paymentmethod(paymentMethod: _paymentMethod),
      ),
    );

    if (method != null) {
      _paymentMethod = Map<String, dynamic>.from(method);
      setState(() {});
    }
  }

  Future<void> _onQuickPlace(QuickPlace place) async {
    _showCancelButton = true;

    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (e) {
        // Handle or log the error if needed
        debugPrint("Error removing overlay entry: $e");
      }
      _overlayEntry = null;
    }

    RidePickUpModel? model;
    switch (place) {
      case QuickPlace.onGoingTrip:
        Map<String, dynamic> whereToMap, pickUpMap;

        pickUpMap = {
          "name": _onGoingTripDetails!.pickupLocation,
          "long": _onGoingTripDetails!.pickupLog,
          "lat": _onGoingTripDetails!.pickupLat,
        };

        whereToMap = {
          "name": _onGoingTripDetails!.destinationLocation,
          "long": _onGoingTripDetails!.destinationLog,
          "lat": _onGoingTripDetails!.destinationLat,
        };

        Map<String, dynamic> meta = {
          "pickup": pickUpMap,
          "whereTo": whereToMap,
          "busStops": [],
        };
        model = RidePickUpModel.fromJson(meta);
        break;
      case QuickPlace.home || QuickPlace.work:
        Map<String, dynamic> whereToMap = {}, pickUpMap;
        String quickPlaceType = place == QuickPlace.home ? "home" : "work";
        if (!_placesSaved.containsKey(quickPlaceType)) {
          model = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RidePlaces(
                currentLocation: _currentLocation,
                storeLocation: place,
              ),
            ),
          );
          break;
        }

        whereToMap = Map<String, dynamic>.from(_placesSaved[quickPlaceType]);

        setState(() => _isLoading = true);
        PlaceDetailsModel? currentLocationPlaceDetails = await getPlaceDetailsFromCoordinates(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );

        pickUpMap = {
          "name": currentLocationPlaceDetails.name,
          "address": currentLocationPlaceDetails.nearbyPlaceName,
          "long": _currentLocation!.longitude,
          "lat": _currentLocation!.latitude,
        };

        List<LatLng> locations = [];
        locations.addAll([
          LatLng(pickUpMap["lat"], pickUpMap["long"]),
          LatLng(whereToMap["lat"], whereToMap["long"]),
        ]);

        setState(() => _isLoading = false);

        Map<String, dynamic> meta = {
          "pickup": pickUpMap,
          "whereTo": whereToMap,
          "busStops": [],
          "geofenceId": whereToMap["geofenceId"] ?? "",
        };
        model = RidePickUpModel.fromJson(meta);
        break;
      default:
        if (place == QuickPlace.recent && !_placesSaved.containsKey("recents")) {
          toastContainer(text: "No recent activity recorded. Tap 'Where to?'", backgroundColor: BColors.red);
          break;
        }

        model = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RidePlaces(
              currentLocation: _currentLocation,
              isRecent: place == QuickPlace.recent,
            ),
          ),
        );
        break;
    }

    await _getRidePlacesHistory();

    if (model != null) {
      ridePickUpfetcherSink.add(model);
    } else {
      return;
    }

    await _ridePickUpStreamSubscription?.cancel();
    _ridePickUpStreamSubscription = ridePickUpStream.take(1).listen((RidePickUpModel pickUpModel) async {
      // remove current location marker
      await _positionStream?.cancel();
      _markers.removeWhere(
        (marker) => marker.markerId == _currentLocationMarkerId,
      );
      _showSearchPlaceWidget = false;
      _showCurrentLocationMaker = false;

      _ridePickUpModel = pickUpModel;

      LatLng pickupLatLng = LatLng(
        pickUpModel.pickup!.lat!,
        pickUpModel.pickup!.long!,
      );
      LatLng whereToLatLng = LatLng(
        pickUpModel.whereTo!.lat!,
        pickUpModel.whereTo!.long!,
      );

      List<LatLng> busStopLatLngList = [];
      List<Marker> busStopList = [];
      for (int x = 0; x < pickUpModel.busStops!.length; ++x) {
        LatLng bLg = LatLng(
          pickUpModel.busStops![x].lat!,
          pickUpModel.busStops![x].long!,
        );
        busStopLatLngList.add(bLg);
        Marker busStopMarker = Marker(
          markerId: MarkerId("busStop$x"),
          position: bLg,
          infoWindow: InfoWindow(title: pickUpModel.busStops![x].name),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta,
          ),
        );
        busStopList.add(busStopMarker);
      }

      // getting trip estimate
      getTripEstimate(
        [pickupLatLng, whereToLatLng],
        pickUpModel.geofenceId!,
        stopGeofendIds: [
          for (var stop in pickUpModel.busStops!) stop.geofenceId!,
        ],
        stopsLocations: busStopLatLngList,
      ).then((TripEstimateModel? tripEstimate) {
        if (tripEstimate == null) {
          _onBack();

          if (!mounted) return;
          infoDialog(
            context: context,
            type: PanaraDialogType.error,
            text: "Unable to get trip estimate, please report",
            confirmBtnText: "Ok",
          );
          return;
        }

        _ridePickUpModel = setEstimateRidePickUp(model: _ridePickUpModel!, tripEstimate: tripEstimate);
        if (place != QuickPlace.onGoingTrip) {
          // select the okada as the initial trip ride
          _selectedCar = _ridePickUpModel!.tripEstimateModel!.data!.okada;
        }
        setState(() {});
      });

      if (place != QuickPlace.onGoingTrip) _rideNextAction = RideMapNextAction.yourTripSummary;

      Marker pickUpMarker = Marker(
        markerId: const MarkerId("pickup"),
        position: pickupLatLng,
        infoWindow: InfoWindow(title: pickUpModel.pickup!.name),
        icon: _pinIcon!,
      );

      Marker whereToMarker = Marker(
        markerId: const MarkerId("whereTo"),
        position: whereToLatLng,
        infoWindow: InfoWindow(title: pickUpModel.whereTo!.name),
        icon: _destinationIcon!,
      );

      _markers.addAll({
        pickUpMarker,
        whereToMarker,
        ...{for (Marker marker in busStopList) marker}
      });

      Set<Polyline>? polySet = await fetchRouteAndSetPolyline(
        locations: [
          pickupLatLng,
          ...[for (LatLng lL in busStopLatLngList) lL],
          whereToLatLng,
        ],
        polylineKey: 'pickPolyline',
        color: BColors.primaryColor,
      );

      if (polySet != null) {
        _polylines = polySet;
      } else {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('pickPolyline'),
            visible: true,
            points: [
              pickupLatLng,
              ...[for (LatLng lL in busStopLatLngList) lL],
              whereToLatLng,
            ],
            color: BColors.primaryColor,
            width: 5,
          ),
        );
      }

      setState(() {});
      _createAnimationPolyline();

      if (place != QuickPlace.onGoingTrip) {
        await _zoomToFitMarkers(
          point1: pickupLatLng,
          point2: whereToLatLng,
          additionalPoints: [
            ...busStopLatLngList,
          ],
          padding: 85,
        );
        _controller?.showMarkerInfoWindow(const MarkerId('carsAround0'));

        await Future.delayed(const Duration(seconds: 3));

        // _controller?.showMarkerInfoWindow(const MarkerId('whereTo'));
        _overlayCordinate = whereToLatLng;
        _overlayMsg = pickUpModel.whereTo!.name.toString();
        _showCustomInfoWindow();

        await _ridePickUpStreamSubscription?.cancel();
      }
    });
  }

  Future<void> _onSearchDrivers() async {
    if (_availableCarsSubscription != null) {
      _availableCarsSubscription!.cancel();
      _availableCarsSubscription = null; // Reset the subscription
      log("Available cars subscription canceled");
    }

    _rideNextAction = RideMapNextAction.searchingDriver;

    if (mounted) setState(() {});

    LatLng pickupLatLng = LatLng(
      _ridePickUpModel!.pickup!.lat!,
      _ridePickUpModel!.pickup!.long!,
    );
    LatLng whereToLatLng = LatLng(
      _ridePickUpModel!.whereTo!.lat!,
      _ridePickUpModel!.whereTo!.long!,
    );

    List<LatLng> busStopLatLngList = [];
    for (int x = 0; x < _ridePickUpModel!.busStops!.length; ++x) {
      LatLng bLg = LatLng(
        _ridePickUpModel!.busStops![x].lat!,
        _ridePickUpModel!.busStops![x].long!,
      );
      busStopLatLngList.add(bLg);
    }

    // searching for rides
    Map<String, dynamic> reqBody = {
      "action": HttpActions.searchRide,
      "riderId": userModel!.data!.user!.userid,
      "latitude": pickupLatLng.latitude,
      "longitude": pickupLatLng.longitude,
      "vehicleTypeId": _selectedCar!.vehicleTypeId,
      "totalFee": _selectedCar!.totalFee,
      "vehicleTypeBaseFare": _selectedCar!.vehicleTypeBaseFare,
      "onHoldDriverIds": _onHoldDriverIdList,
    };

    // stream all available drivers around
    Stream<Response> responseStream = _firebaseService.searchRideStream(reqBody);
    final broadcastStream = responseStream.asBroadcastStream(onCancel: (StreamSubscription<Response> subscription) {
      log("_onSearchDrivers cancel $_rideNextAction");
    }, onListen: (StreamSubscription<Response> subscription) {
      log("_onSearchDrivers listen $_rideNextAction");
    });

    _rideSelectSubscription = broadcastStream.listen(
      (response) async {
        int statusCode = response.statusCode;
        Map<String, dynamic> driversBody = jsonDecode(response.body);
        _rideSelectModel = RideSelectModel.fromJson(driversBody);

        if (!(_rideNextAction == RideMapNextAction.searchingDriver && _rideSelected == null)) {
          _rideSelectSubscription!.cancel();
        }

        log(driversBody["msg"].toString());
        if (statusCode != 200) {
          log(driversBody["error"].toString());
          // cancel ride request
          if (statusCode == 401) {
            _onCancelRequest(false, isTimeoutNoDriverFound: true);
            _rideSelectSubscription?.cancel();
            _animationController?.stop();
            _initialMoveCameraPosition = true;
            _getCurrentLocation();
            setState(() {});
          } else {
            _onBack();
          }

          if (!mounted) return;
          infoDialog(
            context: context,
            type: statusCode == 401 ? PanaraDialogType.normal : PanaraDialogType.error,
            text: driversBody["msg"],
            confirmBtnText: "Ok",
          );

          return;
        }

        // display drivers around
        List<Rides> driversList = _rideSelectModel!.data!.drivers!;

        // Clear only car markers
        _markers.removeWhere((marker) => _carMarkers.contains(marker));
        _carMarkers.clear();

        List<LatLng> carLatLngList = [];
        carLatLngList.clear();

        // Update car markers and also taking the first driver
        for (int x = 0; x < driversList.take(1).length; ++x) {
          double lat = driversList[x].latitute!;
          double long = driversList[x].longitude!;
          double heading = driversList[x].heading!;
          String vehicleType = driversList[x].data!.vehicleType!;

          carLatLngList.add(LatLng(lat, long));

          Marker carMarker = Marker(
            markerId: MarkerId("carsAround$x"),
            position: LatLng(lat, long),
            icon: vehicleType == "1" ? _carIcon! : _okadaIcon!,
            anchor: const Offset(0.5, 0.5),
            rotation: heading,
            infoWindow: InfoWindow(title: "${formatDuration(driversList[x].duration!)} away"),
          );

          _carMarkers.add(carMarker);
        }

        // Add updated car markers to the main markers set
        _markers.addAll(_carMarkers);

        if (mounted) setState(() {});

        await _zoomToFitMarkers(
          point1: pickupLatLng,
          point2: whereToLatLng,
          additionalPoints: [
            ...busStopLatLngList,
            ...carLatLngList,
          ],
          padding: 85,
        );

        // setting the first driver to riderSelected
        if (driversList.isNotEmpty) {
          _rideSelected = driversList.first;
          _controller?.showMarkerInfoWindow(const MarkerId('carsAround0'));
          await _onSelectRideMakeRequest();
          await _rideSelectSubscription?.cancel();
          return;
        }
      },
      onError: (error) {
        log("Error occurred in stream: $error");
        // cancel ride request
        _onBack();

        if (!mounted) return;
        infoDialog(
          context: context,
          type: PanaraDialogType.error,
          text: "Error occurred in stream: $error",
          confirmBtnText: "Ok",
        );
        return;
      },
      onDone: () {
        log("Stream has been closed.");
      },
      cancelOnError: true,
    );
  }

  Future<void> _showCustomInfoWindow() async {
    if (_overlayCordinate == null) return;

    try {
      final screenPoint = await _controller?.getScreenCoordinate(_overlayCordinate!);
      if (screenPoint == null) return;

      const overlayWidth = 110.0;
      const overlayHeight = 40.0;

      // Calculate position relative to screen coordinates
      double left = screenPoint.x.toDouble() - overlayWidth / .8;
      double top = (screenPoint.y.toDouble() - overlayHeight) - 300;

      // Ensure the custom info window is within the map bounds
      left = left.clamp(0, mapSize.width - overlayWidth);
      top = top.clamp(0, mapSize.height - overlayHeight);

      // Remove the previous overlay
      _overlayEntry?.remove();

      if (_overlayMsg.isNotEmpty) {
        _overlayEntry = OverlayEntry(
          builder: (context) {
            return CustomInfoWindow(
              title: _overlayMsg,
              left: left,
              top: top,
              overlayHeight: overlayHeight,
              overlayWidth: overlayWidth,
            );
          },
        );

        if (!mounted) return;
        Overlay.of(context).insert(_overlayEntry!);
      }
    } catch (e) {
      debugPrint("Error displaying info window: $e");
    }
  }

  void _createAnimationPolyline() {
    if (_polylines.isEmpty) {
      return; // Ensure _polylines is populated before proceeding
    }

    _animationController?.reset(); // Ensure the animation starts fresh
    _animation.removeListener(_updatePolyline); // Remove any previous listener
    _animation.removeStatusListener(_animationStatusListener);
    _animation.addListener(_updatePolyline);
    _animation.addStatusListener(_animationStatusListener);

    _animationController?.forward();
  }

  void _updatePolyline() {
    setState(() {
      double fraction = _animation.value;
      List<LatLng> animatedCoordinates = [];

      if (_polylines.isEmpty) return;

      // Track total distance covered in terms of animated fraction
      double totalDistance = 0;
      for (int i = 0; i < _polylines.first.points.length - 1; i++) {
        totalDistance += calculateDistance(
          _polylines.first.points[i],
          _polylines.first.points[i + 1],
        );
      }

      // Adjust the fraction for each segment individually
      double accumulatedDistance = 0;
      for (int i = 0; i < _polylines.first.points.length - 1; i++) {
        LatLng start = _polylines.first.points[i];
        LatLng end = _polylines.first.points[i + 1];
        double segmentDistance = calculateDistance(start, end);
        double segmentFraction = segmentDistance / totalDistance;

        if (fraction <= (accumulatedDistance + segmentFraction)) {
          double remainingFraction = (fraction - accumulatedDistance) / segmentFraction;

          double lat = start.latitude + (end.latitude - start.latitude) * remainingFraction;
          double lng = start.longitude + (end.longitude - start.longitude) * remainingFraction;

          animatedCoordinates.add(LatLng(lat, lng));
          break; // Stop once the animated point is found
        } else {
          animatedCoordinates.add(end); // Add the end point of this segment
        }
        accumulatedDistance += segmentFraction;
      }

      // Add the animated polyline
      _polylines.removeWhere(
        (polyline) => polyline.polylineId.value == 'animationPolyline',
      );
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('animationPolyline'),
          visible: true,
          points: animatedCoordinates,
          color: BColors.primaryColor2,
          width: 5,
        ),
      );
    });
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _animationController?.forward(
        from: 0,
      ); // Restart animation from the beginning
    }
  }

  Future<void> _zoomToFitMarkers({
    required LatLng point1,
    required LatLng point2,
    List<LatLng> additionalPoints = const [],
    bool moveCameraUp = false,
    double padding = 75,
  }) async {
    // Ensure the GoogleMapController is available
    if (_controller == null) {
      debugPrint("zoomToFitMarkers controller null ");
      _locationUnableToZoom.clear();
      _locationUnableToZoom = [point1, point2, ...additionalPoints];
      return;
    }

    // Combine all points into a single list
    List<LatLng> allPoints = [point1, point2, ...additionalPoints];

    // Find the southwest and northeast bounds based on all points
    double minLat = allPoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = allPoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = allPoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = allPoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    final CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, padding);
    await _controller?.animateCamera(cameraUpdate).then((_) {
      if (moveCameraUp) {
        _controller?.moveCamera(
          CameraUpdate.scrollBy(0, -200), // Scroll up by -200 pixels
        );
      }
    });
  }

  Future<void> _onMoveCameraToCurrentLocation() async {
    if (!mounted) return;

    _getCurrentLocation();
    if (_currentLocationPosition != null) {
      CameraPosition position = CameraPosition(
        bearing: _currentLocationPosition!.heading,
        target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        zoom: _zoom,
      );
      await _controller?.animateCamera(
        CameraUpdate.newCameraPosition(position),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    setState(() {});
    if (_locationUnableToZoom.isNotEmpty) {
      _zoomToFitMarkers(point1: _locationUnableToZoom[0], point2: _locationUnableToZoom[1]);
    }
  }

  Future<void> _loadCustomMarkerAssets() async {
    // loading current location asset image
    final Uint8List cLocationIcon = await _getBytesFromAsset(
      Images.currentLocation,
      170,
    );
    _currentLocationIcon = BitmapDescriptor.bytes(cLocationIcon);

    final Uint8List liveDriverIcon = await _getBytesFromAsset(
      Images.mapLiveDriver,
      30,
    );
    _liveDriverIcon = BitmapDescriptor.bytes(liveDriverIcon);

    // loading car asset image
    final Uint8List carIcon = await _getBytesFromAsset(
      Images.mapCar,
      25,
    );
    _carIcon = BitmapDescriptor.bytes(carIcon);

    final Uint8List carSmallIcon = await _getBytesFromAsset(
      Images.mapCar,
      17,
    );
    _carSmallIcon = BitmapDescriptor.bytes(carSmallIcon);

    // loading okada asset image
    final Uint8List okadaIcon = await _getBytesFromAsset(
      Images.mapOkada,
      25,
    );
    _okadaIcon = BitmapDescriptor.bytes(okadaIcon);

    final Uint8List okadaSmallIcon = await _getBytesFromAsset(
      Images.mapOkada,
      17,
    );
    _okadaSmallIcon = BitmapDescriptor.bytes(okadaSmallIcon);

    // loading pin asset image
    final Uint8List pinIcon = await _getBytesFromAsset(
      Images.mapPin,
      30,
    );
    _pinIcon = BitmapDescriptor.bytes(pinIcon);

    // loading destination asset image
    final Uint8List destinationIcon = await _getBytesFromAsset(
      Images.mapDestination,
      30,
    );
    _destinationIcon = BitmapDescriptor.bytes(destinationIcon);

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

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    await _loadCustomMarkerAssets();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) async {
      if (!mounted) {
        _positionStream?.cancel();
        return;
      }

      _currentLocation = LatLng(
        _currentLocationPosition!.latitude,
        _currentLocationPosition!.longitude,
      );

      if (_showCurrentLocationMaker) {
        _currentLocationPosition = position;
        final marker = Marker(
          markerId: _currentLocationMarkerId,
          position: _currentLocation!,
          icon: _currentLocationIcon!,
          anchor: const Offset(0.5, 0.5),
          rotation: position.heading,
        );
        _markers.add(marker);
        if (!mounted) {
          _positionStream?.cancel();
          return;
        }

        if (mounted) setState(() {});
        if (_initialMoveCameraPosition) {
          _initialMoveCameraPosition = false;
          await _controller?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude),
            ),
          );
        }
      } else {
        debugPrint("current location marker removed");
      }
    });

    if (widget.servicePurpose == ServicePurpose.ride && _onGoingTripDetails == null) {
      _showAvailableCars();
    }
  }

  void _removeOverlay() {
    try {
      _overlayEntry?.remove();
      _overlayMsg = "";
    } catch (e) {
      log(e.toString());
    }
  }
}
