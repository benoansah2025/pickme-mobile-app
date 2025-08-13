import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';

Widget emptyBox(
  BuildContext context, {
  String msg = "",
  void Function()? onTap,
  String? buttonText,
  double subHeight = 120,
  double? imageScale,
}) {
  return Container(
    height: MediaQuery.of(context).size.height - subHeight,
    width: MediaQuery.of(context).size.width,
    alignment: Alignment.center,
    child: SingleChildScrollView(
      child: Column(
        children: [
          Image.asset(Images.empty, scale: imageScale),
          Center(
            child: Text(
              "Oops, Nothing Here !\n $msg",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: BColors.black,
              ),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: button(
                onPressed: onTap,
                text: "$buttonText",
                color: BColors.primaryColor,
                context: context,
              ),
            )
          ],
        ],
      ),
    ),
  );
}
