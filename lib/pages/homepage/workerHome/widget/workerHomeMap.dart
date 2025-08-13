import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/components/toggleBar.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';
import 'package:pickme_mobile/models/allTripsModel.dart';
import 'package:pickme_mobile/models/driverDetailsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/providers/allTripsProvider.dart';
import 'package:pickme_mobile/providers/salesSummaryProvider.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget workerHomeMap({
  required BuildContext context,
  required void Function() onPaySales,
  required void Function() onShowHomeDetails,
  required void Function(int index) onOnOfflineToggle,
  required bool isShowHomeDetails,
  required bool isWorkerToggleLoading,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Visibility(
        visible: isShowHomeDetails,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: button(
                onPressed: onPaySales,
                text: "Pay Sales",
                color: BColors.primaryColor1,
                context: context,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: BColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text("       Today's Earnings", style: Styles.h5Black),
                subtitle: Row(
                  children: [
                    SvgPicture.asset(Images.wallet),
                    const SizedBox(width: 10),
                    StreamBuilder(
                      stream: salesSummaryStream,
                      initialData: salesSummaryModel,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.ok! && snapshot.data!.data != null) {
                            return Text(
                              "${Properties.curreny} ${snapshot.data!.data!.todayEarnings ?? 'N/A'}",
                              style: Styles.h3BlackBold,
                            );
                          }
                        }
                        return Text("Loading...", style: Styles.h3BlackBold);
                      },
                    ),
                  ],
                ),
                trailing: IconButton(
                  onPressed: onShowHomeDetails,
                  icon: const Icon(Icons.arrow_drop_up),
                  color: BColors.black,
                  iconSize: 40,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: BColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width * .21,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 7),
                      title: Text(
                        "Total\nTrips",
                        style: Styles.h6Black,
                        textAlign: TextAlign.end,
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(Images.bookingIcon2),
                          const SizedBox(width: 2),
                          StreamBuilder(
                            stream: allTripsStream,
                            initialData: allTripsModel,
                            builder: (context, AsyncSnapshot<AllTripsModel> snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.ok! && snapshot.data!.data != null) {
                                  return Text(formatNumber("${snapshot.data!.totalTrip}"), style: Styles.h5BlackBold);
                                }
                              }
                              return loadingDoubleBounce(BColors.primaryColor, size: 20);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: BColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width * .25,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                      title: Text(
                        "Time\nOnline",
                        style: Styles.h6Black,
                        textAlign: TextAlign.end,
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.watch_later_outlined,
                            color: BColors.black,
                            size: 20,
                          ),
                          const SizedBox(width: 2),
                          FutureBuilder(
                            future: getHive("timeOnline"),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                String time = snapshot.data.toString();
                                if (time == "") {
                                  return Text("N/A", style: Styles.h5BlackBold);
                                }
                                Duration difference = DateTime.now().difference(DateTime.parse(time));
                                String reading = formatDuration(
                                  difference.inSeconds,
                                  shorten: true,
                                  displayFullDuration: false,
                                );
                                return SizedBox(
                                  width: (MediaQuery.of(context).size.width * .25) - 32,
                                  child: Text(
                                    reading,
                                    style: Styles.h6BlackBold,
                                    textAlign: TextAlign.right,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Text("N/A", style: Styles.h5BlackBold);
                              }
                              return loadingDoubleBounce(BColors.primaryColor, size: 20);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: BColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width * .25,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                      title: Text(
                        "Total\nDistance",
                        style: Styles.h6Black,
                        textAlign: TextAlign.end,
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.route_outlined,
                            color: BColors.black,
                          ),
                          const SizedBox(width: 2),
                          StreamBuilder(
                            stream: allTripsStream,
                            initialData: allTripsModel,
                            builder: (context, AsyncSnapshot<AllTripsModel> snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.ok! && snapshot.data!.data != null) {
                                  return Text(
                                    "${formatNumber("${snapshot.data!.totalDistance}")} (km)",
                                    style: Styles.h6BlackBold,
                                  );
                                }
                              }
                              return loadingDoubleBounce(BColors.primaryColor, size: 20);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: BColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width * .21,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 7),
                      title: Text(
                        "My\nRatings",
                        style: Styles.h6Black,
                        textAlign: TextAlign.end,
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.star_border_sharp,
                            color: BColors.black,
                          ),
                          const SizedBox(width: 2),
                          StreamBuilder(
                            stream: workersInfoStream,
                            initialData: workersInfoModel,
                            builder: (context, AsyncSnapshot<WorkersInfoModel> snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.ok! && snapshot.data!.data != null) {
                                  return Text("${snapshot.data!.data!.rating}", style: Styles.h5BlackBold);
                                }
                              }
                              return loadingDoubleBounce(BColors.primaryColor, size: 20);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      if (checkWorkerAccountStatus()) ...[
        if (isWorkerToggleLoading) loadingDoubleBounce(BColors.primaryColor),
        if (!isWorkerToggleLoading)
          StreamBuilder(
            stream: FirebaseService().getDriverLocationDetails(userModel!.data!.user!.userid!),
            builder: (context, AsyncSnapshot<DriverDetailsModel?> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null) {
                  return ToggleBar(
                    labels: const ['Offline', 'Online'],
                    selectedTabColor: BColors.white,
                    selectedTextColor: snapshot.data!.status == "INACTIVE" ? BColors.orange : BColors.green1,
                    labelTextStyle: Styles.h5BlackBold,
                    backgroundColor: snapshot.data!.status == "INACTIVE" ? BColors.orange : BColors.green1,
                    onSelectionUpdated: (index) => snapshot.data != null ? onOnOfflineToggle(index) : null,
                    selectedIndex: snapshot.data == null || snapshot.data!.status == "INACTIVE" ? 0 : 1,
                  );
                } else {
                  return ToggleBar(
                    labels: const ['Offline', 'Online'],
                    selectedTabColor: BColors.white,
                    selectedTextColor: BColors.green1,
                    labelTextStyle: Styles.h5BlackBold,
                    backgroundColor: BColors.green1,
                    onSelectionUpdated: (index) => onOnOfflineToggle(index),
                    selectedIndex: 0,
                  );
                }
              } else if (snapshot.error != null) {
                return ToggleBar(
                  labels: const ['Offline', 'Online'],
                  selectedTabColor: BColors.white,
                  selectedTextColor: BColors.green1,
                  labelTextStyle: Styles.h5BlackBold,
                  backgroundColor: BColors.green1,
                  onSelectionUpdated: (index) => onOnOfflineToggle(index),
                  selectedIndex: 0,
                );
              }
              return Center(child: loadingDoubleBounce(BColors.primaryColor));
            },
          ),
      ] else
        Container(
          padding: const EdgeInsets.all(10),
          color: BColors.white,
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            "Account Status: ${workersInfoModel?.data?.status ?? "N/A"}",
            style: Styles.h4RedBold,
            textAlign: TextAlign.center,
          ),
        ),
      if (!isShowHomeDetails)
        Align(
          alignment: Alignment.topRight,
          child: _floatingLayout(
            onTap: onShowHomeDetails,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: BColors.black,
              size: 30,
            ),
          ),
        ),
    ],
  );
}

Widget _floatingLayout({
  required void Function() onTap,
  required Widget icon,
  Color? backgroundColor,
}) {
  return Container(
    margin: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: backgroundColor ?? BColors.white,
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
      onPressed: onTap,
      icon: icon,
    ),
  );
}
