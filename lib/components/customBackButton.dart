import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget customBackButton(void Function() onBack) {
  return InkWell(
    onTap: onBack,
    child: Container(
      padding: const EdgeInsets.all(10.0),
      color: BColors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundColor: BColors.black,
            child: Icon(
              Icons.arrow_back_ios_new,
              color: BColors.white,
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          Text("Back", style: Styles.h5BlackBold),
        ],
      ),
    ),
  );
}
