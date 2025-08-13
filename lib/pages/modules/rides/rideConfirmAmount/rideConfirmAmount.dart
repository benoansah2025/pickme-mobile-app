import 'package:flutter/material.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/pages/modules/payments/walletPayRide/walletPayRide.dart';
import 'package:pickme_mobile/pages/modules/rides/rateRide/rateRide.dart';

import 'widget/rideConfirmAmountWidget.dart';

class RideConfirmAmount extends StatefulWidget {
  final String tripId;
  const RideConfirmAmount({
    super.key,
    required this.tripId,
  });

  @override
  State<RideConfirmAmount> createState() => _RideConfirmAmountState();
}

class _RideConfirmAmountState extends State<RideConfirmAmount> {
  final _firebaseService = new FirebaseService();
  TripDetailsModel? _tripDetailsModel;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            if (_tripDetailsModel != null)
              rideConfirmAmountWidget(
                context: context,
                onOk: () => _onOk(),
                tripDetailsModel: _tripDetailsModel!,
              ),
            if (_isLoading) customLoadingPage(),
          ],
        ),
      ),
    );
  }

  void _onOk() {
    if (_tripDetailsModel!.paymentMethod == "CASH") {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => RateRide(
              tripDetailsModel: _tripDetailsModel,
            ),
          ),
          (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => WalletPayRide(
              tripDetailsModel: _tripDetailsModel,
            ),
          ),
          (Route<dynamic> route) => false);
    }
  }

  Future<void> _loadTrip() async {
    setState(() => _isLoading = true);
    _tripDetailsModel = await _firebaseService.tripDetails(widget.tripId);
    setState(() => _isLoading = false);

    if (_tripDetailsModel == null) {
      if (!mounted) return;
      infoDialog(
        context: context,
        type: PanaraDialogType.error,
        text: "Unable to get trip details please report",
        confirmBtnText: "Ok",
        onConfirmBtnTap: () => navigation(context: context, pageName: "homepage"),
      );

      return;
    }
  }
}
