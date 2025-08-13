import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';
import 'package:pickme_mobile/models/driverDetailsModel.dart';
import 'package:pickme_mobile/models/driverRequestModel.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget workerRideAcceptRequestMap({
  required BuildContext context,
  required void Function() onCall,
  required void Function() onChat,
  required void Function() onArrivedPickUpPoint,
  required void Function() onStartTrip,
  required void Function() onEndTrip,
  required WorkerMapNextAction? mapNextAction,
  required DriverRequestModel requestModel,
  required List<StopStut>? stops,
  required int? nextStopIndex,
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
        if (mapNextAction != WorkerMapNextAction.startTrip) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mapNextAction == WorkerMapNextAction.startTrip
                    ? "On Trip"
                    : mapNextAction == WorkerMapNextAction.arrived
                        ? "You’ve arrived at pickup point"
                        : "Request Accepted",
                style: Styles.h5BlackBold,
              ),
              Text(
                "${Properties.curreny} ${requestModel.currentTripDetails!.estimatedTotalAmount}",
                style: Styles.h5BlackBold,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: circular(
              child: cachedImage(
                context: context,
                image: "${requestModel.currentRideDetails!.riderPicture}",
                height: 50,
                width: 50,
                placeholder: Images.defaultProfilePicOffline,
              ),
              size: 50,
            ),
            title: Text(
              "${requestModel.currentRideDetails!.riderName}",
              style: Styles.h4BlackBold,
            ),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: BColors.yellow1),
                const SizedBox(width: 10),
                FutureBuilder(
                  future: getHive("riderRating"),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data, style: Styles.h6BlackBold);
                    } else if (snapshot.hasError) {
                      return Text("N/A", style: Styles.h6BlackBold);
                    }

                    return loadingDoubleBounce(BColors.primaryColor, size: 20);
                  },
                ),
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
        if (mapNextAction == WorkerMapNextAction.startTrip) ...[
          if (stops != null && stops.isNotEmpty && nextStopIndex != null && nextStopIndex < stops.length) ...[
            Text("Next Stop:", style: Styles.h6Black),
            const SizedBox(height: 10),
            Text("${stops[nextStopIndex].name}", style: Styles.h5BlackBold),
            const SizedBox(height: 20),
          ] else ...[
            Text("Final Destination:", style: Styles.h6Black),
            const SizedBox(height: 10),
            Text("${requestModel.currentRideDetails!.destinationInText}", style: Styles.h5BlackBold),
            const SizedBox(height: 20),
          ],
        ],
        button(
          onPressed: mapNextAction == WorkerMapNextAction.startTrip
              ? onEndTrip
              : mapNextAction == WorkerMapNextAction.arrived
                  ? onStartTrip
                  : onArrivedPickUpPoint,
          text: mapNextAction == WorkerMapNextAction.startTrip
              ? "End Trip"
              : mapNextAction == WorkerMapNextAction.arrived
                  ? "Start Trip"
                  : "Arrived at Pickup point",
          color: BColors.primaryColor,
          context: context,
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
