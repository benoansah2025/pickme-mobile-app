import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget confirmDeliveryEstimateWidget({
  required BuildContext context,
  required void Function() onContinue,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Estimated Invoice Details ", style: Styles.h5BlackBold),
          const SizedBox(height: 10),
          Text(Strings.estimatedInvoiveText, style: Styles.h6Black),
          const SizedBox(height: 30),
          Table(
            children: [
              TableRow(
                children: [
                  Text("Item Cost", style: Styles.h6Black),
                  Text(
                    "${Properties.curreny} 80.00",
                    style: Styles.h5BlackBold,
                  ),
                ],
              ),
              TableRow(
                children: [
                  Text("Delivery Charge", style: Styles.h6Black),
                  Text(
                    "${Properties.curreny} 80.00",
                    style: Styles.h5BlackBold,
                  ),
                ],
              ),
              TableRow(
                children: [
                  Text("Cash Out Charge", style: Styles.h6Black),
                  Text(
                    "${Properties.curreny} 80.00",
                    style: Styles.h5BlackBold,
                  ),
                ],
              ),
              TableRow(
                children: [
                  Text("Shopper Fee", style: Styles.h6Black),
                  Text(
                    "${Properties.curreny} 80.00",
                    style: Styles.h5BlackBold,
                  ),
                ],
              ),
              TableRow(
                children: [
                  Text("", style: Styles.h6Black),
                  Text("", style: Styles.h5BlackBold),
                ],
              ),
              TableRow(
                children: [
                  Text("Total", style: Styles.h4BlackBold),
                  Text(
                    "${Properties.curreny} 160.00",
                    style: Styles.h4BlackBold,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          button(
            onPressed: () => onContinue(),
            text: "Ok",
            color: BColors.primaryColor,
            context: context,
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
