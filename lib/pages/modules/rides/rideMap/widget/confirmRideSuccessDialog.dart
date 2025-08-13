import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/rideSelectModel.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget confirmRideSuccessDialog({
  required BuildContext context,
  required void Function(String action) onDialogAction,
  required ServicePurpose servicePurpose,
  required Rides? rideSelected,
}) {
  return PopScope(
    canPop: false,
    child: AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Image.asset(Images.success),
          const SizedBox(height: 20),
          Text("Booking Successful", style: Styles.h3BlackBold),
          const SizedBox(height: 20),
          Text(
            servicePurpose == ServicePurpose.ride
                ? "Your booking has been confirmed. Driver will pick you up in ${rideSelected != null ? formatDuration(rideSelected.duration!) : 'few min time'}"
                : "Your booking has been confirmed. Shopper will purchase your items and deliver them to you\n\nNB: Make sure to call the shopper",
            style: Styles.h5Black,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        button(
          onPressed: () =>
              servicePurpose == ServicePurpose.ride ? onDialogAction("cancel") : onDialogAction("trackDeliveryOrder"),
          text: servicePurpose == ServicePurpose.ride ? "Cancel" : "Track Order",
          color: BColors.white,
          context: context,
          useWidth: false,
          textColor: BColors.grey,
        ),
        button(
          onPressed: () => onDialogAction("done"),
          text: "Done",
          color: BColors.white,
          context: context,
          useWidth: false,
          textColor: BColors.primaryColor1,
        ),
      ],
    ),
  );
}
