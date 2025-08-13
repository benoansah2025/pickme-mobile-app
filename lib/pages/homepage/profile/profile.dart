import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/config/sharePreference.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/homepage/profile/widget/profileWidget.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final VoidCallback onWallet;
  final VoidCallback onMyBookings;
  const Profile({
    super.key,
    required this.onMyBookings,
    required this.onWallet,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final Repository _repo = new Repository();

  bool _isLoading = false;
  bool? _isWorkerMode;

  @override
  void initState() {
    super.initState();
    _getWorkerStatus();
    // _repo.fetchWalletBalance(true);
  }

  Future<void> _getWorkerStatus() async {
    await _repo.fetchWorkerInfo(true);
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("isWorker")) {
      _isWorkerMode = prefs.getBool("isWorker")!;
    } else {
      _isWorkerMode = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          profileWidget(
            context: context,
            onEditProfile: () => navigation(context: context, pageName: "editprofile"),
            onContactUs: () => navigation(context: context, pageName: "support"),
            onWallet: widget.onWallet,
            onEmergency: () => navigation(context: context, pageName: "emergency"),
            onVendors: () => navigation(context: context, pageName: "vendors"),
            onMyBookings: widget.onMyBookings,
            onBusinessProfile: () => navigation(context: context, pageName: "applicationstatus"),
            onMyCart: () {},
            onNotifications: () => navigation(context: context, pageName: "notifications"),
            onFavoriteSp: () => navigation(context: context, pageName: "favorite"),
            onBecomeWorker: () => navigation(context: context, pageName: "registrationselectservice"),
            isWorkerMode: _isWorkerMode,
            onWorkerMode: (bool value, String rideStatus, String? accountStatus) =>
                _onWorkerMode(value, rideStatus, accountStatus),
            onInvest: () => navigation(context: context, pageName: "investment"),
            onSettings: () => navigation(context: context, pageName: "accountsettings"),
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onWorkerMode(bool value, String rideStatus, String? accountStatus) async {
    if (accountStatus != "APPROVED") {
      toastContainer(text: "Your account is $accountStatus", backgroundColor: BColors.red);
      return;
    }

    if (rideStatus != "INACTIVE" && !value) {
      setState(() => _isLoading = true);
      Map<String, dynamic> reqBody = {
        "data": {
          "driverId": userModel!.data!.user!.userid,
        },
      };

      Response response = await FirebaseService().goOffline(reqBody);
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
}
