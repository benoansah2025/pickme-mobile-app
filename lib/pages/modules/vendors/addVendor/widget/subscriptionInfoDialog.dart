import 'package:flutter/material.dart';
import 'package:pickme_mobile/models/subscriptionsModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

AlertDialog subscriptionInfoDialog({
  required BuildContext context,
  required SubscriptionData data,
}) {
  return AlertDialog(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Details", style: Styles.h6BlackBold),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close),
          color: BColors.black,
        )
      ],
    ),
    backgroundColor: BColors.white,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data.name ?? "N/A", style: Styles.h5BlackBold),
        const SizedBox(height: 10),
        Text(
          data.description ?? "N/A",
          style: Styles.h6Black,
        ),
        const SizedBox(height: 20),
        Text("Features", style: Styles.h6BlackBold),
        const SizedBox(height: 10),
        for (String feature in data.features ?? []) ...[
          Text("- $feature", style: Styles.h6BlackBold),
          SizedBox(height: 5),
        ],
        const SizedBox(height: 20),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${Properties.curreny} ${data.price ?? "N/A"}",
              style: Styles.h5BlackBold,
            ),
            Text(
              "${data.durationDays ?? "N/A"} days",
              style: Styles.h6BlackBold,
            ),
          ],
        ),
        const SizedBox(height: 10),
        
      ],
    ),
  );
}
