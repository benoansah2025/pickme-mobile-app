import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget homeDeliveryOptionsWidget({
  @required BuildContext? context,
  required void Function(String type) onDelivery,
}) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: const BoxDecoration(
      color: BColors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => onDelivery("personalShopper"),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: MediaQuery.of(context!).size.width * .43,
                decoration: BoxDecoration(
                  color: BColors.primaryColor.withOpacity(.2),
                  border: Border.all(color: BColors.primaryColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(Images.personalShopper),
                    const SizedBox(height: 10),
                    Text("Personal\nShopper", style: Styles.h4Primary),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => onDelivery("deliveryRunner"),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: MediaQuery.of(context).size.width * .43,
                decoration: BoxDecoration(
                  color: BColors.primaryColor1.withOpacity(.2),
                  border: Border.all(color: BColors.primaryColor1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(Images.deliveryRunner),
                    const SizedBox(height: 10),
                    Text("Delivery\nRunner", style: Styles.h4Primary1),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => onDelivery("accreditedVendors"),
          child: Container(
            padding: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width * .9,
            decoration: BoxDecoration(
              color: BColors.primaryColor1.withOpacity(.2),
              border: Border.all(color: BColors.primaryColor1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: Image.asset(Images.vendors),
              title: Text(
                "${Properties.titleShort.toUpperCase()} Accredited Vendors",
                style: Styles.h4Primary1,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
