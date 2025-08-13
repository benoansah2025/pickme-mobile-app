import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';

import 'cachedImage.dart';
import 'circular.dart';

Widget profilePicWithUploadButton({
  @required BuildContext? context,
  @required String? profilePicture,
  @required void Function()? onUpload,
}) {
  return SizedBox(
    height: 130,
    child: Stack(
      children: [
        Center(
          child: circular(
            useGradient: true,
            child: cachedImage(
              context: context,
              image: profilePicture,
              height: 120,
              width: 120,
              placeholder: Images.defaultProfilePicOffline,
            ),
            size: 120,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 70),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: BColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: BColors.background, width: 2),
              ),
              child: IconButton(
                onPressed: onUpload,
                color: BColors.background,
                icon: const Icon(FeatherIcons.edit2),
                iconSize: 20,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
