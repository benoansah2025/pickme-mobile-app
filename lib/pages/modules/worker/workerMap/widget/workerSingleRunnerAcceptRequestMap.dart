import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget workerSingleRunnerAcceptRequestMap({
  required BuildContext context,
  required void Function() onCall,
  required void Function() onChat,
  required void Function() onArrivedSenderLocation,
  required void Function() onStartTrip,
  required void Function() onEndTrip,
  required WorkerMapNextAction? mapNextAction,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              mapNextAction == WorkerMapNextAction.startTrip
                  ? "Heading to receiver"
                  : mapNextAction == WorkerMapNextAction.arrived
                      ? "Package Taken"
                      : "Heading to Sender",
              style: Styles.h5BlackBold,
            ),
            Text(
              "${Properties.curreny} 45.00",
              style: Styles.h3BlackBold,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text("    sender’s details ".toUpperCase(), style: Styles.h6Black),
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
        const SizedBox(height: 10),
        ListTile(
          contentPadding: const EdgeInsets.only(left: 20),
          title: Text(
            "Sender's location".toUpperCase(),
            style: Styles.h6Black,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text("4 min (1 mile) away", style: Styles.h6BlackBold),
              Text(
                "Melcom chambers street",
                style: Styles.h4Black,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        ListTile(
          contentPadding: const EdgeInsets.only(left: 20),
          title: Text("package type".toUpperCase(), style: Styles.h6Black),
          subtitle: Text("Parcel", style: Styles.h4BlackBold),
        ),
        const SizedBox(height: 20),
        button(
          onPressed: mapNextAction == WorkerMapNextAction.startTrip
              ? onEndTrip
              : mapNextAction == WorkerMapNextAction.arrived
                  ? onStartTrip
                  : onArrivedSenderLocation,
          text: mapNextAction == WorkerMapNextAction.startTrip
              ? "Arrived at receiver's location"
              : mapNextAction == WorkerMapNextAction.arrived
                  ? "Head to receiver's location"
                  : "Arrived at sender's location",
          color: BColors.primaryColor,
          context: context,
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
