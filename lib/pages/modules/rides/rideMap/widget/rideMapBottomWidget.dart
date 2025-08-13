import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

enum QuickPlace { whereTo, home, work, recent, setLocation, onGoingTrip }

Widget rideMapBottomWidget({
  required BuildContext context,
  required void Function() onCurrentLocation,
  required void Function(QuickPlace place) onQuickPlace,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BColors.white,
            boxShadow: [
              BoxShadow(
                color: BColors.black.withOpacity(.2),
                spreadRadius: .1,
                blurRadius: 20,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onCurrentLocation,
            icon: const Icon(
              Icons.location_searching_rounded,
              color: BColors.black,
            ),
          ),
        ),
      ),
      SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: BColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => onQuickPlace(QuickPlace.whereTo),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: BColors.assDeep1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text("Where to?", style: Styles.h5BlackBold),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _layout(
                    context: context,
                    color: BColors.primaryColor,
                    text: 'Home',
                    onTap: () => onQuickPlace(QuickPlace.home),
                    icon: Icons.home_filled,
                  ),
                  _layout(
                    context: context,
                    color: BColors.primaryColor1,
                    text: 'Work',
                    onTap: () => onQuickPlace(QuickPlace.work),
                    icon: Icons.cases_rounded,
                  ),
                  _layout(
                    context: context,
                    color: BColors.red,
                    text: 'Recent',
                    onTap: () => onQuickPlace(QuickPlace.recent),
                    icon: Icons.restore,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _layout({
  required BuildContext context,
  required Color color,
  required String text,
  required IconData icon,
  required void Function() onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: MediaQuery.of(context).size.width * .3,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: BColors.assDeep1,
        border: Border.all(color: BColors.assDeep),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: BColors.white),
          ),
          const SizedBox(height: 10),
          Text(text, style: Styles.h5BlackBold),
        ],
      ),
    ),
  );
}
