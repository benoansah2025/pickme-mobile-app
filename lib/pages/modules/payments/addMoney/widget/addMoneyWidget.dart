import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'addMoneyAppBar.dart';

Widget addMoneyWidget({
  required BuildContext context,
  required TextEditingController amountController,
  required FocusNode amountFocusNode,
  required void Function() onContinue,
}) {
  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      return <Widget>[const AddMoneyAppBar()];
    },
    body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("Enter Amount", style: Styles.h4BlackBold),
            const SizedBox(height: 40),
            Text(Properties.curreny, style: Styles.h3BlackBold),
            const SizedBox(height: 10),
            textFormField(
              hintText: "0.00",
              hintTextStyle: Styles.h1XBlack,
              controller: amountController,
              focusNode: amountFocusNode,
              textStyle: Styles.h1XBlack,
              textAlign: TextAlign.center,
              borderColor: BColors.background,
              inputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            ),
            const SizedBox(height: 30),
            button(
              onPressed: onContinue,
              text: "CONTINUE",
              color: BColors.primaryColor,
              context: context,
            ),
          ],
        ),
      ),
    ),
  );
}
