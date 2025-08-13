import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget deliveryRunnerTypeWidget({
  required Function(DeliveryType type) onDeliveryType,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "How do you want your delivery to be made ?",
            style: Styles.h3BlackBold,
          ),
          const SizedBox(height: 40),
          Text("Send something", style: Styles.h4BlackBold),
          const SizedBox(height: 10),
          Text(
            "Have a delivery guy deliver a package across town.",
            style: Styles.h5Black,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => onDeliveryType(DeliveryType.send),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: BColors.primaryColor,
              ),
              padding: const EdgeInsets.all(10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: BColors.white,
                  child: Icon(FeatherIcons.box, color: BColors.black),
                ),
                title: Text("Send a package", style: Styles.h4WhiteBold),
                subtitle: Text(
                  "Send small item(s) that can be carried on a Motor bike or okada",
                  style: Styles.h6White,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text("Get something", style: Styles.h4BlackBold),
          const SizedBox(height: 10),
          Text(
            "Have a delivery guy pick up a package from across town.",
            style: Styles.h5Black,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => onDeliveryType(DeliveryType.receive),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: BColors.primaryColor1,
              ),
              padding: const EdgeInsets.all(10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: BColors.white,
                  child: Icon(FeatherIcons.box, color: BColors.black),
                ),
                title: Text("Receive a package", style: Styles.h4WhiteBold),
                subtitle: Text(
                  "Receive small item(s) that can be carried on a Motor bike or okada",
                  style: Styles.h6White,
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}
