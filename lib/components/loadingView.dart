// Progress indicator widget to show loading.
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Widget loadingDoubleBounce(Color color, {double size = 50}) => Center(
      child: LoadingAnimationWidget.inkDrop(color: color, size: size),
    );
