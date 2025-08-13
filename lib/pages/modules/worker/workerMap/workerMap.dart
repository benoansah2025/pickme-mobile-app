import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart' hide Step;
import 'package:flutter_polyline_points/flutter_polyline_points.dart' hide TravelMode, Route;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
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
import 'package:pickme_mobile/models/driverRequestModel.dart';
import 'package:pickme_mobile/models/feeModel.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/homepage/workerHome/workerHome.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/widget/cancelRequestDialog.dart';
import 'package:pickme_mobile/pages/modules/worker/workerMap/widget/workerRideAcceptRequestMap.dart';
import 'package:pickme_mobile/pages/modules/worker/rateCustomer/rateCustomer.dart';
import 'package:pickme_mobile/pages/modules/worker/workerMap/widget/workerMapWidget.dart';
import 'package:pickme_mobile/pages/modules/worker/workerMap/workerRadiusMap.dart';
import 'package:pickme_mobile/providers/cancelReasonsProvider.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'dart:ui' as ui;

import 'package:pickme_mobile/spec/properties.dart';

import 'widget/workerMultipleRunnerAcceptRequestMap.dart';
import 'widget/workerSingleRunnerAcceptRequestMap.dart';

class WorkerMap extends StatefulWidget {
  final Position? currentLocation;
  final WorkerMapNextAction? mapNextAction;
  final ServicePurpose? servicePurpose;
  final OnWorkerOnOfflineToggle? onWorkerOnOfflineToggle;
  final DriverRequestModel? requestModel;
  final bool isWorkerToggleLoading;

  const WorkerMap({
    super.key,
    required this.currentLocation,
    this.mapNextAction,
    this.servicePurpose,
    this.onWorkerOnOfflineToggle,
    this.requestModel,
    this.isWorkerToggleLoading = false,
  });

  @override
  State<WorkerMap> createState() => _WorkerMapState();
}

class _WorkerMapState extends State<WorkerMap> {
  final Repository _repo = new Repository();
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Position? _currentPosition;
  Circle? _radiusCircle;
  double _currentRadius = 1000.0;

  Position? _currentLocationPosition;
  LatLng? _currentLocation, _destinationLocation;
  StreamSubscription<Position>? _positionStream;

  BitmapDescriptor? _currentLocationIcon, _liveDriverIcon;

  final double _zoom = 14.4746;

  static const MarkerId _currentLocationMarkerId = MarkerId('currentLocation');
  bool _showCurrentLocationMaker = true,
      _isTTSVolumeMute = true,
      _isLoading = false,
      _useDirections = false,
      _isShowHomeDetails = false,
      _showCancelButton = true;

  WorkerMapNextAction? _mapNextAction;
  FlutterTts? _flutterTts;
  double _cameraBearing = 0.0;

  final FirebaseService _firebaseService = new FirebaseService();

  final List<LatLng> _busStopLatLngList = [];
  Set<Polyline>? _polySet;

  List<StopStut>? _busStops;
  Map<dynamic, dynamic>? _busStopsTripDetails;
  int? _nextStopIndex;

  String _arrivedTime = "";

