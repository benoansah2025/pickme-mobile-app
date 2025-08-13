import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget confirmDeliveryOrdersWidget({
  required BuildContext context,
  required Map<String, dynamic> itemsMap,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text("Shopping Overview", style: Styles.h3BlackBold),
          const SizedBox(height: 20),
          Text("Item list", style: Styles.h5BlackBold),
          const SizedBox(height: 20),
          Table(
            children: [
              for (var data in itemsMap["items"])
                TableRow(
                  children: [
                    Text("${data["name"]}", style: Styles.h5Black),
                    Text("${data["qty"]}", style: Styles.h5Black),
                    Text(
                      "${Properties.curreny} ${data["price"]}",
                      style: Styles.h5Black,
                    ),
                  ],
                ),
              TableRow(
                children: [
                  Text("", style: Styles.h5BlackBold),
                  Text("", style: Styles.h5Black),
                  Text("", style: Styles.h5Black),
                ],
              ),
              TableRow(
                children: [
                  Text("Total", style: Styles.h4BlackBold),
                  Text("", style: Styles.h5Black),
                  Text(
                    "${Properties.curreny} ${itemsMap["total"]}",
                    style: Styles.h4BlackBold,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Stores/Places", style: Styles.h4BlackBold),
          const SizedBox(height: 10),
          Text(
            "${itemsMap["storeSuggested"] == '' ? 'N/A' : itemsMap["storeSuggested"]}",
            style: Styles.h5Black,
          ),
          const SizedBox(height: 20),
          Text("Delivery Address Details ", style: Styles.h4BlackBold),
          const SizedBox(height: 10),
          Text(
            "Nii Haruna Quaye street 33\nHouse No 5\nFather's Legacy School \n0504563036",
            style: Styles.h6Black,
          ),
          const SizedBox(height: 50),
          Text("Prohibited Items", style: Styles.h4BlackBold),
          const SizedBox(height: 10),
          Text(Strings.prohibitedText, style: Styles.h6Black),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
