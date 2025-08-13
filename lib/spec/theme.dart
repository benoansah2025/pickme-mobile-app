import 'package:flutter/material.dart';

import 'colors.dart';
import 'styles.dart';

class Themes {
  Themes._();

  static ThemeData theme() {
    return ThemeData(
      // textButtonTheme: TextButtonThemeData(
      //   style: TextButton.styleFrom(
      //     textStyle: Styles.h4BlackXNormal,
      //     shape: const RoundedRectangleBorder(
      //       borderRadius: BorderRadius.all(
      //         Radius.circular(35),
      //       ),
      //     ),
      //     side: const BorderSide(color: BColors.grey),
      //   ),
      // ),
      scaffoldBackgroundColor: BColors.white,
      primaryColor: BColors.primaryColor,
      disabledColor: BColors.assDeep,
      appBarTheme: AppBarTheme(
        backgroundColor: BColors.white,
        elevation: .0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: BColors.black),
        actionsIconTheme: const IconThemeData(color: BColors.black),
        titleTextStyle: Styles.h4BlackBold,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BColors.primaryColor,
        foregroundColor: BColors.white,
      ),
      dialogBackgroundColor: BColors.white,
      drawerTheme: const DrawerThemeData(backgroundColor: BColors.white),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: BColors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: BColors.grey,
        thickness: .7,
      ),
   
    );
  }

  static ThemeData datePickerTheme() {
    return ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(primary: BColors.primaryColor),
    );
  }
}
