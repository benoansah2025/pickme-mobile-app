import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/flutterPincode.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget lockPincodeWidget({
  required BuildContext context,
  required void Function(String pin) onPinChange,
  required void Function() onFingerPrint,
  required GlobalKey<PinCodeState> pinCodeKey,
  String title = "Enter PIN",
}) {
  return Container(
    margin: const EdgeInsets.all(20),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset(Images.lock, scale: .8),
              const SizedBox(height: 20),
              Text(
                title,
                style: Styles.h3BlackBold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              Expanded(
                child: Center(
                  child: PinCodeWidget(
                    key: pinCodeKey,
                    minPinLength: 4,
                    maxPinLength: 4,
                    onChangedPin: (pin) => onPinChange(pin),
                    onEnter: (pin, _) => onFingerPrint(),
                    // delete: const Icon(Icons.backspace, color: Colors.grey),
                    numbersStyle: const TextStyle(fontSize: 20, color: BColors.primaryColor),
                    buttonColor: BColors.white,
                    borderSide: const BorderSide(color: BColors.primaryColor),
                    deleteButtonColor: BColors.white,
                    deleteIconColor: BColors.primaryColor,
                    filledIndicatorColor: BColors.primaryColor,
                    onPressColorAnimation: BColors.primaryColor,
                    deleteIconSize: 20,
                    enterIconData: Icons.check,
                    enterIconSize: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
