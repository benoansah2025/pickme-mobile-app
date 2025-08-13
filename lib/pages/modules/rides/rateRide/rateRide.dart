import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/rateRideWidget.dart';

class RateRide extends StatefulWidget {
  final ServicePurpose servicePurpose;
  final TripDetailsModel? tripDetailsModel;

  const RateRide({
    super.key,
    this.servicePurpose = ServicePurpose.ride,
    this.tripDetailsModel,
  });

  @override
  State<RateRide> createState() => _RateRideState();
}

class _RateRideState extends State<RateRide> {
  final _commentController = new TextEditingController();
  final _commentFocusNode = new FocusNode();

  double _rate = 5;

  bool _isLoading = false;

  WorkersInfoModel? _workerDetailsInfoModel;

  @override
  void initState() {
    super.initState();
    _loadWorkerInfoDetails();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            rateRideWidget(
              context: context,
              rate: _rate,
              onRate: (double rate) => _onRate(rate),
              commentController: _commentController,
              commentFocusNode: _commentFocusNode,
              onSubmit: () => _onSubmit(),
              servicePurpose: widget.servicePurpose,
              tripDetailsModel: widget.tripDetailsModel!,
              workerDetailsInfoModel: _workerDetailsInfoModel,
            ),
            if (_isLoading) customLoadingPage(),
          ],
        ),
      ),
    );
  }

  Future<void> _loadWorkerInfoDetails() async {
    _workerDetailsInfoModel = await WorkersInfoProvider().fetch(userId: widget.tripDetailsModel!.driverId);
    setState(() {});
  }

  Future<void> _onSubmit() async {
    setState(() => _isLoading = true);

    final CollectionReference userCollection = FirebaseFirestore.instance.collection("Users");
    await userCollection.doc(widget.tripDetailsModel!.riderId).update({"currentTripId": ""});

    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.tripRating,
          "userid": widget.tripDetailsModel!.driverId,
          "tripId": widget.tripDetailsModel!.tripId,
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
