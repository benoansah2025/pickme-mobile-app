import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';

class NotificationsModel {
  List<NotificationData>? notificationData;
  List<NotificationData>? todayNotifiactionData;

  NotificationsModel({this.notificationData});

  NotificationsModel.fromJson(Map<String, dynamic> json) {
    notificationData = <NotificationData>[];
    json.forEach((key, data) {
      notificationData!.add(new NotificationData.fromJson(key, data));
    });

    // sort notification by timestamp
    notificationData!.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

    todayNotifiactionData = <NotificationData>[];
    if (notificationData!.isNotEmpty) {
      todayNotifiactionData = notificationData!.where((element) {
        final DateTime now = DateTime.now();
        final DateTime date = element.timestamp!.toDate();
        return now.day == date.day && now.month == date.month && now.year == date.year && !element.read!;
      }).toList();

      // // remove today notification from notificationData
      // notificationData!.removeWhere((element) {
      //   final DateTime now = DateTime.now();
      //   final DateTime date = element.timestamp!.toDate();
      //   return now.day == date.day && now.month == date.month && now.year == date.year;
      // });
    }
  }
}

class NotificationData {
  bool? read;
  Data? data;
  String? key;
  String? title;
  String? body;
  Timestamp? timestamp;
  String? timeAgo;
  TripDetailsModel? tripDetailsModel;

  NotificationData({
    this.read,
    this.data,
    this.key,
    this.title,
    this.body,
    this.timestamp,
    this.timeAgo,
    this.tripDetailsModel,
  });

  NotificationData.fromJson(String this.key, Map<String, dynamic> json) {
    read = json['read'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    title = json['title'];
    body = json['body'];
    timestamp = json['timestamp'];
    if (timestamp != null) timeAgo = getTimeago(timestamp!.toDate());

    if (data?.page == "bookings" && data!.tripId != null) {
      // get trip details
      FirebaseService().tripDetails(data!.tripId!).then((TripDetailsModel? tripDetailsModel) {
        this.tripDetailsModel = tripDetailsModel;
        title = "From: ${tripDetailsModel?.pickupLocation ?? 'N/A'}";
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['read'] = read;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['title'] = title;
    data['body'] = body;
    data['timestamp'] = timestamp;
    return data;
  }
}

class Data {
  String? riderId;
  String? driverId;
  String? tripId;
  String? page;

  Data({this.riderId, this.driverId, this.tripId, this.page});

  Data.fromJson(Map<String, dynamic> json) {
    riderId = json['riderId'];
    driverId = json['driverId'];
    tripId = json['tripId'];
    page = json['page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['riderId'] = riderId;
    data['driverId'] = driverId;
    data['tripId'] = tripId;
    data['page'] = page;
    return data;
  }
}
