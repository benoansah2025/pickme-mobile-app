import 'package:flutter/material.dart';
import 'package:pickme_mobile/models/businessListingsModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Dialog vendorSubscriptionInfoDialog({
  required BuildContext context,
  required ListingDetails data,
}) {
  return Dialog(
    backgroundColor: BColors.white,
    child: Stack(
      children: [
        ListTile(
          title: Text("", style: Styles.h6BlackBold),
          trailing: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
            color: BColors.black,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 40),
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.subscriptionName ?? "N/A", style: Styles.h4BlackBold),
                const SizedBox(height: 10),
                Text("Features", style: Styles.h6Black),
                const SizedBox(height: 10),
                for (String feature in data.subscriptionFeatures ?? []) ...[
                  Text("- $feature", style: Styles.h6Black),
                  SizedBox(height: 5),
                ],
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${Properties.curreny} ${data.amountPaid ?? "N/A"}",
                      style: Styles.h5BlackBold,
                    ),
                    Text(
                      "${data.subscriptionHistory?.first.daysLeft ?? "N/A"} days left",
                      style: Styles.h6BlackBold,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text("History", style: Styles.h6BlackBold),
                const SizedBox(height: 10),
                for (SubscriptionHistory history in data.subscriptionHistory ?? []) ...[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: BColors.assDeep1,
                      border: Border.all(color: BColors.assDeep),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      title: Text(history.subscriptionName ?? "N/A", style: Styles.h5BlackBold),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Payment Method: ${history.paymentMethod ?? "N/A"}", style: Styles.h6Black),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${Properties.curreny} ${history.subscriptionPrice ?? "N/A"}",
                                    style: Styles.h5BlackBold,
                                  ),
                                  Text(
                                    "${history.subscriptionDurationDays ?? "N/A"} days",
                                    style: Styles.h6BlackBold,
                                  ),
                                ],
                              ),
                              Text(history.status ?? "N/A", style: Styles.h6BlackBold),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
