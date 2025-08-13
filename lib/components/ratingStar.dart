import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pickme_mobile/spec/colors.dart';

Widget ratingStar({
  @required double? rate,
  @required void Function(double rating)? function,
  double size = 40,
  bool ignore = false,
  int itemCount = 5,
  double itemPadding = 4,
  Color? unratedColor,
}) {
  return RatingBar.builder(
    initialRating: rate!,
    minRating: 1,
    direction: Axis.horizontal,
    itemSize: size,
    itemCount: itemCount,
    unratedColor: unratedColor ?? BColors.assDeep1.withOpacity(0.4),
    itemPadding: EdgeInsets.symmetric(horizontal: itemPadding),
    itemBuilder: (context, _) => const Icon(
      Icons.star,
      color: BColors.primaryColor1,
    ),
    onRatingUpdate: (double rating) => function!(rating),
    glow: true,
    glowColor: BColors.red,
    ignoreGestures: ignore,
  );
}
