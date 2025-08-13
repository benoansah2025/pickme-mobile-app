import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget deliverySendReceiveItemMap({
  required BuildContext context,
  required void Function(DeliveryAccessLocation value) onChangeLocation,
  required void Function() onDeliveryStartProceed,
  required Map<dynamic, dynamic> deliveryAddresses,
  required RideMapNextAction rideNextAction,
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
      mainAxisSize: MainAxisSize.min,
      children: [
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text("DELIVERY VEHICLE TYPE", style: Styles.h6Black),
                const SizedBox(height: 10),
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  leading: SvgPicture.asset(Images.moto),
                  title: Text("Motor Bike", style: Styles.h4BlackBold),
                  subtitle: Text(
                    "Items will be delivered on a motor bike",
                    style: Styles.h6Black,
                  ),
                ),
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  onTap: () => onChangeLocation(
                    DeliveryAccessLocation.pickUpLocation,
                  ),
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: BColors.primaryColor),
                    ),
                    child: const Icon(
                      Icons.circle,
                      color: BColors.primaryColor,
                      size: 15,
                    ),
                  ),
                  title: Text("PICKUP", style: Styles.h6Black),
                  subtitle: Text(
                    deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["name"] == ""
                        ? "My current location"
                        : deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["name"],
                    style: Styles.h4BlackBold,
                  ),
                  trailing: rideNextAction == RideMapNextAction.deliverySendItem
                      ? button(
                          onPressed: () => onChangeLocation(
                            DeliveryAccessLocation.pickUpLocation,
                          ),
                          text: "Change",
                          color: BColors.primaryColor,
                          context: context,
                          useWidth: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          textStyle: Styles.h5Black,
                          icon: const Icon(
                            Icons.watch_later_outlined,
                            color: BColors.white,
                          ),
                          height: 40,
                        )
                      : null,
                ),
                ListTile(
                  onTap: () => onChangeLocation(
                    DeliveryAccessLocation.whereToLocation,
                  ),
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.location_on,
                    color: BColors.primaryColor1,
                  ),
                  title: Text("WHERE TO", style: Styles.h6Black),
                  subtitle: Text(
                    deliveryAddresses[DeliveryAccessLocation.whereToLocation] == null
                        ? "Enter location"
                        : deliveryAddresses[DeliveryAccessLocation.whereToLocation]["name"],
                    style: Styles.h4BlackBold,
                  ),
                  trailing: rideNextAction == RideMapNextAction.deliveryReceiveItem
                      ? button(
                          onPressed: () => onChangeLocation(
                            DeliveryAccessLocation.whereToLocation,
                          ),
                          text: "Change",
                          color: BColors.primaryColor,
                          context: context,
                          useWidth: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          textStyle: Styles.h5Black,
                          icon: const Icon(
                            Icons.watch_later_outlined,
                            color: BColors.white,
                          ),
                          height: 40,
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                button(
                  onPressed: onDeliveryStartProceed,
                  text: "Next",
                  color: BColors.primaryColor,
                  context: context,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
