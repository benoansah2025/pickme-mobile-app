import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/placemarkModel.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget addNewAddressMap({
  required BuildContext context,
  required void Function() onCurrentLocation,
  required TextEditingController houseNoController,
  required TextEditingController landmarkController,
  required TextEditingController phoneController,
  required void Function() onChangeLocation,
  required LatLng currentLocation,
  required Map<dynamic, dynamic> deliveryAddresses,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Align(
        alignment: Alignment.topRight,
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BColors.white,
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
            onPressed: onCurrentLocation,
            icon: const Icon(
              Icons.location_searching_rounded,
              color: BColors.black,
            ),
          ),
        ),
      ),
      SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: BColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text("Add new Addresses", style: Styles.h6Black),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(3),
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
                title: Text("My current location", style: Styles.h4BlackBold),
                subtitle: deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["name"] == ""
                    ? FutureBuilder(
                        future: getLocationDetails(
                          lat: currentLocation.latitude,
                          log: currentLocation.longitude,
                        ),
                        builder: (BuildContext context, AsyncSnapshot<PlacemarkModel?> snapshot) {
                          if (snapshot.hasData) {
                            PlacemarkModel? placemarkModel = snapshot.data;

                            return placemarkModel == null
                                ? Text(
                                    "Unable to get current location",
                                    style: Styles.h6Black,
                                  )
                                : Text(
                                    "${placemarkModel.thoroughfare != '' ? placemarkModel.thoroughfare : placemarkModel.subAdministrativeArea}",
                                    style: Styles.h6Black,
                                  );
                          }
                          return Text(
                            "Loading...",
                            style: Styles.h6Black,
                          );
                        },
                      )
                    : Text(
                        deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["name"],
                        style: Styles.h6Black,
                      ),
                trailing: button(
                  onPressed: onChangeLocation,
                  text: "Change",
                  color: BColors.primaryColor,
                  context: context,
                  useWidth: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  textStyle: Styles.h5Black,
                  icon: const Icon(Icons.refresh, color: BColors.white),
                  height: 40,
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              textFormField(
                hintText: "Building/House No",
                controller: null,
                focusNode: null,
                removeBorder: true,
                hintTextStyle: Styles.h4Ashdeep,
              ),
              const Divider(),
              textFormField(
                hintText: "Landmark eg: Hospital, Church etc.",
                controller: null,
                focusNode: null,
                removeBorder: true,
                hintTextStyle: Styles.h4Ashdeep,
              ),
              const Divider(),
              textFormField(
                hintText: "Phone number",
                controller: null,
                focusNode: null,
                removeBorder: true,
                hintTextStyle: Styles.h4Ashdeep,
                inputType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
