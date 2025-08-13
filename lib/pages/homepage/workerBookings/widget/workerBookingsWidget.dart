import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/emptyBox.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/models/allTripsModel.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/providers/allTripsProvider.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget workerBookingsWidget({
  @required BuildContext? context,
  required void Function(AllTripsData trip) onCompletedTrip,
  required void Function(TripDetailsModel model) onOnGoingTrip,
  required TripDetailsModel? tripDetailsModel,
}) {
  bool hasFirebaseData = tripDetailsModel != null && tripDetailsModel.tripId != null;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: ListView(
      children: [
        const SizedBox(height: 20),
        if (tripDetailsModel != null && tripDetailsModel.tripId != null) ...[
          Container(
            color: BColors.primaryColor.withOpacity(.1),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text("In Route", style: Styles.h5BlackBold),
                GestureDetector(
                  onTap: () => onOnGoingTrip(tripDetailsModel),
                  child: _layout(
                    icon: tripDetailsModel.vehicleType == "BIKE"
                        ? OngoingRequestLayoutIconEnum.bIcon1
                        : OngoingRequestLayoutIconEnum.bIcon2,
                    title: "Ride Request",
                    subtitle: "From ${tripDetailsModel.pickupLocation}",
                    amount:
                        '${tripDetailsModel.status == "ENDED" ? tripDetailsModel.grandTotal : tripDetailsModel.estimatedTotalAmount}',
                  ),
                ),
              ],
            ),
          ),
        ],
        StreamBuilder(
          stream: allTripsStream,
          initialData: allTripsModel,
          builder: (context, AsyncSnapshot<AllTripsModel> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.ok! && snapshot.data!.data != null) {
                Map<String, List<AllTripsData>> groupedTrips = snapshot.data!.groupTripsByMonthYear();

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: groupedTrips.length,
                  itemBuilder: (context, index) {
                    // Get the month-year key and the list of trips for this month-year
                    String monthYear = groupedTrips.keys.elementAt(index);
                    List<AllTripsData> trips = groupedTrips[monthYear]!;
                    return ExpansionTile(
                      initiallyExpanded: index == 0,
                      iconColor: BColors.black,
                      title: Text(monthYear, style: Styles.h5BlackBold),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide.none,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide.none,
                      ),
                      children: [
                        for (var trip in trips) ...[
                          GestureDetector(
                            onTap: () => onCompletedTrip(trip),
                            child: _layout(
                              icon: trip.vehicleType == "BIKE"
                                  ? OngoingRequestLayoutIconEnum.bIcon1
                                  : OngoingRequestLayoutIconEnum.bIcon2,
                              title: trip.destinationLocation,
                              subtitle: "From ${trip.pickupLocation}",
                              amount: trip.grandTotal.toString(),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                );
              }
            } else if (snapshot.hasError) {
              return !hasFirebaseData ? emptyBox(context, msg: "No data available") : Container();
            }
            return Center(
              child: loadingDoubleBounce(BColors.primaryColor),
            );
          },
        ),
      ],
    ),
  );
}

Widget _layout({
  @required OngoingRequestLayoutIconEnum? icon,
  @required String? title,
  @required String? subtitle,
  @required String? amount,
}) {
  return Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        visualDensity: const VisualDensity(vertical: -3),
        leading: CircleAvatar(
          radius: 15,
          backgroundColor: BColors.assDeep1,
          child: Image.asset(
            icon == OngoingRequestLayoutIconEnum.bIcon1 ? Images.bookingIcon1 : Images.bookingIcon2,
          ),
        ),
        title: Text(title!, style: Styles.h4BlackBold),
        subtitle: Text(subtitle!, style: Styles.h6Black),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${Properties.curreny}$amount",
              style: Styles.h4BlackBold,
            ),
          ],
        ),
      ),
      const Divider(),
    ],
  );
}
