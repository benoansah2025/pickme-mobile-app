import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/models/driverRequestModel.dart';
import 'package:pickme_mobile/models/feeModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/rateCustomerWidget.dart';

class RateCustomer extends StatefulWidget {
  final ServicePurpose servicePurpose;
  final FeeModel feeModel;
  final String riderId;
  final DriverRequestModel? requestModel;

  const RateCustomer({
    super.key,
    this.servicePurpose = ServicePurpose.ride,
    required this.feeModel,
    required this.riderId,
    required this.requestModel,
  });

  @override
  State<RateCustomer> createState() => _RateCustomerState();
}

class _RateCustomerState extends State<RateCustomer> {
  final FirebaseService _firebaseService = new FirebaseService();

  final _commentController = new TextEditingController();
  final _commentFocusNode = new FocusNode();

  double _rate = 5;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            rateCustomerWidget(
              context: context,
              rate: _rate,
              onRate: (double rate) => _onRate(rate),
              commentController: _commentController,
              commentFocusNode: _commentFocusNode,
              onSubmit: () => _onSubmit(),
              servicePurpose: widget.servicePurpose,
              feeModel: widget.feeModel,
              requestModel: widget.requestModel,
            ),
            if (_isLoading) customLoadingPage(),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    setState(() => _isLoading = true);

    Position currentLocation = await Geolocator.getCurrentPosition();

    final GeoFirePoint geoFirePoint = GeoFirePoint(
      GeoPoint(
        currentLocation.latitude,
        currentLocation.longitude,
      ),
    );

    Map<String, dynamic> reqBody = {
      "action": HttpActions.tripCompleted,
      "driverId": userModel!.data!.user!.userid,
      "position": {
        "geohash": geoFirePoint.geohash,
        "geopoint": [currentLocation.latitude, currentLocation.longitude],
        "heading": currentLocation.heading,
      }
    };

    Response response = await _firebaseService.tripCompleted(reqBody);
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

    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.tripRating,
          "userid": widget.riderId,
          "tripId": widget.requestModel!.currentTripDetails!.tripId!,
          "rating": _rate.roundToDouble().toString(),
          "review": _commentController.text,
        },
      ),
    );

    log("$httpResult");
    if (httpResult["ok"]) {
      setState(() => _isLoading = false);
      // toastContainer(
      //   text: httpResult["data"]["msg"],
      //   backgroundColor: BColors.green,
      // );
      if (!mounted) return;
      navigation(context: context, pageName: "homepage");
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
      return;
    }
  }

  void _onRate(double rate) {
    _rate = rate;
    setState(() {});
  }
}
