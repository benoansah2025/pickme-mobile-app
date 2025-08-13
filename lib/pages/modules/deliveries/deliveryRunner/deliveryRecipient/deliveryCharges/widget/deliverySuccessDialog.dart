import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget deliverySuccessDialog({
  required BuildContext context,
  required void Function() onDone,
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
            "Your booking has been confirmed.Rider will pickup your package in 6 minutes.",
            style: Styles.h5Black,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        button(
          onPressed: () => onDone(),
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
