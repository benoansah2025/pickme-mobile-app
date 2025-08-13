import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';

import 'loadingView.dart';

Widget cachedImage({
  @required BuildContext? context,
  @required String? image,
  @required double? height,
  @required double? width,
  String placeholder = Images.defaultProfilePicOffline,
  BoxFit fit = BoxFit.fill,
}) {
  return CachedNetworkImage(
    height: height,
    width: width,
    fit: fit,
    errorWidget: (widget, text, error) {
      return Image.asset(
        placeholder,
        height: height,
        width: width,
      );
    },
    progressIndicatorBuilder: (context, url, progress) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        loadingDoubleBounce(BColors.primaryColor, size: 20),
      ],
    ),
    imageUrl: image!,
  );
}
