import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget deliveryChargesWidget({
  required BuildContext context,
  required void Function() onProceed,
  required RideMapNextAction rideMapNextAction,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text("Charges", style: Styles.h3BlackBold),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: BColors.background,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  title: Text(
                    "base fare".toUpperCase(),
                    style: Styles.h6Black,
                  ),
                  trailing: Text(
                    "${Properties.curreny} 8.00",
                    style: Styles.h5BlackBold,
                  ),
                ),
                const Divider(),
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  title: Text(
                    "distance (0.01 km)".toUpperCase(),
                    style: Styles.h6Black,
                  ),
                  trailing: Text(
                    "${Properties.curreny} 0.01",
                    style: Styles.h5BlackBold,
                  ),
                ),
                const Divider(),
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  title: Text(
                    "minimum  ( GH11.00)".toUpperCase(),
                    style: Styles.h6Black,
                  ),
                  trailing: Text(
                    "${Properties.curreny} 2.99",
                    style: Styles.h5BlackBold,
                  ),
                ),
                const Divider(),
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  title: Text(
                    "ride discount @ 5%".toUpperCase(),
                    style: Styles.h6Black,
                  ),
                  trailing: Text(
                    "${Properties.curreny} -0.40",
                    style: Styles.h5BlackBold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: BColors.background,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  title: Text(
                    "Subtotal".toUpperCase(),
                    style: Styles.h6Black,
                  ),
                  trailing: Text(
                    "${Properties.curreny} 10.45",
                    style: Styles.h5BlackBold,
                  ),
                ),
                const Divider(),
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  title: Text(
                    "rounding off".toUpperCase(),
                    style: Styles.h6Black,
                  ),
                  trailing: Text(
                    "${Properties.curreny} -0.45",
                    style: Styles.h5BlackBold,
                  ),
                ),
                const Divider(),
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  title: Text(
                    "net total".toUpperCase(),
                    style: Styles.h4BlackBold,
                  ),
                  trailing: Text(
                    "${Properties.curreny} 10.00",
                    style: Styles.h4Primary1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text("Responsible for Payment", style: Styles.h4BlackBold),
          const SizedBox(height: 10),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: BColors.primaryColor),
              ),
              child: const Icon(
                Icons.circle,
                color: BColors.primaryColor,
                size: 15,
              ),
            ),
            title: Text(
              rideMapNextAction == RideMapNextAction.deliverySendItem ? "Sender (Me)" : "Receiver (Me)",
              style: Styles.h5Black,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Note: Payments on deliveries are made by sender only",
            style: Styles.h6Black,
          ),
          const SizedBox(height: 30),
          button(
            onPressed: () => onProceed(),
            text: "Proceed to payment",
            color: BColors.primaryColor,
            context: context,
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
