// Generates a transaction ID.
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_firebase_admin/messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:pickme_mobile/config/firebase/firebaseConfig.dart';

// Converts a distance value from meters to kilometers.
double convertMeterToKilometer(String distance) {
  if (distance.endsWith('km')) {
    return double.parse(distance.substring(0, distance.length - 2));
  } else {
    double meters = double.parse(distance.substring(0, distance.length - 1));
    return double.parse((meters / 1000).toStringAsFixed(2));
  }
}

// Converts the estimated distance to meters.
double convertEstimatedDistanceToMeters(String estimatedDistance) {
  final RegExp distancePattern = RegExp(r'^(\d+)(km|mi)$');
  final Match? matches = distancePattern.firstMatch(estimatedDistance);

  if (matches == null) {
    throw const FormatException('Invalid estimated distance format. It should be in the format of "20km" or "20mi".');
  }

  final double numericValue = double.parse(matches.group(1)!);
  final String unit = matches.group(2)!;

  if (unit == 'km') {
    return numericValue * 1000;
  } else if (unit == 'mi') {
    return numericValue * 1609.34;
  } else {
    throw const FormatException('Invalid unit of distance.');
  }
}

String genTransactionID([int length = 8]) {
  const String characters = '123456789ABCDEFGHIJKLMNPQRSTUVWXYZ';
  const int charactersLength = characters.length;
  String randomString = '';

  for (int i = 0; i < length; i++) {
    randomString += characters[(Random().nextInt(charactersLength))];
  }

  final DateTime now = DateTime.now();
  final String month = now.month.toString().padLeft(2, '0');
  final String day = now.day.toString().padLeft(2, '0');
  final String year = now.year.toString().substring(2);

  return 'TP$randomString$month$day$year';
}

// // Sends a notification to a device using FCM.
Future<void> sendNotification(
  String title,
  String body,
  String token,
  Map<String, String>? data,
) async {
  debugPrint(token);
  try {
    await FirebaseConfig.instance.getMessaging().send(
          TokenMessage(
            notification: Notification(title: title, body: body),
            token: token,
            data: {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              ...data ?? {},
            },
          ),
        );

    String? driverId = data?['driverId'];
    String? tripId = data?['tripId'];
    String? riderId = data?['riderId'];


    if (tripId == null) {
      return;
    }

    CollectionReference collection = FirebaseFirestore.instance.collection("Users");
    if (driverId != null) {
      await collection.doc(driverId).collection("notification").doc(tripId).set({
        "title": title,
        "body": body,
        "data": data,
        "read": false,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    if (riderId != null) {
      await collection.doc(riderId).collection("notification").doc(tripId).set({
        "title": title,
        "body": body,
        "data": data,
        "read": false,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
    debugPrint("Notification sent successfully.");
  } catch (e) {
    debugPrint("Failed to send notification: $e");
  }
}

// Calculates the trip duration in minutes from start and end dates.
Future<int?> getTripMinuteFromDate(DateTime startDate, DateTime endDate) async {
  final int interval = (endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch).abs();
  return (interval / (1000 * 60)).round();
}

// Retrieves trip settings from Firestore.
Future<Map<String, dynamic>> getTripSettings() async {
  final CollectionReference tripSettingCollection = FirebaseFirestore.instance.collection('trip_settings');
  final QuerySnapshot tripSettingSnapshot = await tripSettingCollection.get();

  if (tripSettingSnapshot.docs.isEmpty) {
    return {};
  }

  return tripSettingSnapshot.docs.first.data() as Map<String, dynamic>;
}

// Calculates the total trip fees.
// Future<Map<String, dynamic>> getTripTotalFees(
//     double km, int minute, double discountPercentage, double vehicleTypeBaseFare) async {
//   final Map<String, dynamic> tripSettings = await getTripSettings();

//   if (tripSettings.isEmpty) {
//     return {};
//   }

//   final double baseFee = double.parse(tripSettings['baseFee'].toString());
//   final double totalKmCharged = double.parse(tripSettings['pricePerKm'].toString()) * km;
//   final double totalMinCharged = double.parse(tripSettings['pricePerMinute'].toString()) * minute;

//   ///////
//   ///Old
//   //  const subTotal = total_km_charged + total_min_charged + baseFee;
// // New
//   //  const subTotal = total_km_charged + total_min_charged + baseFee + vehicleTypeBaseFare;

//   final double subTotal = totalKmCharged + totalMinCharged + baseFee + vehicleTypeBaseFare;
//   final double discountAmount = discountPercentage * subTotal;
//   final double grandTotal = (subTotal - discountAmount).ceilToDouble();

//   final double driverCommission = grandTotal * double.parse(tripSettings['driverPercentage'].toString());
//   final double pickmeCommission = grandTotal - driverCommission;

//   return {
//     'baseFee': baseFee.toStringAsFixed(2),
//     'totalKm': km.toStringAsFixed(2),
//     'totalKmCharged': totalKmCharged.toStringAsFixed(2),
//     'totalMinutes': minute,
//     'totalMinCharged': totalMinCharged.toStringAsFixed(2),
//     'discountPercentage': discountPercentage.toStringAsFixed(2),
//     'discountAmount': discountAmount.toStringAsFixed(2),
//     'subTotal': subTotal.toStringAsFixed(2),
//     'grandTotal': grandTotal.toStringAsFixed(2),
//     'driverPercentage': tripSettings['driverPercentage'],
//     'driverCommission': driverCommission.toStringAsFixed(2),
//     'pickmePercentage': (1 - double.parse(tripSettings['driverPercentage'].toString())).toStringAsFixed(2),
//     'pickmeCommission': pickmeCommission.toStringAsFixed(2),
//   };
// }
