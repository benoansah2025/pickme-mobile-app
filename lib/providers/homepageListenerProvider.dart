import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pickme_mobile/config/auth/appLogout.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/modules/rides/rideConfirmAmount/rideConfirmAmount.dart';

bool pauseMainTripDetailsStreaming = false;

class HomepageListenerProvider {
  final _firebaseService = new FirebaseService();

  void tripListening(BuildContext context) {
    String userId = userModel!.data!.user!.userid!;

    FirebaseService().userTripDetailsStream(userId).listen(
      (TripDetailsModel? tripDetails) {
        if (tripDetails != null && userId == tripDetails.riderId) {
          Map<String, dynamic> reqBody = {
            "driverId": tripDetails.driverId,
            "driverFirebaseKey": tripDetails.driverFirebaseKey,
            "riderFirebaseKey": tripDetails.riderFirebaseKey,
            "newRideRequest": false,
            "onGoingTripId": tripDetails.tripId,
          };

          _firebaseService.bookRideStream(reqBody).listen((Response response) async {
            int statusCode = response.statusCode;
            Map<String, dynamic> body = jsonDecode(response.body);

            log(body.toString());

            if (statusCode == 200) {
              String driverStatus = body["data"]["status"];

              if (driverStatus == "TRIP-ENDED") {
                if (!pauseMainTripDetailsStreaming) {
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => RideConfirmAmount(tripId: tripDetails.tripId!),
                        ),
                        (Route<dynamic> route) => false);
                  }
                }
              }
            }
          });
        }
      },
    );
  }

  void userTokenListening({
    required void Function() loading,
    required void Function() notLoading,
    required BuildContext context,
  }) {
    String userId = userModel!.data!.user!.userid!;
    _firebaseService.userTokenStream(userId).listen((String? token) {
      if (token == null || userModel!.data!.authToken != token) {
        if (context.mounted) {
          onLogout(loading: loading, notLoading: notLoading, context: context);
        }
      }
    });
  }
}
