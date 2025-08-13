import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget onboardingBottomWidget({
  @required BuildContext? context,
  @required int? pageNum,
  @required void Function()? onSkip,
}) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int x = 0; x < 3; ++x)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  margin: const EdgeInsets.only(right: 20),
                  width: pageNum == x ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: pageNum == x ? BColors.primaryColor1 : BColors.assDeep,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (pageNum != 2)
            button(
              onPressed: onSkip,
              text: "Skip all ->",
              color: BColors.white,
              context: context,
              textStyle: Styles.h5Black,
              textColor: BColors.black,
            ),
        ],
      ),
    ),
  );
}
