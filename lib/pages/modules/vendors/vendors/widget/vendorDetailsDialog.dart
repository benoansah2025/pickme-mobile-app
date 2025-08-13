import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/ratingStar.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/vendorsModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget vendorDetailsDialog({
  required Data data,
  required BuildContext context,
}) {
  return ClipRRect(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: cachedImage(
                  context: context,
                  image: data.picture,
                  height: 100,
                  width: 100,
                  placeholder: Images.imageLoadingError,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(child: Text(sentenceCase(data.vendorName!), style: Styles.h4BlackBold)),
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(data.serviceName!, style: Styles.h6BlackBold),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ratingStar(
                    rate: data.rating!.toDouble(),
                    function: null,
                    size: 17,
                    itemCount: 5,
                    itemPadding: 1,
                    unratedColor: BColors.assDeep,
                  ),
                  const SizedBox(width: 5),
                  Text("${data.rating!.toDouble()}", style: Styles.h6BlackBold),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text("Contact", style: Styles.h5BlackBold),
            ),
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              title: Text("Phone:", style: Styles.h6Black),
              subtitle: Text(data.phone ?? "N/A", style: Styles.h5BlackBold),
              trailing: CircleAvatar(
                backgroundColor: BColors.primaryColor1,
                radius: 20,
                child: IconButton(
                  onPressed: () => callLauncher("tel: ${data.phone}"),
                  icon: const Icon(Icons.call),
                  color: BColors.white,
                  iconSize: 20,
                ),
              ),
            ),
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              title: Text("Email:", style: Styles.h6Black),
              subtitle: Text(data.email ?? "N/A", style: Styles.h5BlackBold),
              trailing: CircleAvatar(
                backgroundColor: BColors.primaryColor1,
                radius: 20,
                child: IconButton(
                  onPressed: () => callLauncher("mailto: ${data.email}"),
                  icon: const Icon(Icons.mail),
                  color: BColors.white,
                  iconSize: 20,
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text("Location", style: Styles.h5BlackBold),
            ),
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              leading: Text("Street Name:", style: Styles.h6Black),
              trailing: Text(data.streetname ?? "N/A", style: Styles.h5BlackBold),
            ),
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              leading: Text("Town:", style: Styles.h6Black),
              trailing: Text(data.town ?? "N/A", style: Styles.h5BlackBold),
            ),
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              leading: Text("District:", style: Styles.h6Black),
              trailing: Text(data.district ?? "N/A", style: Styles.h5BlackBold),
            ),
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              leading: Text("Region:", style: Styles.h6Black),
              trailing: Text(data.region ?? "N/A", style: Styles.h5BlackBold),
            ),
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              leading: Text("GPS Address:", style: Styles.h6Black),
              trailing: Text(data.gpsaddress ?? "N/A", style: Styles.h5BlackBold),
            ),
            // const SizedBox(height: 10),
            // button(
            //   onPressed: () {
            //     // Open Google Maps with directions
            //     String googleUrl =
            //         'https://www.google.com/maps/dir/?api=1&origin=${currentPosition!.latitude},${_currentPosition!.longitude}&destination=${_destinationLocation!.latitude},${_destinationLocation!.longitude}';
            //     callLauncher(googleUrl);
            //   },
            //   text: "View location on map",
            //   color: BColors.primaryColor,
            //   context: context,
            // ),
          ],
        ),
      ),
    ),
  );
}
