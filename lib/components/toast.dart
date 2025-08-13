import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pickme_mobile/spec/colors.dart';

void toastContainer({
  @required String? text,
  Toast toastLength = Toast.LENGTH_LONG,
  Color backgroundColor = BColors.black,
  ToastGravity? gravity,
}) {
  Fluttertoast.showToast(
    msg: text!,
    toastLength: toastLength,
    gravity: gravity ?? ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: backgroundColor,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
