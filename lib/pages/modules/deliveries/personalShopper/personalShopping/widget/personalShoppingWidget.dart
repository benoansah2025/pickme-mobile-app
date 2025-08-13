import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget personalShoppingWidget({
  required BuildContext context,
  required void Function() onProceed,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Order from a store/marketplace", style: Styles.h3BlackBold),
          const SizedBox(height: 20),
          Text(
            "Order anything from any nearby Store. The Personal Shopper will shop for you and deliver to your door steps.\n\nEg. You may want to order Water Bottle, Cold Drink, Beer & food for a quick party you may have arranged. You can make a list of these items, enter their prices and suggest names of stores or places where they can be purchased from by using our app. The personal shopper will receive your order and be at your service. He will confirm prices and details with you and then purchase the items and deliver to your location instantly. You will be able to see his location in real time on Map while he is bringing items to your home.",
            style: Styles.h6Black,
          ),
          const SizedBox(height: 40),
          button(
            onPressed: onProceed,
            text: "What do you need? ",
            color: BColors.primaryColor,
            context: context,
            useWidth: false,
            buttonRadius: 20,
            postFixIcon: const Icon(
              Icons.arrow_forward_ios,
              color: BColors.white,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
