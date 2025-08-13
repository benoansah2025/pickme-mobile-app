import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget rideConfirmAmountWidget({
  required BuildContext context,
  required void Function() onOk,
  required TripDetailsModel tripDetailsModel,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    width: double.infinity,
    height: MediaQuery.of(context).size.height,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const SizedBox(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Images.wallet,
              height: 100,
              // ignore: deprecated_member_use
              color: BColors.primaryColor1,
            ),
            const SizedBox(height: 30),
            Text("${Properties.curreny} ${tripDetailsModel.grandTotal}", style: Styles.h1BlackBold),
            const SizedBox(height: 10),
            Text("Thanks for riding with us", style: Styles.h5Black),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("confirm amount and click on OK", style: Styles.h5BlackBold),
            const SizedBox(height: 40),
            button(
              onPressed: onOk,
              text: "OK",
              color: BColors.primaryColor,
              context: context,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ],
    ),
  );
}
