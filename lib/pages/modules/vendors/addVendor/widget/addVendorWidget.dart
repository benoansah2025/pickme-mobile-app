import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:progress_bar_steppers/stepper_data.dart';
import 'package:progress_bar_steppers/stepper_style.dart';
import 'package:progress_bar_steppers/steppers_widget.dart';

Widget addVendorWidget({
  required Widget child,
  required int currentStep,
  required void Function()? onNextAction,
  required BuildContext context,
  required bool isEdit,
}) {
  return Stack(
    children: [
      Steppers(
        direction: StepperDirection.horizontal,
        labels: [
          StepperData(label: 'Service'),
          StepperData(label: 'Personal'),
          StepperData(label: 'GPS'),
          if (!isEdit) StepperData(label: 'Subscription'),
        ],
        currentStep: currentStep,
        stepBarStyle: StepperStyle(maxLineLabel: isEdit ? 3 : 4),
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
                  text: ((isEdit && currentStep == 3) || currentStep == 4) ? "Submit" : "Next",
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
