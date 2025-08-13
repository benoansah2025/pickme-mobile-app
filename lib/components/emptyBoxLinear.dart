import 'package:flutter/material.dart';

import '../spec/colors.dart';
import '../spec/images.dart';
import '../spec/styles.dart';

Widget emptyBoxLinear(
  BuildContext context, {
  String msg = "",
  Color backgroundColor = BColors.white,
}) {
  return Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.symmetric(vertical: 20),
    height: 100,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: backgroundColor,
      boxShadow: [
        BoxShadow(
          color: BColors.black.withOpacity(.1),
          spreadRadius: .1,
          blurRadius: 20,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Stack(
      children: [
        Container(color: backgroundColor),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Image.asset(
            Images.empty,
            width: 100,
            height: 100,
          ),
          title: Text(msg, style: Styles.h4BlackBold),
        ),
      ],
    ),
  );
}
