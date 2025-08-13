import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget trackDriverMap({
  required BuildContext context,
  required void Function() onCall,
  required void Function() onChat,
}) {
  return AnimatedContainer(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: BColors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: BColors.black.withOpacity(.1),
          spreadRadius: .1,
          blurRadius: 20,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    duration: const Duration(seconds: 3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Text("Shopper’s current location ", style: Styles.h6Black),
        const SizedBox(height: 10),
        Text("Makola Market Station, Accra ", style: Styles.h4Black),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: circular(
            child: cachedImage(
              context: context,
              image: "",
              height: 50,
              width: 50,
              placeholder: Images.defaultProfilePicOffline,
            ),
            size: 50,
          ),
          title: Text("Gregory Smith", style: Styles.h4BlackBold),
          subtitle: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: BColors.yellow1),
              const SizedBox(width: 10),
              Text("4.9", style: Styles.h6Black),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: BColors.primaryColor,
                radius: 25,
                child: IconButton(
                  icon: SvgPicture.asset(Images.message),
                  color: BColors.white,
                  onPressed: onChat,
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: BColors.primaryColor1,
                radius: 25,
                child: IconButton(
                  icon: const Icon(Icons.call),
                  color: BColors.white,
                  onPressed: onCall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
