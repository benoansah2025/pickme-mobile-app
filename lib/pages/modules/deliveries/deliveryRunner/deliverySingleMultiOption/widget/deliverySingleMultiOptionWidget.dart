import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget deliverySingleMultiOptionWidget({
  required Function(ServicePurpose purpose) onDeliveryOption,
  required DeliveryType deliveryType,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => onDeliveryOption(ServicePurpose.deliveryRunnerSingle),
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
                title: Text("Single Delivery", style: Styles.h4WhiteBold),
                subtitle: Text(
                  deliveryType == DeliveryType.send
                      ? "With this feature you can send any item from one pick up point to a single destination. Send any item from any location to any single point of delivery"
                      : "With this feature you can receive any item from one pick up point to a single destination. Receive any item from any location to any single point of delivery",
                  style: Styles.h6White,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => onDeliveryOption(ServicePurpose.deliveryRunnerMultiple),
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
                title: Text("Multi Delivery", style: Styles.h4WhiteBold),
                subtitle: Text(
                  deliveryType == DeliveryType.send
                      ? "Want to send more than one items to multiple locations in a single go? It’s possible with this option. Send multiple deliveries to multiple destinations "
                      : "Want to receive more than one items from multiple locations in a single go? It’s possible with this option. Receive multiple deliveries from multiple locations ",
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
