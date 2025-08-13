import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';

Widget circular({
  @required Widget? child,
  @required double? size,
  Color borderColor = BColors.assDeep,
  bool useGradient = false,
  bool useBorder = true,
}) {
  return Container(
    height: size,
    width: size,
    padding: useGradient ? const EdgeInsets.all(2) : null,
    decoration: BoxDecoration(
      border: useBorder ? Border.all(color: borderColor) : null,
      shape: BoxShape.circle,
      gradient: useGradient
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                BColors.obGrade1.withOpacity(.5),
                BColors.obGrade2.withOpacity(.5),
                BColors.obGrade3.withOpacity(.5),
                BColors.obGrade4.withOpacity(.5),
              ],
            )
          : null,
    ),
    child: ClipOval(child: child),
  );
}