  @override
  void initState() {
    super.initState();
    if (widget.currentLocation != null) {
      _currentLocationPosition = widget.currentLocation;
      _currentLocation = LatLng(
        _currentLocationPosition!.latitude,
        _currentLocationPosition!.longitude,
      );

      if (_mapNextAction == null) _getCurrentLocation();
    } else {
      throw Exception(
        "Current location position can't be null",
      );
    }

    _loadCustomMarkerAssets();
    _initTts();

    _mapNextAction = widget.mapNextAction;

    if (_mapNextAction == WorkerMapNextAction.accept || _mapNextAction == WorkerMapNextAction.arrived) {
      // go to pickup location
      _onStartRideTrip(
        destination: LatLng(
          widget.requestModel!.currentRideDetails!.riderPosition!.latitude,
          widget.requestModel!.currentRideDetails!.riderPosition!.longitude,
        ),
        action: _mapNextAction!,
        sendNotification: false,
      );
    } else if (_mapNextAction == WorkerMapNextAction.startTrip) {
      _onStartRideTrip(
        destination: LatLng(
          widget.requestModel!.currentRideDetails!.destinationPosition!.latitude,
          widget.requestModel!.currentRideDetails!.destinationPosition!.longitude,
        ),
        action: _mapNextAction!,
        sendNotification: false,
      );
    } else if (_mapNextAction == WorkerMapNextAction.endTrip) {
      _onEndRideTrip(_mapNextAction!, sendNotification: false);
    }

    _initialHomeDetails();
    _onCancellationTimer();
    _onCheckTripStatus();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _positionStream = null;
    _disposeTts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          workerMapWidget(
            context: context,
            currentLocation: _currentLocation!,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              if (widget.mapNextAction == null) addRadiusCircle(); // Initialize the circle
              _onMapCreated(controller);
            },
            zoom: _zoom,
            polylines: _polylines,
            onCurrentLocation: () => _onMoveCameraToCurrentLocation(),
            onPaySales: () => navigation(context: context, pageName: "salesPayment"),
            onOnOfflineToggle: (int index) => widget.onWorkerOnOfflineToggle!(index),
            mapNextAction: _mapNextAction,
            onBack: () => _onBack(),
            // onTTSVolume: () => _onTTSVolume(),
            // isTTSVolumeMute: _isTTSVolumeMute,
            onGoogleMap: () => _onOpenGoogleMap(),
            // onDirection: () => _onUseDirections(),
            isDirecting: _useDirections,
            onRadius: () => _onRadius(),
            onHitmap: () {},
            onSideHomeDetails: () => _onShowHomeDetails(),
            isShowHomeDetails: _isShowHomeDetails,
            circles: _radiusCircle != null ? {_radiusCircle!} : {},
            onCancelRequest: () => _onCancelRequestDialog(),
            showCancelButton: _showCancelButton,
            isWorkerToggleLoading: widget.isWorkerToggleLoading,
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
      bottomNavigationBar: _isLoading
          ? null
          : _mapNextAction == WorkerMapNextAction.accept ||
                  _mapNextAction == WorkerMapNextAction.arrived ||
                  _mapNextAction == WorkerMapNextAction.startTrip
              ? widget.servicePurpose == ServicePurpose.ride
                  ? workerRideAcceptRequestMap(
                      context: context,
                      onCall: () => callLauncher("tel: ${widget.requestModel!.currentRideDetails!.riderPhone}"),
                      onChat: () {},
                      onArrivedPickUpPoint: () => _onEndRideTrip(WorkerMapNextAction.arrived),
                      mapNextAction: _mapNextAction,
                      onStartTrip: () => _onStartRideTrip(
                        destination: LatLng(
                          widget.requestModel!.currentRideDetails!.destinationPosition!.latitude,
                          widget.requestModel!.currentRideDetails!.destinationPosition!.longitude,
                        ),
                        action: WorkerMapNextAction.startTrip,
                      ),
                      onEndTrip: () => _onEndRideTrip(WorkerMapNextAction.endTrip),
                      requestModel: widget.requestModel!,
                      stops: _busStops,
                      nextStopIndex: _nextStopIndex,
                    )
                  : widget.servicePurpose == ServicePurpose.deliveryRunnerSingle
                      ? workerSingleRunnerAcceptRequestMap(
                          context: context,
                          onCall: () {},
                          onChat: () {},
                          onArrivedSenderLocation: () => _onEndRideTrip(
                            WorkerMapNextAction.arrived,
                          ),
                          mapNextAction: _mapNextAction,
                          onStartTrip: () => _onStartRideTrip(
                            destination: const LatLng(5.6730432, -0.1835081),
                            action: WorkerMapNextAction.startTrip,
                          ),
                          onEndTrip: () => _onEndRideTrip(
                            WorkerMapNextAction.endTrip,
                          ),
                        )
                      : workerMultipleRunnerAcceptRequestMap(
                          context: context,
                          onCall: () {},
                          onChat: () {},
                          onArrivedSenderLocation: () => _onEndRideTrip(
                            WorkerMapNextAction.arrived,
                          ),
                          mapNextAction: _mapNextAction,
                          onStartTrip: () => _onStartRideTrip(
                            destination: const LatLng(5.6730432, -0.1835081),
                            action: WorkerMapNextAction.startTrip,
                          ),
                          onEndTrip: () => _onEndRideTrip(
                            WorkerMapNextAction.endTrip,
                          ),
                        )
              : null,
    );
  }

  Future<void> _onCheckTripStatus() async {
    // loading busStopsTripDetails hive caching
    _busStopsTripDetails = (await getHive("busStopsTripDetails"));
    log("======_busStopsTripDetails init $_busStopsTripDetails");

    // loading arriveTime hive chaching
    _arrivedTime = await getHive("arrivedTime") ?? "";
    log("======_arrivedTime init $_arrivedTime");

    if (widget.requestModel != null) {
      String userId = userModel!.data!.user!.userid!;

      FirebaseService().userTripDetailsStream(userId).listen((TripDetailsModel? tripDetails) {
        if (tripDetails?.status == "TRIP-CANCELLED") {
          if (!mounted) return;
          navigation(context: context, pageName: "homepage");
          toastContainer(text: "Trip Cancelled", backgroundColor: BColors.red);
          return;
        }
      });
    }
  }

  Future<void> _onCancellationTimer() async {
    if (_mapNextAction == WorkerMapNextAction.accept || _mapNextAction == WorkerMapNextAction.arrived) {
      await Future.delayed(const Duration(seconds: 10));
      if (widget.requestModel != null) {
        DateTime inputDate =
            widget.requestModel!.actionDate == null ? DateTime.now() : DateTime.parse(widget.requestModel!.actionDate!);

        Timer.periodic(const Duration(seconds: 1), (timer) {
          DateTime currentDate = DateTime.now();

          Duration timeDiff = currentDate.difference(inputDate);
          debugPrint("Time difference for ride cancel ${timeDiff.inSeconds} seconds");

          if (timeDiff.inSeconds >= Properties.cancelButtonTimerInSec) {
            _showCancelButton = false;
            timer.cancel();
            if (mounted) setState(() {});
          }
        });
      } else {
        _showCancelButton = false;
        if (mounted) setState(() {});
      }
    } else {
      _showCancelButton = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _onCancelRequestDialog() async {
    if (cancelReasonsModel == null) {
      await _repo.fetchCancelReasons(true);
    }

    if (!mounted) return;
    showDialog(
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
              _onCancelRequest(reason!);
            },
            onSelectReason: (CancelReasonData data) {
              reason = data;
              dialogSetState(() {});
            },
            reason: reason,
          );
        });
      },
    ); // Ensure the dialog returns a bool;
  }

  Future<void> _onCancelRequest(CancelReasonData reason) async {
    Map<String, dynamic> reqBody = {
      "driverId": widget.requestModel!.currentRideDetails!.driverId,
      "riderId": widget.requestModel!.currentRideDetails!.riderId,
      "cancelledBy": "DRIVER",
    };
    setState(() => _isLoading = true);

    Response response = await _firebaseService.cancelTrip(reqBody);
    int statusCode = response.statusCode;
    Map<String, dynamic> body = jsonDecode(response.body);

    log(body.toString());

    if (statusCode != 200) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      infoDialog(
        context: context,
        type: PanaraDialogType.error,
        text: body["msg"],
        confirmBtnText: "Ok",
      );

      return;
    }

    String tripId = widget.requestModel!.currentTripDetails!.tripId!;
    TripDetailsModel? tripDetailsModel = await _firebaseService.tripDetails(tripId);

    if (tripDetailsModel == null) {
      if (!mounted) return;
      infoDialog(
        context: context,
        type: PanaraDialogType.error,
        text: "Unable to get trip details please report",
        confirmBtnText: "Ok",
        onConfirmBtnTap: () => navigation(context: context, pageName: "homepage"),
      );

      return;
    }

    // making cancel request api
    final httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.tripCancelled,
          "customerId": userModel!.data!.user!.userid,
          "cancelReason": reason.title,
          "tripId": tripDetailsModel.tripId ?? "",
          "pickupLocation": tripDetailsModel.pickupLocation ?? "",
          "pickupLat": (tripDetailsModel.pickupLat ?? "").toString(),
          "pickupLog": (tripDetailsModel.pickupLog ?? "").toString(),
          "destinationLocation": tripDetailsModel.destinationLocation ?? "",
          "destinationLat": (tripDetailsModel.destinationLat ?? "").toString(),
          "destinationLog": (tripDetailsModel.destinationLog ?? "").toString(),
          "riderId": tripDetailsModel.riderId ?? "",
          "driverId": tripDetailsModel.driverId ?? "",
          "vehicleType": getVehicleTypeName(tripDetailsModel.vehicleType ?? ""),
          "vehicleMake": tripDetailsModel.vehicleMake ?? "",
          "vehicleModel": tripDetailsModel.vehicleModel ?? "",
          "vehicleYear": tripDetailsModel.vehicleYear ?? "",
          "vehicleNumber": tripDetailsModel.vehicleNumber ?? "",
          "vehicleColor": tripDetailsModel.vehicleColor ?? "",
          "tripKm": tripDetailsModel.tripKm ?? "",
          "periodStart": tripDetailsModel.periodStart ?? "",
          "periodEnd": tripDetailsModel.periodEnd ?? "",
          "vehicleTypeBaseFare": tripDetailsModel.vehicleTypeBaseFare ?? "",
        },
      ),
    );

    log(httpResult.toString());

    if (httpResult["ok"]) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      navigation(context: context, pageName: "homepage");
    } else {
      setState(() => _isLoading = false);
      httpResult["statusCode"] == 200
          ? toastContainer(text: httpResult["data"]["msg"], backgroundColor: BColors.red)
          : toastContainer(text: httpResult["error"], backgroundColor: BColors.red);
      return;
    }
  }

  // Update the circle based on the current radius
  bool _fitCircleOnce = true;
  Future<void> addRadiusCircle() async {
    DriverDetailsModel? model =
        await FirebaseService().getDriverLocationDetails(userModel!.data!.user!.userid!).take(1).first;

    _currentRadius = model!.radiusInM!;

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _radiusCircle = Circle(
            circleId: const CircleId("radiusCircle"),
            center: LatLng(position.latitude, position.longitude),
            radius: _currentRadius,
            fillColor: BColors.primaryColor1.withOpacity(0.3),
            strokeWidth: 1,
            strokeColor: BColors.primaryColor1,
          );
        });
      }
      // Call _fitCircleInCamera with a flag to determine if camera should be moved
      _fitCircleInCamera(moveCamera: !_fitCircleOnce);

      if (_fitCircleOnce) {
        _fitCircleOnce = false;
        _onShowHomeDetails();
        _onShowHomeDetails();
      }
    });
  }

  Future<void> _initialHomeDetails() async {
    bool show = (await getHive("showHomeDetails")) ?? false;
    _isShowHomeDetails = show;
    if (mounted) setState(() {});
  }

  void _onShowHomeDetails() {
    _isShowHomeDetails = !_isShowHomeDetails;
    if (mounted) setState(() {});
    saveHive(key: "showHomeDetails", data: _isShowHomeDetails);

    if (_controller != null) {
      if (_isShowHomeDetails) {
        // Move camera down when showing home details
        _controller!.animateCamera(CameraUpdate.scrollBy(0, -150));
      } else {
        // Move camera back to center on the circle when hiding home details
        _fitCircleInCamera(moveCamera: true);
      }
    }
  }

  Future<void> _onRadius() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkerRadiusMap(
          currentLocation: _currentLocation,
          radius: _currentRadius,
        ),
      ),
    );
    addRadiusCircle();
  }

  // void _onUseDirections({bool? useDirection}) {
  //   _useDirections = useDirection ?? !_useDirections;
  //   _flutterTts?.setVolume(0);
  //   _isTTSVolumeMute = true;

  //   _getRideRoute(
  //     _destinationLocation!,
  //     stops: _busStopLatLngList,
  //     useDirections: _useDirections,
  //   );

  //   if (_useDirections) {
  //     // Start updating position and polyline when directions are enabled
  //     _startPositionUpdates();
  //   } else {
  //     // Stop position updates when directions are disabled
  //     _positionStream?.cancel();
  //   }
  //   if (mounted) setState(() {});

  //   _onMoveCameraToCurrentLocation();
  // }

  // ignore: unused_element
  void _startPositionUpdates() {
    _positionStream?.cancel(); // Cancel any existing stream

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      // Update the current location marker
      _updateCurrentLocationMarker();

      // Update the polyline if directions are in use
      if (_useDirections && _destinationLocation != null) {
        // _getRideRoute(
        //   _destinationLocation!,
        //   stops: _busStopLatLngList,
        //   useDirections: true,
        // );
      }

      if (mounted) setState(() {});
    });
  }

  void _updateCurrentLocationMarker() {
    if (_liveDriverIcon != null) {
      final updatedMarker = Marker(
        markerId: _currentLocationMarkerId,
        position: _currentLocation!,
        icon: _liveDriverIcon!,
        anchor: const Offset(0.5, 0.5),
        rotation: _currentPosition!.heading,
      );

      if (mounted) {
        setState(() {
          _markers.removeWhere((marker) => marker.markerId == _currentLocationMarkerId);
          _markers.add(updatedMarker);
        });
      }
    }
  }

  void _onOpenGoogleMap() {
    // Open Google Maps with directions
    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${_destinationLocation!.latitude},${_destinationLocation!.longitude}';
    callLauncher(googleUrl);
  }

  Future<void> _onEndRideTrip(
    WorkerMapNextAction action, {
    bool sendNotification = true,
  }) async {
    if (action == WorkerMapNextAction.arrived) {
      _arrivedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      await saveHive(key: "arrivedTime", data: _arrivedTime);

      Map<String, dynamic> reqBody = {
        "action": HttpActions.arrivedPickup,
        "driverId": widget.requestModel!.currentRideDetails!.driverId,
        "riderId": widget.requestModel!.currentRideDetails!.riderId,
        "sendNotification": sendNotification,
      };

      setState(() => _isLoading = true);
      Response response = await _firebaseService.arriveAtPickup(reqBody);
      setState(() => _isLoading = false);

      int statusCode = response.statusCode;
      Map<String, dynamic> body = jsonDecode(response.body);

      log(body.toString());

      if (statusCode != 200) {
        if (!mounted) return;
        infoDialog(
          context: context,
          type: PanaraDialogType.error,
          text: body["msg"],
          confirmBtnText: "Ok",
        );

        return;
      }
    }

    _positionStream?.cancel();
    _polylines.clear();
    _destinationLocation = null;
    _mapNextAction = action;
    if (mounted) setState(() {});

    if (action == WorkerMapNextAction.endTrip) {
      setState(() => _isLoading = true);

      // set _busStopsTripDetails["destination"]
      _busStopsTripDetails!["destination"]!["end"] = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      if (_busStopLatLngList.isNotEmpty) {
        final double distance = Geolocator.distanceBetween(
          _busStopLatLngList.last.latitude,
          _busStopLatLngList.last.longitude,
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );
        double km = distance / 1000;
        _busStopsTripDetails!["destination"]!["km"] = km;
      } else {
        final double distance = Geolocator.distanceBetween(
          widget.requestModel!.currentRideDetails!.riderPosition!.latitude,
          widget.requestModel!.currentRideDetails!.riderPosition!.longitude,
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );
        double km = distance / 1000;
        _busStopsTripDetails!["destination"]!["km"] = km;
      }

      // caching busStops in case driver leaving page
      await saveHive(key: "busStopsTripDetails", data: _busStopsTripDetails);

      await _submitTrip(sendNotification);
    }
  }

  Future<void> _submitTrip(bool sendNotification) async {
    TripDetailsModel? tripDetailsModel = await _firebaseService.tripDetails(
      widget.requestModel!.currentTripDetails!.tripId!,
    );

    if (tripDetailsModel == null) {
      if (!mounted) return;
      infoDialog(
        context: context,
        type: PanaraDialogType.error,
        text: "Unable to get trip details please report",
        confirmBtnText: "Ok",
        onConfirmBtnTap: () => navigation(context: context, pageName: "homepage"),
      );

      return;
    }

    List<Map<dynamic, dynamic>> stopsList = [];
    stopsList = _busStopsTripDetails!.values
        .cast<Map<dynamic, dynamic>>()
        .where((stop) => stop['end'] != null && stop['end'].toString().isNotEmpty)
        .toList();

    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.tripCompleted,
          "tripId": widget.requestModel!.currentTripDetails?.tripId ?? "",
          "pickupLocation": tripDetailsModel.pickupLocation ?? "",
          "pickupLat": (tripDetailsModel.pickupLat ?? "").toString(),
          "pickupLog": (tripDetailsModel.pickupLog ?? "").toString(),
          "destinationLocation": tripDetailsModel.destinationLocation ?? "",
          "destinationLat": (tripDetailsModel.destinationLat ?? "").toString(),
          "destinationLog": (tripDetailsModel.destinationLog ?? "").toString(),
          "riderId": tripDetailsModel.riderId ?? "",
          "driverId": tripDetailsModel.driverId ?? "",
          "vehicleType": getVehicleTypeName(tripDetailsModel.vehicleType ?? ""),
          "vehicleMake": tripDetailsModel.vehicleMake ?? "",
          "vehicleModel": tripDetailsModel.vehicleModel ?? "",
          "vehicleYear": tripDetailsModel.vehicleYear ?? "",
          "vehicleNumber": tripDetailsModel.vehicleNumber ?? "",
          "vehicleColor": tripDetailsModel.vehicleColor ?? "",
          "arrivedTime": _arrivedTime,
          "promoCode": tripDetailsModel.promoCode ?? "",
          "paymentMethod": tripDetailsModel.paymentMethod ?? "",
          "periodStart": stopsList.first["start"], // get the stops first start
          "periodEnd": stopsList.last["end"], // get the stops last end
          "vehicleTypeBaseFare": tripDetailsModel.vehicleTypeBaseFare ?? "",
          "stops": json.encode(stopsList),
        },
      ),
      showToastMsg: false,
    );
    log("tripCompleted=> $httpResult");
    if (httpResult["ok"]) {
      FeeModel feeModel = FeeModel.fromJson(httpResult["data"]);

      Map<String, dynamic> reqBody = {
        "action": HttpActions.tripEnded,
        "driverId": widget.requestModel!.currentRideDetails!.driverId,
        "riderId": widget.requestModel!.currentRideDetails!.riderId,
        "position": {
          "geopoint": [
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          ],
          "heading": _currentPosition!.heading,
        },
        "tripId": widget.requestModel!.currentTripDetails?.tripId,
        "sendNotification": sendNotification,
        "periodEnd": stopsList.last["end"],
      };

      Response response = await _firebaseService.tripEnded(reqBody, feeModel);

      int statusCode = response.statusCode;
      Map<String, dynamic> body = jsonDecode(response.body);

      log(body.toString());
      if (statusCode != 200) {
        if (!mounted) return;
        infoDialog(
          context: context,
          type: PanaraDialogType.error,
          text: body["msg"],
          confirmBtnText: "Ok",
        );

        return;
      }

      // delete the busStopsTripDetails and arriveTime hive caching
      await deleteHive("busStopsTripDetails");
      await deleteHive("arrivedTime");

      if (mounted) setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => RateCustomer(
            servicePurpose: widget.servicePurpose!,
            feeModel: feeModel,
            riderId: tripDetailsModel.riderId!,
            requestModel: widget.requestModel!,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      setState(() => _isLoading = false);
      httpResult["statusCode"] == 200
          ? toastContainer(text: httpResult["data"]["msg"], backgroundColor: BColors.red)
          : toastContainer(text: httpResult["error"], backgroundColor: BColors.red);
      return;
    }
  }

  Future<void> _onStartRideTrip({
    required LatLng destination,
    required WorkerMapNextAction action,
    bool sendNotification = true,
  }) async {
    if (action == WorkerMapNextAction.startTrip) {
      Map<String, dynamic> reqBody = {
        "action": HttpActions.tripStarted,
        "driverId": widget.requestModel!.currentRideDetails!.driverId,
        "riderId": widget.requestModel!.currentRideDetails!.riderId,
        "riderFirebaseKey": widget.requestModel!.currentRideDetails!.riderFirebaseKey,
        "sendNotification": sendNotification,
      };

      setState(() => _isLoading = true);
      Response response = await _firebaseService.startTrip(reqBody);
      setState(() => _isLoading = false);

      int statusCode = response.statusCode;
      Map<String, dynamic> body = jsonDecode(response.body);

      log(body.toString());

      if (statusCode != 200) {
        if (!mounted) return;
        infoDialog(
          context: context,
          type: PanaraDialogType.error,
          text: body["msg"],
          confirmBtnText: "Ok",
        );

        return;
      }
      if (sendNotification) _onSumbitRideAccept();
    }

    _markers.clear();
    _polylines.clear();
    _showCurrentLocationMaker = false;
    _mapNextAction = action;
    _destinationLocation = destination;

    if (action == WorkerMapNextAction.startTrip) {
      List<Marker> busStopList = [];

      for (int x = 0; x < widget.requestModel!.currentRideDetails!.stops!.length; ++x) {
        LatLng bLg = LatLng(
          widget.requestModel!.currentRideDetails!.stops![x].geopoint!.latitude,
          widget.requestModel!.currentRideDetails!.stops![x].geopoint!.longitude,
        );
        _busStopLatLngList.add(bLg);
        Marker busStopMarker = Marker(
          markerId: MarkerId("busStop$x"),
          position: bLg,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
        );
        busStopList.add(busStopMarker);

        if (sendNotification) {
          // Initialize the next stop for the driver
          _nextStopIndex = 0;
          _busStops = widget.requestModel!.currentRideDetails!.stops!;
          _busStopsTripDetails = {
            "stop$_nextStopIndex": {
              "start": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              "end": "",
              "km": 0,
              "geofenceId": _busStops![_nextStopIndex!].geofenceId,
            },
            // adding desination to be use if driver decide to end the trip while not all stops are completed
            "destination": {
              "start": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              "end": "",
              "km": 0,
              "geofenceId": widget.requestModel!.currentRideDetails!.destinationGeofenceId,
            }
          };
        }
      }

      _markers.addAll({for (Marker marker in busStopList) marker});

      if (sendNotification) {
        // adding destination to _busStopsTripDetails if there is no stops
        _busStopsTripDetails ??= {
          "destination": {
            "start": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
            "end": "",
            "km": 0,
            "geofenceId": widget.requestModel!.currentRideDetails!.destinationGeofenceId,
          },
        };

        log("======_busStopsTripDetails $_busStopsTripDetails");
        // caching busStops in case driver leaving page
        await saveHive(key: "busStopsTripDetails", data: _busStopsTripDetails);
      }
    }

    // _currentPosition = await Geolocator.getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.high,
    // );
    _currentPosition = widget.currentLocation;

    _isLoading = true;
    if (mounted) setState(() {});
    _polySet = await fetchRouteAndSetPolyline(
      locations: [
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ..._busStopLatLngList,
        destination,
      ],
      polylineKey: 'pickPolyline',
      color: BColors.primaryColor,
    );
    _isLoading = false;
    if (mounted) setState(() {});

    _animateCameraToCurrentLocation();
    // _onUseDirections(useDirection: true);

    // Initialize last position and time
    LatLng? lastPosition;
    const double minDistanceThreshold = 500.0; // Minimum distance in meters to call API again
    const Duration timeInterval = Duration(seconds: 30); // Minimum time interval to call API again
    DateTime lastApiCallTime = DateTime.now().subtract(timeInterval); // Initialize with past time

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      _currentPosition = position;
      _currentLocation = LatLng(
        _currentLocationPosition!.latitude,
        _currentLocationPosition!.longitude,
      );

      // Throttling based on distance and time
      if (lastPosition != null) {
        final double distance = Geolocator.distanceBetween(
          lastPosition!.latitude,
          lastPosition!.longitude,
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        );

        final DateTime now = DateTime.now();
        final Duration timeSinceLastApiCall = now.difference(lastApiCallTime);

        if (distance >= minDistanceThreshold || timeSinceLastApiCall >= timeInterval) {
          if (_destinationLocation != null) {
            // _getRideRoute(
            //   _destinationLocation!,
            //   stops: _busStopLatLngList,
            //   useDirections: _useDirections,
            // );
          }
          lastPosition = _currentLocation; // Update last position
          lastApiCallTime = now; // Update last API call time
        }
      } else {
        // Initial call
        if (_destinationLocation != null) {
          // _getRideRoute(
          //   _destinationLocation!,
          //   stops: _busStopLatLngList,
          //   useDirections: _useDirections,
          // );
        }
        lastPosition = _currentLocation; // Update last position
        lastApiCallTime = DateTime.now(); // Set initial API call time
      }

      // Update the existing marker's position
      _markers.removeWhere((marker) => marker.markerId == _currentLocationMarkerId); // Remove the old marker

      final marker = Marker(
        markerId: _currentLocationMarkerId,
        position: _currentLocation!,
        icon: _liveDriverIcon!,
        anchor: const Offset(0.5, 0.5),
        rotation: position.heading,
      );
      _markers.add(marker);
      if (mounted) setState(() {});

      if (_destinationLocation != null) {
        const destinationMakerId = MarkerId("destinationLocation");
        _markers.removeWhere((marker) => marker.markerId == destinationMakerId);
        Marker destinationMarker = Marker(
          markerId: destinationMakerId,
          position: destination,
          infoWindow: InfoWindow(title: widget.requestModel!.currentRideDetails!.destinationInText!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        );

        _markers.add(destinationMarker);
        if (mounted) setState(() {});
      }

      // track stops to auto set next stop
      if (_nextStopIndex != null) {
        if (_nextStopIndex! < _busStopLatLngList.length) {
          final double distance = Geolocator.distanceBetween(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
            _busStopLatLngList[_nextStopIndex!].latitude,
            _busStopLatLngList[_nextStopIndex!].longitude,
          );

          // If the driver is within 50 meters of the stop, set the stop as completed
          if (distance < 50) {
            _busStopsTripDetails!["stop$_nextStopIndex"]!["end"] =
                DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
            double km = distance / 1000;
            _busStopsTripDetails!["stop$_nextStopIndex"]!["km"] = km;

            // checking if there is a next stop and setting the next stop
            if (_nextStopIndex! + 1 < _busStopLatLngList.length) {
              _nextStopIndex = _nextStopIndex! + 1;
              _busStopsTripDetails!["stop$_nextStopIndex"] = {
                "start": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                "end": "",
                "km": 0,
                "geofenceId": _busStops![_nextStopIndex!].geofenceId,
              };
            }

            if (mounted) setState(() {});
          }
        } else {
          // head over to final destination
          _busStopsTripDetails!["destination"] = {
            "start": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
            "end": "",
            "km": 0,
            "geofenceId": widget.requestModel!.currentRideDetails!.destinationGeofenceId,
          };
        }

        // caching busStops in case driver leaving page
        await saveHive(key: "busStopsTripDetails", data: _busStopsTripDetails);
      }

      if (action == WorkerMapNextAction.endTrip) {
        _positionStream?.cancel();
        _disposeTts();
        return;
      }
    });
  }

  Future<void> _onSumbitRideAccept() async {
    String tripId = widget.requestModel!.currentTripDetails!.tripId!;
    TripDetailsModel? tripDetailsModel = await _firebaseService.tripDetails(tripId);

    if (tripDetailsModel == null) {
      if (!mounted) return;
      // coolAlertDialog(
      //   context: context,
      //   type: PanaraDialogType .error,
      //   text: "Unable to get trip details please report",
      //   confirmBtnText: "Ok",
      //   onConfirmBtnTap: () => navigation(context: context, pageName: "homepage"),
      // );

      return;
    }
    // making booking accept request api
    httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.tripAccepted,
          "customerId": userModel!.data!.user!.userid,
          "tripId": tripDetailsModel.tripId ?? "",
          "pickupLocation": tripDetailsModel.pickupLocation ?? "",
          "pickupLat": (tripDetailsModel.pickupLat ?? "").toString(),
          "pickupLog": (tripDetailsModel.pickupLog ?? "").toString(),
          "destinationLocation": tripDetailsModel.destinationLocation ?? "",
          "destinationLat": (tripDetailsModel.destinationLat ?? "").toString(),
          "destinationLog": (tripDetailsModel.destinationLog ?? "").toString(),
          "riderId": tripDetailsModel.riderId ?? "",
          "driverId": tripDetailsModel.driverId ?? "",
          "vehicleType": getVehicleTypeName(tripDetailsModel.vehicleType ?? ""),
          "vehicleMake": tripDetailsModel.vehicleMake ?? "",
          "vehicleModel": tripDetailsModel.vehicleModel ?? "",
          "vehicleYear": tripDetailsModel.vehicleYear ?? "",
          "vehicleNumber": tripDetailsModel.vehicleNumber ?? "",
          "vehicleColor": tripDetailsModel.vehicleColor ?? "",
          "tripKm": tripDetailsModel.tripKm ?? "",
          "periodStart": tripDetailsModel.periodStart ?? "",
        },
      ),
    );
  }

  void _fitCircleInCamera({bool moveCamera = true}) {
    if (!mounted) return;

    if (_controller != null && _radiusCircle != null && !_isShowHomeDetails) {
      final double radiusInDegrees = _currentRadius / 111000; // Approximate degrees for the given radius
      final LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _radiusCircle!.center.latitude - radiusInDegrees,
          _radiusCircle!.center.longitude - radiusInDegrees,
        ),
        northeast: LatLng(
          _radiusCircle!.center.latitude + radiusInDegrees,
          _radiusCircle!.center.longitude + radiusInDegrees,
        ),
      );

      if (moveCamera) {
        _controller!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50.0), // 50.0 is padding
        );
      } else {
        // Just update the visible region without moving the camera
        _controller!.getVisibleRegion().then((visibleRegion) {
          if (!bounds.contains(visibleRegion.northeast) || !bounds.contains(visibleRegion.southwest)) {
            // If the circle is not fully visible, then move the camera
            _controller!.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 50.0),
            );
          }
        });
      }
    }
  }

  Future<void> _animateCameraToCurrentLocation() async {
    if (!mounted) return;

    if (_currentPosition != null && _controller != null) {
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 18,
            bearing: _cameraBearing,
          ),
        ),
      );
    }
  }

  // Future<void> _getRideRoute(
  //   LatLng destination, {
  //   List<LatLng>? stops,
  //   bool useDirections = true,
  // }) async {
  //   if (useDirections) {
  //     DirectionsService.init(Properties.googleApiKey);
  //     final directionsService = DirectionsService();

  //     List<DirectionsWaypoint>? waypoints;
  //     if (stops != null) {
  //       waypoints = [
  //         for (LatLng lL in stops)
  //           DirectionsWaypoint(
  //             location: '${lL.latitude},${lL.longitude}',
  //           )
  //       ];
  //     }

  //     final request = DirectionsRequest(
  //       origin: '${_currentPosition!.latitude},${_currentPosition!.longitude}',
  //       destination: '${destination.latitude},${destination.longitude}',
  //       travelMode: TravelMode.driving,
  //       waypoints: waypoints,
  //     );

  //     directionsService.route(request, (
  //       DirectionsResult response,
  //       DirectionsStatus? status,
  //     ) async {
  //       if (status == DirectionsStatus.ok) {
  //         // Clear existing polylines
  //         _polylines.clear();

  //         // Fetch the encoded polyline from the response
  //         final route = response.routes?.first;
  //         final overviewPolyline = route?.overviewPolyline;

  //         if (overviewPolyline != null) {
  //           // save the route to driver's location for passenger's to see
  //           final points = route?.overviewPolyline?.points;
  //           _firebaseService.updateOnGoingTripWithPolylines(
  //             widget.requestModel!.currentRideDetails!.driverId!,
  //             points!,
  //           );

  //           // Add a polyline to the map
  //           final decodedPath = PolylinePoints().decodePolyline(overviewPolyline.points!);
  //           _polylines.add(Polyline(
  //             polylineId: const PolylineId('pickPolyline'),
  //             visible: true,
  //             points: decodedPath.map((e) => LatLng(e.latitude, e.longitude)).toList(),
  //             color: BColors.primaryColor,
  //             width: 5,
  //           ));

  //           // Process each leg and step to fetch the directions steps
  //           List<Step> stepInstructions = [];
  //           if (route != null && route.legs != null) {
  //             for (var leg in route.legs!) {
  //               for (var step in leg.steps!) {
  //                 stepInstructions.add(step);
  //                 // Log or process each step instruction
  //                 // debugPrint(
  //                 //   "Step Instruction: ${step.instructions}, Distance: ${step.distance?.text}, Duration: ${step.duration?.text}",
  //                 // );
  //               }
  //             }
  //           }

  //           // Optionally speak the directions if TTS is enabled
  //           if (!_isTTSVolumeMute && stepInstructions.isNotEmpty) {
  //             await _flutterTts?.awaitSpeakCompletion(true);
  //             _speakDirections(stepInstructions);
  //           }

  //           if (response.routes!.isNotEmpty) {
  //             _updateCameraBearing(response.routes!.first);
  //           }

  //           if (mounted) setState(() {});
  //         }
  //       } else {
  //         toastContainer(
  //           text: "Unable to get direction",
  //           backgroundColor: BColors.red,
  //         );
  //       }
  //     });
  //   } else {
  //     if (_polySet != null) {
  //       _polylines = _polySet!;
  //     } else {
  //       _polylines.add(
  //         Polyline(
  //           polylineId: const PolylineId('pickPolyline'),
  //           visible: true,
  //           points: [
  //             LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
  //             ...stops ?? [],
  //             destination,
  //           ],
  //           color: BColors.primaryColor,
  //           width: 5,
  //         ),
  //       );
  //     }

  //     if (mounted) setState(() {});
  //   }
  // }

  void _updateCameraBearing(DirectionsRoute route) {
    if (!mounted) return;

    if (_currentPosition != null && route.legs!.isNotEmpty && route.legs!.first.steps!.isNotEmpty) {
      Step firstStep = route.legs!.first.steps!.first;
      double bearing = Geolocator.bearingBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        firstStep.endLocation!.latitude,
        firstStep.endLocation!.longitude,
      );
      if (mounted) {
        setState(() {
          _cameraBearing = bearing;
        });
      }
      _animateCameraToCurrentLocation();
    }
  }

  Future<void> _speakDirections(List<Step> steps) async {
    if (_flutterTts == null) {
      // Handle the case where the TTS plugin is not initialized
      return;
    }

    try {
      for (var step in steps) {
        String maneuverText = '';
        switch (step.maneuver) {
          case 'turn-left':
            maneuverText = 'Turn left';
            break;
          case 'turn-right':
            maneuverText = 'Turn right';
            break;
          case 'straight':
            maneuverText = 'Continue straight';
            break;
          case 'slight-left':
            maneuverText = 'Slight left';
            break;
          case 'slight-right':
            maneuverText = 'Slight right';
            break;
          case 'uturn':
            maneuverText = 'Make a U-turn';
            break;
          default:
            maneuverText = 'Continue';
            break;
        }

        String cleanedManeuver = cleanString(maneuverText);
        await _flutterTts?.speak(cleanedManeuver);
        await Future.delayed(Duration(seconds: step.duration!.value!.toInt()));
      }
    } catch (e) {
      // Handle any errors that might occur during the TTS process
      debugPrint('Error speaking directions: $e');
    }
  }

  void _onBack() {
    _disposeTts();
    navigation(context: context, pageName: "back");
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

      // After moving to the current location, fit the circle if it exists
      if (_radiusCircle != null) {
        _fitCircleInCamera();
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    if (mounted) setState(() {});
    if (_mapNextAction == null) {
      _controller!.moveCamera(CameraUpdate.scrollBy(0, -150));

      _onMoveCameraToCurrentLocation();
    }
  }

  Future<void> _loadCustomMarkerAssets() async {
    // loading current location asset image
    final Uint8List cLocationIcon = await _getBytesFromAsset(
      Images.currentLocation2,
      60,
    );
    _currentLocationIcon = BitmapDescriptor.bytes(cLocationIcon);

    final Uint8List liveDriverIcon = await _getBytesFromAsset(
      Images.mapLiveDriver,
      30,
    );
    _liveDriverIcon = BitmapDescriptor.bytes(liveDriverIcon);

    // loading car asset image
    // final Uint8List carIcon = await _getBytesFromAsset(
    //   Images.mapCar,
    //   80,
    // );
    // _carIcon = BitmapDescriptor.bytes(carIcon);
    if (mounted) setState(() {});
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
    ).listen((Position position) {
      if (_showCurrentLocationMaker) {
        if (mounted) {
          _currentLocationPosition = position;
          _currentLocation = LatLng(
            _currentLocationPosition!.latitude,
            _currentLocationPosition!.longitude,
          );
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
        }
      } else {
        debugPrint("current location marker removed");
      }
    });
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts?.setLanguage('en-US');
    await _flutterTts?.setSpeechRate(0.5);
    _flutterTts?.setVolume(0);
    _isTTSVolumeMute = true;

    _flutterTts?.setCompletionHandler(() {
      log("TTS: Completed");
    });

    _flutterTts?.setErrorHandler((msg) {
      log("TTS Error: $msg");
    });

    _flutterTts?.setStartHandler(() {
      log("TTS: Start");
    });
  }

  void _disposeTts() {
    _flutterTts?.setVolume(0);
    _flutterTts?.stop();
    _flutterTts = null;
  }

  void _onTTSVolume() {
    _isTTSVolumeMute = !_isTTSVolumeMute;
    _flutterTts?.setVolume(_isTTSVolumeMute ? 0 : 1);
    if (mounted) setState(() {});
  }
}
