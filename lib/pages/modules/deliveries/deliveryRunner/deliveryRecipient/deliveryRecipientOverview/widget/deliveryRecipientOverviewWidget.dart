import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget deliveryRecipientOverviewWidget({
  required BuildContext context,
  required Map<dynamic, dynamic> deliveryAddresses,
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
          Text("Delivery Overview", style: Styles.h3BlackBold),
          const SizedBox(height: 20),
          Text("DELIVERY VEHICLE TYPE", style: Styles.h6Black),
          const SizedBox(height: 10),
          Container(
            color: BColors.primaryColor1.withOpacity(.1),
            child: ListTile(
              leading: SvgPicture.asset(
                Images.moto,
                // ignore: deprecated_member_use
                color: BColors.primaryColor1,
              ),
              title: Text("Motor Bike", style: Styles.h4BlackBold),
              subtitle: Text(
                "Items will be delivered on a motor bike",
                style: Styles.h6Black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text("Trip details", style: Styles.h4BlackBold),
          const SizedBox(height: 10),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            contentPadding: EdgeInsets.zero,
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
            title: Text("PICKUP", style: Styles.h6Black),
            subtitle: Text(
              deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["name"] == ""
                  ? "My current location"
                  : deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["name"],
              style: Styles.h4BlackBold,
            ),
          ),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.location_on,
              color: BColors.primaryColor1,
            ),
            title: Text("WHERE TO", style: Styles.h6Black),
            subtitle: Text(
              deliveryAddresses[DeliveryAccessLocation.whereToLocation] == null
                  ? "Enter location"
                  : deliveryAddresses[DeliveryAccessLocation.whereToLocation]["name"],
              style: Styles.h4BlackBold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            rideMapNextAction == RideMapNextAction.deliverySendItem ? "Recipient Details" : "Sender Details",
            style: Styles.h4BlackBold,
          ),
          const SizedBox(height: 10),
          Text(
            "Qhobbie Junior\nKasoa Barrier, Kwadama-Green Avenue ST\n+233 50 678 8902",
            style: Styles.h5Black,
          ),
          const SizedBox(height: 20),
          Text("Review Package Guidelines", style: Styles.h4BlackBold),
          const SizedBox(height: 10),
          Text(
            "For a successful delivery, make sure yourpackage is:\n- compact \n-10 kg or less\n- GHC 200 or less in value \n- securely sealed and ready for pickup",
            style: Styles.h6Black,
          ),
          const Divider(),
          const SizedBox(height: 20),
          Text("Prohibited Items", style: Styles.h4BlackBold),
          const SizedBox(height: 10),
          Text(Strings.prohibitedText, style: Styles.h6Black),
          const Divider(),
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
