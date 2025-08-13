import 'package:flutter/material.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

import '../spec/colors.dart';

void infoDialog({
  required BuildContext context,
  PanaraDialogType type = PanaraDialogType.normal,
  @required String? text,
  String confirmBtnText = "Ok",
  String cancelBtnText = "Cancel",
  void Function()? onConfirmBtnTap,
  bool barrierDismissible = true,
  bool showCancelBtn = false,
  bool closeOnConfirmBtnTap = true,
  Color? confirmBtnColor,
  Color? backgroundColor,
  TextStyle? confirmBtnTextStyle,
  TextStyle? cancelBtnTextStyle,
}) {
  PanaraInfoDialog.show(
    context,
    title: null,
    message: text ?? "",
    buttonText: confirmBtnText,
    onTapDismiss: () {
      if (closeOnConfirmBtnTap) Navigator.pop(context);
      if (onConfirmBtnTap != null) onConfirmBtnTap();
    },
    panaraDialogType: type == PanaraDialogType.normal ? PanaraDialogType.custom : type,
    barrierDismissible: barrierDismissible, // optional parameter (default is true)
    color: type == PanaraDialogType.normal ? BColors.primaryColor : backgroundColor ?? BColors.primaryColor,
  );
}
