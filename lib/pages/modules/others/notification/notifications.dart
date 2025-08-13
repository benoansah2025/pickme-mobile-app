import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/emptyBox.dart';
import 'package:pickme_mobile/components/shimmerItem.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/models/notificationsModel.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/homepage/mainHomepage.dart';
import 'package:pickme_mobile/pages/modules/others/notification/widget/notificationsWidget.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widget/notificationTripDialog.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final FirebaseService _firebaseService = FirebaseService();
  NotificationsModel? _notificationsModel;

  @override
  void initState() {
    super.initState();
    _getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: BColors.white),
        backgroundColor: BColors.primaryColor,
        title: Text("Notification", style: Styles.h4WhiteBold),
      ),
      body: _notificationsModel == null
          ? shimmerItem()
          : _notificationsModel!.notificationData!.isEmpty
              ? emptyBox(context)
              : notificationsWidget(
                  context: context,
                  onMarkAsRead: () => _onMarkAsRead(),
                  notificationsModel: _notificationsModel!,
                  onNotification: (NotificationData data) => _onNotification(data),
                ),
    );
  }

  Future<void> _onNotification(NotificationData data) async {
    FirebaseService().markNotificationAsRead(userModel!.data!.user!.userid!, data.key!);

    if (data.data!.page == "bookings") {
      if (data.tripDetailsModel != null) {
        if (data.tripDetailsModel!.status == "TRIP-CANCELLED") {
          showModalBottomSheet<dynamic>(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            backgroundColor: BColors.white,
            builder: (context) => NotificationTripDialog(data: data),
          );
        } else {
          bool isWorkerMode = false;
          SharedPreferences? prefs = await SharedPreferences.getInstance();
          if (prefs.containsKey("isWorker")) {
            isWorkerMode = prefs.getBool("isWorker")!;
          }
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => MainHomepage(isWorkerDashboard: isWorkerMode, selectedPage: 1),
              ),
              (Route<dynamic> route) => false);
        }
      }
    }

    _getNotifications();
  }

  void _onMarkAsRead() {}

  void _getNotifications() {
    _firebaseService
        .getNotifications(userModel!.data!.user!.userid!)
        .then((NotificationsModel? notificationsModel) async {
      if (notificationsModel == null) {
        _notificationsModel = NotificationsModel.fromJson({});
      } else {
        _notificationsModel = notificationsModel;
        for (var data in _notificationsModel!.notificationData!) {
          if (data.data!.page == "bookings" && data.data!.tripId != null) {
            await _firebaseService.tripDetails(data.data!.tripId!).then((TripDetailsModel? tripDetailsModel) {
              data.tripDetailsModel = tripDetailsModel;
              setState(() {});
            });
          }
        }
      }
    });
  }
}
