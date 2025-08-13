import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

class CustomInfoWindow extends StatelessWidget {
  final String title;
  final double top, left;
  final double overlayWidth, overlayHeight;

  const CustomInfoWindow({
    super.key,
    required this.title,
    required this.left,
    required this.top,
    required this.overlayHeight,
    required this.overlayWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: SafeArea(
        child: Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 4.0,
          child: Container(
            width: overlayWidth,
            height: overlayHeight,
            padding: const EdgeInsets.all(5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              title,
              style: Styles.h7Black,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
