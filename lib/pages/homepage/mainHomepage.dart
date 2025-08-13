// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/firebase/firebaseAuth.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/config/sharePreference.dart';
import 'package:pickme_mobile/models/driverDetailsModel.dart';
import 'package:pickme_mobile/models/driverRequestModel.dart';
import 'package:pickme_mobile/models/notificationsModel.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/homepage/bookings/bookings.dart';
import 'package:pickme_mobile/pages/homepage/inviteFriend/inviteFriend.dart';
import 'package:pickme_mobile/pages/homepage/profile/profile.dart';
import 'package:pickme_mobile/pages/homepage/wallet/wallet.dart';
import 'package:pickme_mobile/pages/homepage/workerBookings/workerBookings.dart';
import 'package:pickme_mobile/pages/homepage/workerHome/widget/workerHomeDrawer.dart';
import 'package:pickme_mobile/pages/homepage/workerHome/workerHome.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/rideMap.dart';
import 'package:pickme_mobile/pages/modules/worker/workerMap/workerMap.dart';
import 'package:pickme_mobile/providers/locationProdiver.dart';
import 'package:pickme_mobile/providers/recordLiveLocationProvider.dart';
import 'package:pickme_mobile/providers/homepageListenerProvider.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'home/home.dart';
import 'workerHome/widget/workerDeliveryRunnerMultiRequestDialog.dart';
import 'workerHome/widget/workerDeliveryRunnerSingleRequestDialog.dart';
import 'workerHome/widget/workerRideRequestDialog.dart';

class MainHomepage extends StatefulWidget {
  final int selectedPage;
  final bool isWorkerDashboard;

  const MainHomepage({
    super.key,
    this.selectedPage = 0,
    this.isWorkerDashboard = false,
  });

  @override
  State<MainHomepage> createState() => _MainHomepageState();
}

class _MainHomepageState extends State<MainHomepage> {
  final Repository _repo = new Repository();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LocationProvider _locationProvider = LocationProvider();
  final RecordLiveLocationProvider _recordLiveLocation = new RecordLiveLocationProvider();

  int _selectedIndex = 0;
  bool _isLoading = false, _isWorkerMode = false;

  Position? _currentLocation;

  StreamSubscription<DriverRequestModel?>? _driverRequestSubscription;
  StreamSubscription<Position?>? _locationSubscription;

  final FirebaseService _firebaseService = new FirebaseService();

  final List<String> _bottomIcons = [
    Images.home,
    Images.bookings,
    Images.wallet,
    Images.inviteFriend,
    Images.profile,
  ];

  final List<String> _bottomIconsUnclick = [
    Images.homeUnclick,
    Images.bookingsUnclick,
    Images.walletUnclick,
    Images.inviteFriendUnclick,
    Images.profileUnclick,
  ];

  List<Widget> _widgetOptions = [];

  DateTime? lastPressed;

  Future<NotificationsModel?>? _notificationsModel;
  DriverDetailsModel? _driverDetailsModel;
  Future<List<String>?>? _workerServicesList;

