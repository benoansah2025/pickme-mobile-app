import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget paymentmethodBottom({
  required BuildContext context,
  required TextEditingController promoCodeController,
  required FocusNode promoCodeFocusNode,
  required void Function() onApply,
  required void Function() onDone,
  required ServicePurpose purpose,
}) {
  return Container(
    color: BColors.white,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Do you have a Promo code? \nEnter it here to get a reduced amount",
          style: Styles.h6BlackBold,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: BColors.assDeep),
          ),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .7,
                height: 35,
                child: textFormField(
                  hintText: "Promo Code",
                  controller: promoCodeController,
                  focusNode: promoCodeFocusNode,
                  borderColor: BColors.transparent,
                ),
              ),
              const SizedBox(width: 10),
              button(
                onPressed: onApply,
                text: "Apply",
                color: BColors.primaryColor1,
                context: context,
                useWidth: false,
                textStyle: Styles.h5Black,
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        button(
          onPressed: onDone,
          text: purpose == ServicePurpose.ride ? "Done" : "Next",
          color: BColors.primaryColor,
          context: context,
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
