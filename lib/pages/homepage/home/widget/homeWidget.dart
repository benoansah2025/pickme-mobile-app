import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pickme_mobile/pages/modules/vendors/vendors/vendors.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'homeAppbar.dart';

Widget homeWidget({
  @required BuildContext? context,
  required void Function(String? tap) onSos,
  @required void Function()? onNotification,
  @required void Function()? onRide,
  @required void Function()? onDelivery,
  required void Function() onProfile,
  @required Position? currentLocation,
}) {
  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      return <Widget>[
        HomeAppbar(
          onNotification: onNotification,
          onSos: (String? tap) => onSos(tap),
          currentLocation: currentLocation,
          onProfile: onProfile,
        ),
      ];
    },
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Vendors(showAd: true),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 10),
                _layout1(
                  context: context,
                  onTap: onRide!,
                  image: Images.homeRideCard,
                ),
                const SizedBox(width: 10),
                _layout1(
                  context: context,
                  title: "20% Discount from anywhere within Accra to National Theater",
                  subtitle: "Book your ride now ➜",
                  image: Images.needRide,
                  backgroundColor: BColors.primaryColor1,
                  onTap: onRide,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _layoutServices(
            title: "ORDER A RIDE",
            subtitle: "Book affordable ${Properties.titleShort.toUpperCase()} rides and enjoy maximum comfort",
            image: null,
            color: BColors.primaryColor,
            onTap: onRide,
          ),
          const SizedBox(height: 20),
          _layoutServices(
            title: "DELIVERIES",
            subtitle: "Order anything and have it delivered at your doorstep",
            image: Images.bike,
            color: BColors.primaryColor1,
            onTap: onDelivery,
          ),
        ],
      ),
    ),
  );
}

Widget _layoutServices({
  @required String? title,
  @required String? subtitle,
  @required String? image,
  @required Color? color,
  @required void Function()? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: BColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BColors.black.withOpacity(.2),
            spreadRadius: .1,
            blurRadius: 20,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(title!, style: Styles.h3BlackBold),
            trailing: image == null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(Images.ride2, width: 40),
                      Image.asset(Images.ride1, width: 40),
                    ],
                  )
                : Image.asset(image),
          ),
          const SizedBox(height: 10),
          Text(subtitle!, style: Styles.h6Black),
          Align(
            alignment: Alignment.bottomRight,
            child: CircleAvatar(
              backgroundColor: color,
              radius: 12,
              child: const Icon(
                Icons.arrow_forward_ios,
                color: BColors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _layout1({
  @required BuildContext? context,
  String? title,
  String? subtitle,
  @required String? image,
  Color? backgroundColor,
  @required void Function()? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: title == null
        ? Image.asset(
            image!,
            width: MediaQuery.of(context!).size.width * .85,
            height: 140,
            fit: BoxFit.fill,
          )
        : Container(
            width: MediaQuery.of(context!).size.width * .85,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            constraints: const BoxConstraints(minHeight: 140),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: BColors.black.withOpacity(.2),
                  spreadRadius: .1,
                  blurRadius: 20,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width * .7) - 100,
                      child: Text(
                        title,
                        style: Styles.h5WhiteBold,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Opacity(
                      opacity: .2,
                      child: Image.asset(image!, width: 100),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(subtitle!, style: Styles.h6WhiteBold),
              ],
            ),
          ),
  );
}
