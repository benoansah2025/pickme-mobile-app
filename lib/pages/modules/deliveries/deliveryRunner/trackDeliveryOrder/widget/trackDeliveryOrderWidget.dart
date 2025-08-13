import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget trackDeliveryOrderWidget({
  required BuildContext context,
  required void Function() onTrackOnMap,
  required void Function() onCall,
  required void Function() onChat,
  required void Function() onDone,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Track your order", style: Styles.h3BlackBold),
          const SizedBox(height: 30),
          _layout(
            time: "10:00 am",
            text: "Rider is heading towards you",
            check: true,
          ),
          _layout(
            time: "10:30 am",
            text: "Rider has arrived at your location ",
            check: true,
          ),
          _layout(
            time: "10:30 am",
            text: "Rider is heading towards receiver ",
            check: true,
          ),
          _layout(
            time: "10:30 am",
            text: "Rider has arrived at receiver's location ",
            check: true,
          ),
          _layout(
            time: "01:30 pm",
            text: "Items delivered successfully ",
            check: false,
          ),
          const SizedBox(height: 30),
          button(
            onPressed: onTrackOnMap,
            text: "Track rider on map",
            color: BColors.primaryColor1,
            context: context,
            useWidth: false,
            textStyle: Styles.h6BlackBold,
            padding: const EdgeInsets.all(5),
            postFixIcon: const Icon(
              Icons.gps_fixed,
              color: BColors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 30),
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
          const SizedBox(height: 30),
          button(
            onPressed: onDone,
            text: "Done",
            color: BColors.primaryColor,
            context: context,
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

Widget _layout({
  required String time,
  required String text,
  required bool check,
}) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 50,
          alignment: Alignment.centerLeft,
          child: Text(time, style: Styles.h6Black),
        ),
        const SizedBox(width: 5),
        Column(
          children: [
            Icon(
              Icons.check_circle,
              color: check ? BColors.primaryColor1 : BColors.primaryColor,
              size: 40,
            ),
            if (check) Container(height: 16, width: 3, color: BColors.assDeep),
          ],
        ),
        // const SizedBox(width: 10),
        // const Icon(Icons.cases_rounded),
      ],
    ),
    titleAlignment: ListTileTitleAlignment.top,
    title: Text(text, style: Styles.h6BlackBold),
  );
}
