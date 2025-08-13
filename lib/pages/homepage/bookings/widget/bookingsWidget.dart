import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/emptyBox.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/models/allTripsModel.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/pages/homepage/bookings/widget/bookingAppBar.dart';
import 'package:pickme_mobile/providers/allTripsProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget bookingsWidget({
  @required BuildContext? context,
  @required FocusNode? searchFocusNode,
  @required void Function(String text)? onSearchChange,
  @required void Function()? onBookingFilter,
  required void Function(TripDetailsModel model) onOnGoingTrip,
  required void Function(AllTripsData trip) onCompletedTrip,
  required String searchText,
  required TripDetailsModel? tripDetailsModel,
}) {
  bool hasFirebaseData = tripDetailsModel != null && tripDetailsModel.tripId != null;

  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      return <Widget>[const BookingAppBar()];
    },
    body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            textFormField(
              hintText: "Search bookings...",
              controller: null,
              focusNode: searchFocusNode,
              onTextChange: (String text) => onSearchChange!(text),
              backgroundColor: BColors.assDeep1,
              borderColor: BColors.assDeep1,
              // icon: FeatherIcons.sliders,
              // onIconTap: onBookingFilter,
            ),
            if (searchText == "") ...[
              if (tripDetailsModel != null && tripDetailsModel.tripId != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text("In Route", style: Styles.h5BlackBold),
                    GestureDetector(
                      onTap: () => onOnGoingTrip(tripDetailsModel),
                      child: _layout(
                        icon: tripDetailsModel.vehicleType == "BIKE" ? _LayoutIcon.bIcon1 : _LayoutIcon.bIcon2,
                        title: "Ride Request",
                        subtitle: "From ${tripDetailsModel.pickupLocation}",
                        amount:
                            '${tripDetailsModel.status == "ENDED" ? tripDetailsModel.grandTotal : tripDetailsModel.estimatedTotalAmount}',
                      ),
                    ),
                  ],
                )
            ],
            if (searchText == "")
              StreamBuilder(
                stream: allTripsStream,
                initialData: allTripsModel,
                builder: (context, AsyncSnapshot<AllTripsModel> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.ok! && snapshot.data!.data != null && snapshot.data!.data!.isNotEmpty) {
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
                                    icon: trip.vehicleType == "BIKE" ? _LayoutIcon.bIcon1 : _LayoutIcon.bIcon2,
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
                    } else {
                      return !hasFirebaseData
                          ? emptyBox(context, msg: "No data available", subHeight: 300)
                          : Container();
                    }
                  } else if (snapshot.hasError) {
                    return !hasFirebaseData ? emptyBox(context, msg: "No data available", subHeight: 300) : Container();
                  }
                  return Center(
                    child: loadingDoubleBounce(BColors.primaryColor),
                  );
                },
              ),
            if (searchText != "" && allTripsModel != null) ...[
              const SizedBox(height: 20),
              for (var trip in allTripsModel!.data!)
                if (trip.destinationLocation!.toLowerCase().contains(searchText.toLowerCase()) ||
                    trip.pickupLocation!.toLowerCase().contains(searchText.toLowerCase()))
                  GestureDetector(
                    onTap: () => onCompletedTrip(trip),
                    child: _layout(
                      icon: trip.vehicleType == "BIKE" ? _LayoutIcon.bIcon1 : _LayoutIcon.bIcon2,
                      title: trip.destinationLocation,
                      subtitle: "From ${trip.pickupLocation}",
                      amount: trip.grandTotal.toString(),
                    ),
                  ),
            ],
          ],
        ),
      ),
    ),
  );
}

enum _LayoutIcon { bIcon1, bIcon2 }

Widget _layout({
  @required _LayoutIcon? icon,
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
            icon == _LayoutIcon.bIcon1 ? Images.bookingIcon1 : Images.bookingIcon2,
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
