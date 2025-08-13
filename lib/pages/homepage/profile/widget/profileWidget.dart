import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/models/driverDetailsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/pages/homepage/profile/widget/profileAppBar.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget profileWidget({
  required BuildContext context,
  required void Function() onEditProfile,
  required void Function() onContactUs,
  required void Function() onWallet,
  required void Function() onEmergency,
  required void Function() onVendors,
  required void Function() onMyBookings,
  required void Function() onBusinessProfile,
  required void Function() onMyCart,
  required void Function() onNotifications,
  required void Function() onFavoriteSp,
  required void Function() onBecomeWorker,
  required void Function() onInvest,
  required void Function() onSettings,
  required bool? isWorkerMode,
  required void Function(bool value, String rideStatus, String? accountStatus) onWorkerMode,
}) {
  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      return <Widget>[ProfileAppBar(onEdit: onEditProfile)];
    },
    body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text("Wallet Balance", style: Styles.h4BlackBold),
            //     StreamBuilder(
            //       stream: walletBalanceStream,
            //       initialData: walletBalanceModel,
            //       builder: (context, AsyncSnapshot<WalletBalanceModel> snapshot) {
            //         if (snapshot.hasData) {
            //           return Text(
            //             "${Properties.curreny} ${snapshot.data!.data != null ? snapshot.data!.data!.balance : '0.00'}",
            //             style: Styles.h4Primary,
            //           );
            //         } else if (snapshot.hasError) {
            //           return Text("${Properties.curreny} 0.00", style: Styles.h4Primary);
            //         }
            //         return loadingDoubleBounce(BColors.white);
            //       },
            //     ),
            //   ],
            // ),
            // const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _layout1(
                  context: context,
                  image: Images.contactUs,
                  name: 'Contact Us',
                  onTap: onContactUs,
                ),
                _layout1(
                  context: context,
                  image: Images.addMoney,
                  name: 'Wallet',
                  onTap: onWallet,
                ),
                _layout1(
                  context: context,
                  image: Images.emergency,
                  name: 'Emergency',
                  onTap: onEmergency,
                ),
                _layout1(
                  context: context,
                  image: Images.vendors2,
                  name: 'Vendors',
                  onTap: onVendors,
                ),
              ],
            ),
            const SizedBox(height: 30),
            StreamBuilder(
              stream: workersInfoStream,
              initialData: workersInfoModel,
              builder: (BuildContext context, AsyncSnapshot<WorkersInfoModel> workerInfoSnapshot) {
                if (workerInfoSnapshot.hasData) {
                  if (workerInfoSnapshot.data!.ok! && workerInfoSnapshot.data!.data != null) {
                    return Container(
                      color: BColors.background,
                      child: StreamBuilder(
                        stream: FirebaseService().getDriverLocationDetails(userModel!.data!.user!.userid!),
                        builder: (context, AsyncSnapshot<DriverDetailsModel?> driverDetailsSnapshot) {
                          if (driverDetailsSnapshot.hasData) {
                            if (driverDetailsSnapshot.data != null) {
                              return ListTile(
                                title: Text(
                                  "${Properties.titleShort.toUpperCase()} Worker Mode",
                                  style: Styles.h4BlackBold,
                                ),
                                subtitle: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Switch between the user and worker dashboards",
                                      style: Styles.h7Black,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Account Status: ${workerInfoSnapshot.data!.data!.status ?? "N/A"}",
                                      style: workerInfoSnapshot.data!.data!.status == "APPROVED"
                                          ? Styles.h5GreenBold
                                          : Styles.h4RedBold,
                                    ),
                                  ],
                                ),
                                trailing: isWorkerMode != null
                                    ? Switch(
                                        value: isWorkerMode,
                                        onChanged: (bool value) => onWorkerMode(
                                          value,
                                          driverDetailsSnapshot.data!.status!,
                                          workerInfoSnapshot.data!.data!.status,
                                        ),
                                        activeColor: BColors.primaryColor1,
                                      )
                                    : SizedBox(
                                        width: 25,
                                        child: loadingDoubleBounce(BColors.primaryColor1, size: 20),
                                      ),
                              );
                            }
                          }
                          return ListTile(
                            title: Text("Loading...", style: Styles.h4BlackBold),
                            trailing: SizedBox(
                              width: 30,
                              child: loadingDoubleBounce(BColors.primaryColor, size: 20),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }
                return GestureDetector(
                  onTap: onBecomeWorker,
                  child: Card(
                    color: BColors.white,
                    elevation: 5,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 120),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: BColors.primaryColor2.withOpacity(.2),
                        borderRadius: BorderRadius.circular(10),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: BColors.black.withOpacity(.3),
                        //     spreadRadius: .1,
                        //     blurRadius: 20,
                        //     offset: const Offset(0, 3),
                        //   ),
                        // ],
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Opacity(
                              opacity: .8,
                              child: Image.asset(Images.worker),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "BECOME A ${Properties.titleShort.toUpperCase()} WORKER",
                                style: Styles.h4BlackBold,
                              ),
                              const SizedBox(height: 7),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .6,
                                child: Text(
                                  "Gain money as a PICKME Rider,\nDriver, Delivery guy or\nPersonal shopper.",
                                  style: Styles.h6BlackBold,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text("General", style: Styles.h4BlackBold),
            ListTile(
              onTap: onMyBookings,
              // ignore: deprecated_member_use
              leading: SvgPicture.asset(Images.bookings, color: BColors.red),
              title: Text("My Bookings", style: Styles.h5BlackBold),
              // dense: true,
              // visualDensity: const VisualDensity(vertical: -3),
            ),
            ListTile(
              onTap: onBusinessProfile,
              leading: const Icon(
                Icons.account_circle_sharp,
                color: BColors.primaryColor,
              ),
              title: Text("Business Profile", style: Styles.h5BlackBold),
            ),
            // ListTile(
            //   onTap: onMyCart,
            //   leading: const Icon(
            //     Icons.shopping_cart,
            //     color: BColors.primaryColor1,
            //   ),
            //   title: Text("My Cart", style: Styles.h5BlackBold),
            // ),
            ListTile(
              onTap: onNotifications,
              leading: const Icon(Icons.notifications, color: BColors.red),
              title: Text("Notifications", style: Styles.h5BlackBold),
            ),
            ListTile(
              onTap: onFavoriteSp,
              leading: const Icon(Icons.favorite, color: BColors.green),
              title: Text(
                "Favorite Service Providers",
                style: Styles.h5BlackBold,
              ),
            ),
            ListTile(
              onTap: onInvest,
              leading: const Icon(
                FeatherIcons.info,
                color: BColors.green,
              ),
              title: Text("Invest In PickMe", style: Styles.h5BlackBold),
            ),
            ListTile(
              onTap: onSettings,
              leading: const Icon(FeatherIcons.settings),
              title: Text("Settings", style: Styles.h5BlackBold),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}

Widget _layout1({
  @required BuildContext? context,
  @required String? image,
  @required String? name,
  @required void Function()? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: MediaQuery.of(context!).size.width * .22,
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: BColors.assDeep1,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: BColors.black.withOpacity(.05),
            spreadRadius: .1,
            blurRadius: 20,
            // offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(image!),
            const SizedBox(height: 10),
            Text(name!, style: Styles.h7Black, textAlign: TextAlign.center)
          ],
        ),
      ),
    ),
  );
}
