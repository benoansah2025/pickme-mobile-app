import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';


Widget customLoadingPage({
  String msg = "",
  bool showClose = false,
  void Function()? onClose,
}) {
  return Container(
    color: BColors.black.withOpacity(.3),
    height: double.maxFinite,
    width: double.maxFinite,
    child: Stack(
      children: [
        Center(
          child: Container(
            width: 200,
            height: 150,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LoadingAnimationWidget.inkDrop(color: BColors.primaryColor, size: 50),
                if (msg != "") ...[
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      msg,
                      style: Styles.h5Black,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
        if (showClose)
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: BColors.black,
                child: IconButton(
                  onPressed: onClose,
                  color: BColors.white,
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
