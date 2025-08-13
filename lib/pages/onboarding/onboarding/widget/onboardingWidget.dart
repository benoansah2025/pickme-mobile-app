import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget onboardingWidget({
  @required BuildContext? context,
  @required String? image,
  @required String? title,
  @required String? subtitle,
  bool isLastPage = false,
  void Function()? onCurrentLocation,
  void Function()? onSelectManually,
}) {
  return Column(
    children: [
      const SizedBox(height: 30),
      Padding(
        padding: isLastPage ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 20),
        child: Image.asset(
          image!,
          width: MediaQuery.of(context!).size.width,
          height: MediaQuery.of(context).size.height * .45,
          fit: BoxFit.contain,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),
            Text(title!, style: Styles.h2Black),
            const SizedBox(height: 20),
            Text(
              subtitle!,
              style: Styles.h4Black,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            if (isLastPage) ...[
              button(
                onPressed: onCurrentLocation,
                text: "Use current location",
                color: BColors.primaryColor1,
                backgroundcolor: BColors.white,
                context: context,
                textStyle: Styles.h5Black,
                textColor: BColors.primaryColor1,
                icon: const Icon(Icons.navigation, color: BColors.primaryColor1),
                centerItems: true,
                colorFill: false,
              ),
              const SizedBox(height: 20),
              button(
                onPressed: onSelectManually,
                text: "Select it manually",
                color: BColors.white,
                context: context,
                textStyle: Styles.h5BlackBoldUnderline,
                textColor: BColors.primaryColor,
              ),
            ],
          ],
        ),
      ),
    ],
  );
}
