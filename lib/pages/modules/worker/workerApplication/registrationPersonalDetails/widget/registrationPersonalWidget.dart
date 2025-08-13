import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:progress_bar_steppers/steppers.dart';

Widget registrationPersonalWidget({
  required Widget child,
  required int currentStep,
  required void Function()? onNextAction,
  required BuildContext context,
}) {
  return Stack(
    children: [
      Steppers(
        direction: StepperDirection.horizontal,
        labels: [
          StepperData(label: 'Personal'),
          StepperData(label: 'ID Details'),
          StepperData(label: 'Vehicle Info'),
        ],
        currentStep: currentStep,
        stepBarStyle: StepperStyle(maxLineLabel: 3),
      ),
      Container(
        margin: const EdgeInsets.only(top: 60),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 60),
              child: child,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: BColors.white,
                padding: const EdgeInsets.all(10),
                child: button(
                  onPressed: onNextAction,
                  text: "Next",
                  color: BColors.primaryColor,
                  context: context,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
