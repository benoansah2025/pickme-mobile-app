import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget vendorGPSWidget({
  required BuildContext context,
  required Key key,
  required TextEditingController gpsAddressController,
  required TextEditingController longitudeController,
  required TextEditingController latitudeController,
  required FocusNode gpsAddressFocusNode,
  required FocusNode longitudeFocusNode,
  required FocusNode latitudeFocusNode,
  required ScrollController scrollController,
  required void Function() onLocation,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      controller: scrollController,
      child: Form(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text("GPS Details", style: Styles.h3BlackBold),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: const EdgeInsets.all(0),
              title: Text("Location (Optional)", style: Styles.h6Black),
              trailing: IconButton(
                onPressed: onLocation,
                icon: Icon(
                  Icons.gps_fixed,
                  color: BColors.primaryColor1,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .45,
                  child: textFormField(
                      hintText: "Latitude",
                      controller: latitudeController,
                      focusNode: latitudeFocusNode,
                      validate: false),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .45,
                  child: textFormField(
                      hintText: "Longitude",
                      controller: longitudeController,
                      focusNode: longitudeFocusNode,
                      validate: false),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text("GPS Address (Optional)", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter name",
              controller: gpsAddressController,
              focusNode: gpsAddressFocusNode,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}
