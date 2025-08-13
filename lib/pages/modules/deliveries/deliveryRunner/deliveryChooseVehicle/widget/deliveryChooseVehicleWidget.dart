import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget deliveryChooseVehicleWidget({
  required Function(String action) onAction,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Choose delivery vehicle ",
            style: Styles.h3BlackBold,
          ),
          const SizedBox(height: 10),
          Text(
            "Your package will be delivered on one of the available vehicles. Choose between the motor bike or the okada ",
            style: Styles.h6Black,
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => onAction("send"),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: BColors.assDeep1,
              ),
              padding: const EdgeInsets.all(10),
              child: ListTile(
                leading: SvgPicture.asset(Images.moto),
                title: Text("Motor Bike", style: Styles.h4BlackBold),
                subtitle: Text(
                  "Items will be delivered on a motor bike",
                  style: Styles.h6Black,
                ),
                trailing: Container(
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
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => onAction("send"),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: BColors.assDeep1,
              ),
              padding: const EdgeInsets.all(10),
              child: ListTile(
                leading: SvgPicture.asset(Images.okada),
                title: Text("Okada", style: Styles.h4BlackBold),
                subtitle: Text(
                  "Items will be delivered on an okada",
                  style: Styles.h6Black,
                ),
                trailing: Container(
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
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