  @override
  void initState() {
    super.initState();

    _isWorkerMode = widget.isWorkerDashboard;
    _initPage();

    _onCheckWorkStartForLiveLocation();
    _repo.fetchVehicleTypes(true);
    _repo.fetchWorkerInfo(true);
    _repo.fetchWalletBalance(true);
    _repo.fetchWorkersAppreciation(true);
    _repo.fetchAllTrips(true);
    _repo.fetchGeofences(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationsModel = FirebaseService().getNotifications(userModel!.data!.user!.userid!);
      FirebaseService().getDriverLocationDetails(userModel!.data!.user!.userid!).listen((DriverDetailsModel? model) {
        _driverDetailsModel = model;
        if (mounted) setState(() {});
      });
      _workerServicesList = FirebaseService().getWorkerServices(userModel!.data!.user!.userid!);
      new HomepageListenerProvider().tripListening(context);
      new HomepageListenerProvider().userTokenListening(
        loading: () => setState(() => _isLoading = true),
        notLoading: () => setState(() => _isLoading = false),
        context: context,
      );
      _loadCurrentTrip();
    });
  }

  @override
  void dispose() {
    // _locationSubscription?.cancel();
    _driverRequestSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (invoke) {
        if (invoke) return;
        if (_selectedIndex == 0) {
          DateTime now = DateTime.now();
          if (lastPressed == null || now.difference(lastPressed!) > const Duration(seconds: 2)) {
            lastPressed = now;
            toastContainer(text: "Press back again to exit", toastLength: Toast.LENGTH_SHORT);
          } else {
            // Exit the app if the second back press happens within 2 seconds
            SystemNavigator.pop();
          }
        } else {
          _onItemTapped(0);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: widget.isWorkerDashboard
            ? workerHomeDrawer(
                context: context,
                isWorkerMode: _isWorkerMode,
                onWorkerMode: (bool value, String status) => _onWorkerMode(value, status),
                onMyServices: () => navigation(context: context, pageName: "myServices"),
                onNotifications: () => navigation(context: context, pageName: "notifications"),
                onRewards: () => navigation(context: context, pageName: "workerAppreciation"),
                onPromotions: () => navigation(context: context, pageName: "promotions"),
                onSettings: () => navigation(context: context, pageName: "accountsettings"),
                onSupport: () => navigation(context: context, pageName: "support"),
                notificationsModel: _notificationsModel,
                workerServicesList: _workerServicesList,
                driverDetailsModel: _driverDetailsModel,
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          elevation: 10,
          unselectedFontSize: 10,
          backgroundColor: BColors.white,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: BColors.primaryColor,
          unselectedItemColor: BColors.black,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: Styles.h8Primary,
          onTap: (int index) => _onItemTapped(index),
          items: <BottomNavigationBarItem>[
            for (int x = 0; x < _bottomIcons.length; ++x)
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  x == _selectedIndex ? _bottomIcons[x] : _bottomIconsUnclick[x],
                  // ignore: deprecated_member_use
                  color: _selectedIndex == x ? BColors.primaryColor : BColors.black,
                ),
                label: x == 0
                    ? "Home"
                    : x == 1
                        ? "Bookings"
                        : x == 2
                            ? "Wallet"
                            : x == 3
                                ? "Invite Friends"
                                : "Profile",
              ),
          ],
        ),
        body: Stack(
          children: [
            if (_currentLocation != null) _widgetOptions[_selectedIndex],
            if (_isLoading || _currentLocation == null) customLoadingPage(),
          ],
        ),
      ),
    );
  }

  Future<void> _onItemTapped(int index) async {
    _selectedIndex = index;
    setState(() {});
  }

  Future<void> _onWorkerMode(bool value, String status) async {
    if (status != "INACTIVE") {
      _scaffoldKey.currentState?.closeDrawer();

      setState(() => _isLoading = true);
      Map<String, dynamic> reqBody = {
        "data": {
          "driverId": userModel!.data!.user!.userid,
        },
      };

      Response response = await _firebaseService.goOffline(reqBody);
      int statusCode = response.statusCode;
      Map<String, dynamic> body = jsonDecode(response.body);
      setState(() => _isLoading = false);

      if (statusCode != 200) {
        log(body["error"].toString());
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

    _isWorkerMode = value;
    await saveBoolShare(key: "isWorker", data: value);
    setState(() {});
    if (!mounted) return;
    navigation(context: context, pageName: "homepage");
  }

  void _onIncomingRideRequest() {
    _driverRequestSubscription =
        _firebaseService.getDriverRequest(userModel!.data!.user!.userid!, _currentLocation!).listen(
      (DriverRequestModel? model) {
        if (model == null) return;

        if (model.status == "CALLED") {
          if (model.currentRideDetails!.serviceType == "ride") {
            showModalBottomSheet<dynamic>(
              context: context,
              isDismissible: false,
              enableDrag: false,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: BColors.white,
              builder: (context) => WorkerRideRequestDialog(
                onReject: () {
                  navigation(context: context, pageName: "back");
                  _onRideRequest(
                    purpose: ServicePurpose.ride,
                    action: "REJECT",
                    requestModel: model,
                  );
                },
                onAccept: () {
                  navigation(context: context, pageName: "back");
                  _onRideRequest(
                    purpose: ServicePurpose.ride,
                    action: "ACCEPT",
                    requestModel: model,
                  );
                },
                remainTimeInSec: model.requestTimeoutSec!,
                model: model,
              ),
            );
          } else if (model.currentRideDetails!.serviceType == "deliverySingle") {
            showModalBottomSheet<dynamic>(
              context: context,
              isDismissible: false,
              enableDrag: false,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: BColors.white,
              builder: (context) => WorkerDeliveryRunnerSingleRequestDialog(
                onReject: () {
                  // navigation(context: context, pageName: "back");
                  // _onRejectRideRequest();
                },
                onAccept: () {
                  // navigation(context: context, pageName: "back");
                  // _onAcceptRideRequest(ServicePurpose.deliveryRunnerSingle);
                },
                remainTimeInSec: model.requestTimeoutSec!,
              ),
            );
          } else if (model.currentRideDetails!.serviceType == "deliveryMultiple") {
            showModalBottomSheet<dynamic>(
              context: context,
              isDismissible: false,
              enableDrag: false,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: BColors.white,
              builder: (context) => WorkerDeliveryRunnerMultiRequestDialog(
                onReject: () {
                  // navigation(context: context, pageName: "back");
                  // _onRejectRideRequest();
                },
                onAccept: () {
                  // navigation(context: context, pageName: "back");
                  // _onAcceptRideRequest(ServicePurpose.deliveryRunnerMultiple);
                },
                remainTimeInSec: model.requestTimeoutSec!,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _onRideRequest({
    required ServicePurpose purpose,
    required String action,
    required DriverRequestModel requestModel,
  }) async {
    setState(() => _isLoading = true);

    FireAuth firebaseAuth = new FireAuth();
    String? token = await firebaseAuth.getToken();

    Map<String, dynamic> reqBody = {
      "action": HttpActions.acceptRide,
      "driverId": userModel!.data!.user!.userid,
      "tripId": requestModel.currentTripDetails!.tripId,
      "status": action.toUpperCase(),
      "driverFirebaseKey": token,
      "riderFirebaseKey": requestModel.currentRideDetails!.riderFirebaseKey,
      "riderId": requestModel.currentRideDetails!.riderId,
    };

    Response response = await _firebaseService.acceptRide(reqBody);
    int statusCode = response.statusCode;
    Map<String, dynamic> body = jsonDecode(response.body);

    setState(() => _isLoading = false);

    if (statusCode != 200) {
      log(body["error"].toString());
      if (!mounted) return;
      infoDialog(
        context: context,
        type: PanaraDialogType.error,
        text: body["msg"],
        confirmBtnText: "Ok",
      );
      return;
    }

    if (action == "ACCEPT") {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WorkerMap(
            currentLocation: _currentLocation,
            mapNextAction: WorkerMapNextAction.accept,
            servicePurpose: purpose,
            requestModel: requestModel,
          ),
        ),
      );
    }
  }

  Future<void> _initPage() async {
    // Get the current location without resetting the widgets
    _currentLocation = await _locationProvider.getCurrentLocation();
    _locationSubscription = _locationProvider.getPositionStream().listen((Position position) {
      _currentLocation = position;
      if (mounted) {
        setState(() {});
      }
    });

    setState(() {
      _widgetOptions = _initWidgetOptions(); // Initialize widgetOptions only once
      _isLoading = false;
      _selectedIndex = widget.selectedPage;
    });

    if (widget.isWorkerDashboard) {
      _onIncomingRideRequest();
    }
  }

  List<Widget> _initWidgetOptions() {
    return [
      widget.isWorkerDashboard
          ? WorkerHome(
              currentLocation: _currentLocation!,
              scaffoldKey: _scaffoldKey,
            )
          : Home(
              currentLocation: _currentLocation!,
              onProfile: () => navigation(context: context, pageName: "editProfile"),
            ),
      widget.isWorkerDashboard
          ? WorkerBookings(
              scaffoldKey: _scaffoldKey,
              currentLocation: _currentLocation!,
            )
          : Bookings(currentLocation: _currentLocation!),
      Wallet(isWorker: widget.isWorkerDashboard),
      const InviteFriends(),
      Profile(
        onMyBookings: () => _onItemTapped(1),
        onWallet: () => _onItemTapped(2),
      ),
    ];
  }

  Future<void> _onCheckWorkStartForLiveLocation() async {
    DriverDetailsModel? model =
        await FirebaseService().getDriverLocationDetails(userModel!.data!.user!.userid!).take(1).first;
    if (model != null) {
      // log(model.status.toString());
      if (model.status == "INACTIVE") {
        if ((await getHive("timeOnline")) == null) await saveHive(key: "timeOnline", data: "");
        _recordLiveLocation.record(action: StartStop.stop);
      } else {
        _recordLiveLocation.record(action: StartStop.start);

        if ((await getHive("timeOnline")) == null) {
          await saveHive(
            key: "timeOnline",
            data: model.goLiveTime?.toDate().toIso8601String() ?? "",
          );
        }
      }
    } else {
      if ((await getHive("timeOnline")) == null) await saveHive(key: "timeOnline", data: "");
    }
    return;
  }

  Future<void> _loadCurrentTrip() async {
    TripDetailsModel? tripDetailsModel = await FirebaseService().userOnGoingTrip(userModel!.data!.user!.userid!);
    if (tripDetailsModel != null && tripDetailsModel.tripId != null) {
      if (widget.isWorkerDashboard) {
        _firebaseService
            .getDriverRequest(userModel!.data!.user!.userid!, _currentLocation!)
            .take(1)
            .listen((DriverRequestModel? model) async {
          if (model == null) return;

          WorkerMapNextAction? action;
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
              // action = WorkerMapNextAction.accept;
              break;
          }

          if (action == null) return;

          if (!mounted) return;
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkerMap(
                currentLocation: _currentLocation,
                mapNextAction: action!,
                servicePurpose: ServicePurpose.ride, // TODO: check service purpose
                requestModel: model,
              ),
            ),
          );
          if (mounted) setState(() {});
        });
      } else {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideMap(
              currentLocation: _currentLocation,
              onGoingTripDetails: tripDetailsModel,
            ),
          ),
        );
      }
    }
  }
}
