import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget personalAddItemDialog({
  required BuildContext context,
  required void Function(String action) onDialogAction,
}) {
  return AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Text(
          "Suggest where you want your items to be bought?",
          style: Styles.h5Black,
          textAlign: TextAlign.center,
        ),
      ],
    ),
    actionsAlignment: MainAxisAlignment.spaceAround,
    actions: [
      button(
        onPressed: () => onDialogAction("no"),
        text: "No proceed",
        color: BColors.white,
        context: context,
        useWidth: false,
        textColor: BColors.black,
        padding: EdgeInsets.zero,
      ),
      button(
        onPressed: () => onDialogAction("yes"),
        text: "Suggest",
        color: BColors.white,
        context: context,
        useWidth: false,
        textColor: BColors.black,
        padding: EdgeInsets.zero,
      ),
    ],
  );
}
