import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget filter({
  @required void Function()? onFilter,
  @required String? text,
  bool useMargin = true,
}) {
  return GestureDetector(
    onTap: onFilter,
    child: Container(
      padding: const EdgeInsets.all(10),
      margin: useMargin ? const EdgeInsets.all(10) : null,
      decoration: BoxDecoration(
        color: BColors.assDeep1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("$text", style: Styles.h6Black),
          const SizedBox(width: 10),
          const Icon(Icons.keyboard_arrow_down)
        ],
      ),
    ),
  );
}
