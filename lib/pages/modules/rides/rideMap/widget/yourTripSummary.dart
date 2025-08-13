import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/shimmerItem.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/ridePickUpModel.dart';
import 'package:pickme_mobile/models/tripEstimateModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget yourTripSummaryWidget({
  required BuildContext context,
  required void Function() onPaymentMethod,
  required void Function() onSearchDrivers,
  required void Function() onStops,
  required void Function(Car data, String? tap) onSelectCar,
  required Map<String, dynamic> paymentMethod,
  required RidePickUpModel? ridePickUpModel,
  required Car? selectedCar,
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
        Center(
          child: Container(
            height: 5,
            width: 60,
            decoration: BoxDecoration(
              color: BColors.assDeep,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text("Your Trip", style: Styles.h4BlackBold),
        ),
        const SizedBox(height: 5),
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          visualDensity: const VisualDensity(vertical: -3),
          leading: Container(
            padding: const EdgeInsets.all(2),
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
          title: Text("Pickup", style: Styles.h7Black),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ridePickUpModel?.pickup?.name ?? ridePickUpModel!.pickup!.address!, style: Styles.h6BlackBold),
              const SizedBox(height: 5),
              Text(ridePickUpModel!.pickup!.address!, style: Styles.h7PrimaryBold),
            ],
          ),
        ),
        if (ridePickUpModel.busStops!.isEmpty) const Divider(indent: 50),
        if (ridePickUpModel.busStops!.isNotEmpty)
          SizedBox(
            height: 35,
            child: Stack(
              children: [
                Center(child: Divider(indent: 50, endIndent: ridePickUpModel.busStops!.isNotEmpty ? 70 : null)),
                if (ridePickUpModel.busStops!.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: button(
                      onPressed: onStops,
                      text: "Stops",
                      color: BColors.grey,
                      context: context,
                      useWidth: false,
                      textStyle: Styles.h6BlackBold,
                      padding: const EdgeInsets.all(5),
                      height: 35,
                    ),
                  ),
              ],
            ),
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          visualDensity: const VisualDensity(vertical: -3),
          leading: const Icon(Icons.location_on, color: BColors.primaryColor1),
          subtitle: Text(ridePickUpModel.whereTo!.name!, style: Styles.h6BlackBold),
          title: Text(
            ridePickUpModel.tripEstimateModel == null
                ? "Ride Duration: Loading..."
                : "Ride Duration: ${formatDuration(int.parse(ridePickUpModel.tripEstimateModel!.data!.duration!))} (${ridePickUpModel.tripEstimateModel!.data!.distanceKm}km)",
            style: Styles.h6Black,
          ),
        ),
        Text("Ride", style: Styles.h6BlackBold),
        const SizedBox(height: 10),
        if (ridePickUpModel.tripEstimateModel == null) shimmerItem(useGrid: true, numOfItem: 2),
        if (ridePickUpModel.tripEstimateModel != null)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (Car data in [
                  ridePickUpModel.tripEstimateModel!.data!.okada!,
                  ridePickUpModel.tripEstimateModel!.data!.car!,
                  ridePickUpModel.tripEstimateModel!.data!.bike!,
                  // ridePickUpModel.tripEstimateModel!.data!.pragia!,
                ])
                  GestureDetector(
                    onTap: () => onSelectCar(data, null),
                    onDoubleTap: () => onSelectCar(data, "carDetails"),
                    child: SizedBox(
                      width: 120,
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: selectedCar != null && selectedCar.vehicleTypeId == data.vehicleTypeId
                                  ? BColors.lightGray.withOpacity(.4)
                                  : BColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  data.vehicleTypeId == "2"
                                      ? Images.ride2
                                      : data.vehicleTypeId == "3"
                                          ? Images.ride3
                                          : Images.ride1,
                                  width: 100,
                                  height: 50,
                                  fit: BoxFit.fitHeight,
                                ),
                                const SizedBox(height: 10),
                                Text(getVehicleTypeName(data.vehicleTypeId!), style: Styles.h6BlackBold),
                                const SizedBox(height: 10),
                                Text("${Properties.curreny} ${data.totalFee}", style: Styles.h5BlackBold),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              onPressed: () => onSelectCar(data, "carDetails"),
                              icon: const Icon(Icons.info_outline, color: BColors.primaryColor1, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const Divider(),
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
        const SizedBox(height: 10),
        if (ridePickUpModel.tripEstimateModel != null)
          button(
            onPressed: onSearchDrivers,
            text: "Tap to Request",
            color: BColors.primaryColor,
            context: context,
          ),
      ],
    ),
  );
}
