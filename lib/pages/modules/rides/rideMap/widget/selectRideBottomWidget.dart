import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/shimmerItem.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/ridePickUpModel.dart';
import 'package:pickme_mobile/models/rideSelectModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget selectRideBottomWidget({
  required BuildContext context,
  required void Function() onPaymentMethod,
  required void Function() onRequest,
  required void Function(Rides ride) onRideSelected,
  required RideSelectModel? rideSelectModel,
  required Rides? rideSelected,
  required Map<String, dynamic> paymentMethod,
  required RidePickUpModel? ridePickUpModel,
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
        Container(
          height: 5,
          width: 60,
          decoration: BoxDecoration(
            color: BColors.assDeep,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 20),
        if (rideSelectModel == null) shimmerItem(numOfItem: 1),
        if (rideSelectModel != null)
          for (var ride in rideSelectModel.data!.drivers!.take(3)) ...[
            Container(
              color: rideSelected?.driverId == ride.driverId ? BColors.primaryColor1 : BColors.white,
              child: ListTile(
                onTap: () => onRideSelected(ride),
                dense: true,
                visualDensity: const VisualDensity(vertical: -1),
                leading: SizedBox(
                  height: 50,
                  width: 50,
                  child: Stack(
                    children: [
                      Icon(
                        rideSelected?.driverId == ride.driverId
                            ? Icons.check_circle_outline_outlined
                            : Icons.circle_outlined,
                        color: rideSelected?.driverId == ride.driverId ? BColors.white : BColors.black,
                        size: 25,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SvgPicture.asset(
                          getVehicleTypePicture(ride.data!.vehicleType ?? ""),
                          height: 25,
                          // ignore: deprecated_member_use
                          color: rideSelected?.driverId == ride.driverId
                              ? BColors.white
                              : convertToColor(ride.data!.vehicleColor ?? ""),
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  "${ride.data!.vehicleMake} ${ride.data!.vehicleModel}",
                  style: rideSelected?.driverId == ride.driverId ? Styles.h5WhiteBold : Styles.h5BlackBold,
                ),
                subtitle: Text(
                  "${ride.distanceInKm} km",
                  style: rideSelected?.driverId == ride.driverId ? Styles.h6White : Styles.h6Black,
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${Properties.curreny} ${rideSelected?.totalFee}",
                      style: rideSelected?.driverId == ride.driverId ? Styles.h5WhiteBold : Styles.h5BlackBold,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      formatDuration(ride.duration!),
                      style: rideSelected?.driverId == ride.driverId ? Styles.h6White : Styles.h6Black,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
          ],
        const SizedBox(height: 30),
        ListTile(
          onTap: onPaymentMethod,
          dense: true,
          visualDensity: const VisualDensity(vertical: -3),
          leading: const Icon(Icons.money, color: BColors.black),
          title: Text(
            "${paymentMethod["paymentMethod"]} Payment ${paymentMethod["discountPercentage"] != 0 ? '(${((paymentMethod["discountPercentage"] * 100) as double).toStringAsFixed(0)}% OFF)' : ''}",
            style: Styles.h5BlackBold,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: BColors.black,
            size: 15,
          ),
        ),
        const SizedBox(height: 20),
        button(
          onPressed: onRequest,
          text: "Request",
          color: BColors.primaryColor,
          context: context,
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}
