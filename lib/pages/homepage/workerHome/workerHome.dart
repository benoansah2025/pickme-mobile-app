import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/config/firebase/firebaseAuth.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/localNotification/notificationSchedular.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/driverRequestModel.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/modules/others/myServices/myServices.dart';
import 'package:pickme_mobile/pages/modules/worker/workerMap/workerMap.dart';
import 'package:pickme_mobile/providers/recordLiveLocationProvider.dart';
import 'package:pickme_mobile/providers/salesSummaryProvider.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/properties.dart';

import 'widget/workerHomeAppBar.dart';
import 'widget/workerHomeOngoingRequest.dart';

typedef OnWorkerOnOfflineToggle = void Function(int index);

class WorkerHome extends StatefulWidget {
  final Position currentLocation;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const WorkerHome({
    super.key,
    required this.currentLocation,
    required this.scaffoldKey,
  });

  @override
  State<WorkerHome> createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome> {
  final FirebaseService _firebaseService = new FirebaseService();
  final RecordLiveLocationProvider _recordLiveLocation = new RecordLiveLocationProvider();

  bool _isWorkerToggleLoading = false;

  TripDetailsModel? _tripDetailsModel;

  final Repository _repo = new Repository();

  @override
  void initState() {
    super.initState();
    _repo.fetchSalesSummary(true);
    _loadCurrentTrip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: workerHomeAppBar(
        onSos: (String? tap) => _onSOS(tap),
        onDrawer: () => widget.scaffoldKey.currentState?.openDrawer(),
      ),
      body: Stack(
        children: [
          WorkerMap(
            currentLocation: widget.currentLocation,
            onWorkerOnOfflineToggle: (int index) => _onWorkerOnOfflineToggle(index),
            isWorkerToggleLoading: _isWorkerToggleLoading,
          ),
          if (_tripDetailsModel != null && _tripDetailsModel?.tripId != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: workerHomeOngoingRequest(
                icon: _tripDetailsModel!.vehicleType == "BIKE"
                    ? OngoingRequestLayoutIconEnum.bIcon1
                    : OngoingRequestLayoutIconEnum.bIcon2,
                title: "Ongoing Ride",
                from: _tripDetailsModel!.pickupLocation,
                to: _tripDetailsModel!.destinationLocation,
                context: context,
                onOpen: () => _onOnGoingTrip(_tripDetailsModel!),
              ),
            ),
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

  Future<void> _onWorkerOnOfflineToggle(int index) async {
    // checking if worker account is approved
    if (!checkWorkerAccountStatus(showMsg: true)) return;

    Map? services;
    if (index == 1) {
      services = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MyServices(isWorkerStatus: true),
        ),
      );
      if (services == null) return;
    }

    // index = 0 => offline || index = 1 => online

    setState(() => _isWorkerToggleLoading = true);

    FireAuth firebaseAuth = new FireAuth();
    String? token = await firebaseAuth.getToken();

    final GeoFirePoint geoFirePoint = GeoFirePoint(
      GeoPoint(
        widget.currentLocation.latitude,
        widget.currentLocation.longitude,
      ),
    );

    await Repository().fetchWorkerInfo(true);

    Map<String, dynamic> reqBody = {
      "action": index == 0 ? HttpActions.goOffline : HttpActions.goOnline,
      "status": "ACTIVE",
      "position": {
        "geohash": geoFirePoint.geohash,
        "geopoint": [widget.currentLocation.latitude, widget.currentLocation.longitude],
        "heading": widget.currentLocation.heading,
      },
      "data": {
        "driverId": userModel!.data!.user!.userid,
        "driverName": workersInfoModel!.data!.name,
        "driverPhone": userModel!.data!.user!.phone,
        "driverPhoto": workersInfoModel!.data!.picture,
        "vehicleType": workersInfoModel!.data!.vehicleTypeId,
        "vehicleMake": workersInfoModel!.data!.vehicleMake,
        "vehicleModel": workersInfoModel!.data!.vehicleModel,
        "vehicleYear": workersInfoModel!.data!.vehicleYear,
        "vehicleNumber": workersInfoModel!.data!.vehicleNumber,
        "vehicleColor": workersInfoModel!.data!.vehicleColor,
        "driverFirebaseKey": token,
        ...services ?? {},
      }
    };

    Response response =
        index == 0 ? await _firebaseService.goOffline(reqBody) : await _firebaseService.goOnline(reqBody);
    int statusCode = response.statusCode;
    Map<String, dynamic> body = jsonDecode(response.body);

    await saveHive(
      key: "timeOnline",
      data: index == 0 ? "" : DateTime.now().toIso8601String(),
    );

    // schedule notification to remind workers 30 min before the sales end period
    if (salesSummaryModel == null) {
      await _repo.fetchSalesSummary(true);
    }

    // default 8:00 pm in case of a null data
    String paymentEndTime = salesSummaryModel?.data?.paymentEndTime ?? "20:00:00";

    final now = DateTime.now();
    final closingTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(paymentEndTime.split(":")[0]),
      int.parse(paymentEndTime.split(":")[1]),
      int.parse(paymentEndTime.split(":")[2]),
    );
    DateTime notificationTime = closingTime.subtract(const Duration(minutes: 10)); // substract 10 min from the closing time 

    await NotificationScheduler().scheduleNotification(
      dateTime: notificationTime,
      title: "Sales payment reminder",
      body:
          "Hi ${workersInfoModel!.data!.name},  it's 10 mins to the deadline for sales payment! If you have not paid kindly pay now using the App or pay at the office immediately to avoid Penalties",
      notificationId: 1,
    );

    setState(() => _isWorkerToggleLoading = false);
    if (statusCode == 200) {
      // record workers live location
      _recordLiveLocation.record(action: index == 0 ? StartStop.stop : StartStop.start);

      // if (!mounted) return;
      // coolAlertDialog(
      //   context: context,
      //   type: PanaraDialogType .success,
      //   text: body["msg"],
      //   confirmBtnText: "Ok",
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

  Future<void> _loadCurrentTrip() async {
    TripDetailsModel? model = await FirebaseService().userOnGoingTrip(userModel!.data!.user!.userid!);
    if (model != null &&
        (model.status == "ACCEPTED" ||
            model.status == "ARRIVED-PICKUP" ||
            model.status == "TRIP-STARTED" ||
            model.status == "TRIP-ENDED")) {
      _tripDetailsModel = model;
      setState(() {});
    }
  }

  void _onOnGoingTrip(TripDetailsModel model) {
    if (!checkWorkerAccountStatus(showMsg: true)) return;

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
}
