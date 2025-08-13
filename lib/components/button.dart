import 'package:pickme_mobile/spec/colors.dart';
import 'package:flutter/material.dart';

Widget button({
  @required void Function()? onPressed,
  void Function()? onLongPressed,
  @required String? text,
  @required Color? color,
  Color textColor = BColors.white,
  bool colorFill = true,
  @required BuildContext? context,
  double divideWidth = 1.0,
  bool useWidth = true,
  double buttonRadius = 7,
  double height = 50,
  double elevation = .0,
  Color backgroundcolor = BColors.transparent,
  TextStyle? textStyle,
  Widget? icon,
  bool showBorder = true,
  EdgeInsetsGeometry? padding,
  bool centerItems = false,
  bool isSpaceBetween = false,
  Widget? postFixIcon,
  double borderWidth = 1,
}) {
  return SizedBox(
    width: useWidth ? MediaQuery.of(context!).size.width * divideWidth : null,
    height: height,
    child: ElevatedButton(
      onPressed: onPressed,
      onLongPress: onLongPressed,
      style: ElevatedButton.styleFrom(
        padding: padding,
        elevation: elevation,
        foregroundColor: textColor,
        backgroundColor: colorFill ? color : backgroundcolor,
        shape: showBorder
            ? RoundedRectangleBorder(
                side: BorderSide(color: color!, width: borderWidth),
                borderRadius: BorderRadius.circular(buttonRadius),
              )
            : null,
        textStyle: textStyle ??
            const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
      ),
      child: icon == null && postFixIcon == null
          ? Text("$text")
          : Row(
              mainAxisAlignment: isSpaceBetween
                  ? MainAxisAlignment.spaceBetween
                  : centerItems
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
              mainAxisSize: useWidth ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (icon != null) icon,
                if (!isSpaceBetween) const SizedBox(width: 7),
                Text("$text"),
                if (!isSpaceBetween && postFixIcon != null) const SizedBox(width: 7),
                if (postFixIcon != null) postFixIcon,
              ],
            ),
    ),
  );
}
