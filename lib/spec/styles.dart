import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class Styles {
  Styles._();

  //white
  static TextStyle h1XWhiteBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 50,
      fontWeight: FontWeight.bold,
      color: BColors.white,
    ),
  );

  static TextStyle h1WhiteBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: BColors.white,
    ),
  );

  static TextStyle h2WhiteBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: BColors.white,
    ),
  );

  static TextStyle h2WhiteBoldShadow = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: BColors.white,
      shadows: <Shadow>[
        Shadow(
          // offset: Offset(5, 3),
          blurRadius: 10.0,
          color: BColors.black,
        ),
      ],
    ),
  );

  static TextStyle h3WhiteBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: BColors.white,
    ),
  );

  static TextStyle h3AshBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: BColors.lightGray,
    ),
  );

  static TextStyle h3White = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: BColors.white,
    ),
  );

  static TextStyle h4WhiteBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: BColors.white,
    ),
  );

  static TextStyle h4White = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w600,
      color: BColors.white,
    ),
  );

  static TextStyle h5WhiteBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: BColors.white,
    ),
  );

  static TextStyle h5White = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: BColors.white,
    ),
  );

  static TextStyle h6WhiteBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: BColors.white,
    ),
  );

  static TextStyle h6White = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: BColors.white,
    ),
  );

//BColors.assDeep
  static TextStyle h5Ashdeep = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: BColors.assDeep,
    ),
  );

  static TextStyle h4Ashdeep = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      color: BColors.grey,
    ),
  );
//black
  static TextStyle h1XBlackBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.bold,
      color: BColors.black,
    ),
  );

   static TextStyle h1XBlack = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.normal,
      color: BColors.black,
    ),
  );

  static TextStyle h1BlackBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: BColors.black,
    ),
  );

  static TextStyle h1Black = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.normal,
      color: BColors.black,
    ),
  );

  static TextStyle h1BlackLight = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w300,
      color: BColors.black,
    ),
  );

  static TextStyle h2Black = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: BColors.black,
    ),
  );

  static TextStyle h2BlackUnderline = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: BColors.black,
      decoration: TextDecoration.underline,
    ),
  );

  static TextStyle h3BlackBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: BColors.black,
    ),
  );
  static TextStyle h3Black = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: BColors.black,
    ),
  );
  static TextStyle h4BlackXNormal = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w400,
      color: BColors.black,
    ),
  );

  static TextStyle h4BlackXBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: BColors.black,
    ),
  );

  static TextStyle h4Black = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: BColors.black,
    ),
  );

  static TextStyle h4BlackNormal = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w300,
      color: BColors.black,
    ),
  );

  static TextStyle h4BlackBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: BColors.black,
    ),
  );

  static TextStyle h4BlackBoldStrikeThough = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: BColors.black,
      decoration: TextDecoration.lineThrough,
    ),
  );

  static TextStyle h5BlackBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: BColors.black,
    ),
  );

  static TextStyle h5Black = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: BColors.black,
    ),
  );

  static TextStyle h5BlackBoldUnderline = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: BColors.black,
      decoration: TextDecoration.underline,
    ),
  );

  static TextStyle h6Black = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: BColors.black,
    ),
  );

  static TextStyle h6BlackBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: BColors.black,
    ),
  );

  static TextStyle h7Black = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: BColors.black,
    ),
  );

  static TextStyle h6AshDeep = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: BColors.assDeep1,
    ),
  );

//Primary
  static TextStyle h1PrimaryBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: BColors.primaryColor,
    ),
  );
  static TextStyle h2PrimaryBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: BColors.primaryColor,
    ),
  );

  static TextStyle h3Primary = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: BColors.primaryColor,
    ),
  );
  static TextStyle h3PrimaryBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: BColors.primaryColor,
    ),
  );
  static TextStyle h4Primary = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: BColors.primaryColor,
    ),
  );

  static TextStyle h4Primary1 = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: BColors.primaryColor1,
    ),
  );

  static TextStyle h5Primary1 = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: BColors.primaryColor1,
    ),
  );

 static TextStyle h5Primary1Bold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: BColors.primaryColor1,
    ),
  );


  static TextStyle h5PrimaryBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: BColors.primaryColor,
    ),
  );

  static TextStyle h6PrimaryBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: BColors.primaryColor,
    ),
  );

  static TextStyle h7PrimaryBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: BColors.primaryColor,
    ),
  );

  static TextStyle h8Primary = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.normal,
      color: BColors.primaryColor,
    ),
  );

  static TextStyle h5GradientBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: BColors.gradient,
    ),
  );

// yellow
  static TextStyle h5YellowBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: BColors.yellow1,
    ),
  );

//red
  static TextStyle h3RedBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: BColors.red,
    ),
  );

  static TextStyle h4RedBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: BColors.red,
    ),
  );

//green
  static TextStyle h3Green = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: BColors.green,
    ),
  );

  static TextStyle h5Green = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: BColors.green,
    ),
  );

  static TextStyle h5GreenBold = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: BColors.green,
    ),
  );

//button
  static TextStyle h4Button = GoogleFonts.inter(
    textStyle: const TextStyle(fontSize: 18),
  );
}
