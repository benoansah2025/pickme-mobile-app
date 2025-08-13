import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/firebase/firebaseUtils.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/modules/deliveries/deliveryRunner/deliveryRecipient/deliveryCharges/widget/deliverySuccessDialog.dart';
import 'package:pickme_mobile/pages/modules/payments/lockPincode/lockPincode.dart';
import 'package:pickme_mobile/pages/modules/rides/rateRide/rateRide.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/rideMap.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';

import 'widget/walletPayRideWidget.dart';

class WalletPayRide extends StatefulWidget {
  final ServicePurpose purpose;
  final Map<dynamic, dynamic>? deliveryAddresses;
  final TripDetailsModel? tripDetailsModel;

  const WalletPayRide({
    super.key,
    this.purpose = ServicePurpose.ride,
    this.deliveryAddresses,
    this.tripDetailsModel,
  });

  @override
  State<WalletPayRide> createState() => _WalletPayRideState();
}

class _WalletPayRideState extends State<WalletPayRide> {
  final _repo = new Repository();

  Position? _currentLocation;

  final _codeController = new TextEditingController();
  final _codeFocusNode = new FocusNode();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          walletPayRideWidget(
            context: context,
            codeController: _codeController,
            codeFocusNode: _codeFocusNode,
            onPay: () => _onPay(),
            tripDetailsModel: widget.tripDetailsModel,
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onPay() async {
    if (widget.purpose == ServicePurpose.ride) {
      setState(() => _isLoading = true);
      UserModel? model = await _repo.fetchProfile();
      setState(() => _isLoading = false);

      if (model == null) {
        toastContainer(text: "Wallet authentication failed", backgroundColor: BColors.red);
        return;
      }

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LockPincode(
          onSuccess: () => _onCompleteWalletPayment(),
        ),
      );
    } else if (widget.purpose == ServicePurpose.deliveryRunnerSingle ||
        widget.purpose == ServicePurpose.deliveryRunnerMultiple) {
      _onSubmitDeliveryRunner();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RideMap(
            currentLocation: _currentLocation!,
            servicePurpose: widget.purpose,
            mapNextAction: RideMapNextAction.searchingDriver,
          ),
        ),
      );
    }
  }

  Future<void> _onCompleteWalletPayment() async {
    final tripDetails = widget.tripDetailsModel!;
    if (double.parse(tripDetails.grandTotal!) > double.parse(userModel!.data!.user!.walletBalance!)) {
      toastContainer(text: "Insufficient amount, please top up", backgroundColor: BColors.red);
      return;
    }

    setState(() => _isLoading = true);
    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.transferWalletMoney,
          "senderId": tripDetails.riderId,
          "recipientId": tripDetails.driverId,
          "amount": tripDetails.grandTotal,
        },
      ),
    );

    log("$httpResult");
    if (httpResult["ok"]) {
      await sendNotification(
        tripDetails.driverFirebaseKey!,
        '🚖 Pickme',
        'Payment received ${Properties.curreny} ${tripDetails.grandTotal}',
        {"page": "wallet"},
      );
      await sendNotification(
        userModel!.data!.user!.firebaseKey!,
        '🚖 Pickme',
        'Transfer of ${Properties.curreny} ${tripDetails.grandTotal} for ride completed',
        {"page": "wallet"},
      );
      setState(() => _isLoading = false);
      toastContainer(
        text: httpResult["data"]["msg"],
        backgroundColor: BColors.green,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => RateRide(
              tripDetailsModel: widget.tripDetailsModel,
            ),
          ),
          (Route<dynamic> route) => false);
    } else {
      setState(() => _isLoading = false);
      httpResult["statusCode"] == 200
          ? toastContainer(
              text: httpResult["data"]["msg"],
              backgroundColor: BColors.red,
            )
          : toastContainer(
              text: httpResult["error"],
              backgroundColor: BColors.red,
            );
    }
  }

  void _onSubmitDeliveryRunner() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => deliverySuccessDialog(
        context: context,
        onDone: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideMap(
                currentLocation: _currentLocation!,
                servicePurpose: widget.purpose,
                mapNextAction: RideMapNextAction.searchingDriver,
                deliveryAddresses: widget.deliveryAddresses,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    WidgetsFlutterBinding.ensureInitialized();
    setState(() => _isLoading = true);
    _currentLocation = await Geolocator.getCurrentPosition();
    setState(() => _isLoading = false);
  }
}
