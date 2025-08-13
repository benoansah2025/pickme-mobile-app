import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/customBackButton.dart';
import 'package:pickme_mobile/pages/modules/deliveries/personalShopper/deliveryAddress/widget/addNewAddressMap.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'rideMapBottomWidget.dart';

late Size mapSize;

Widget rideMapWidget({
  required BuildContext context,
  required LatLng currentLocation,
  required Set<Marker> markers,
  required void Function(GoogleMapController controller) onMapCreated,
  required double zoom,
  required void Function() onBack,
  required void Function() onCurrentLocation,
  required void Function(QuickPlace place) onQuickPlace,
  required bool showSearchPlace,
  required Set<Polyline> polylines,
  required RideMapNextAction rideNextAction,
  required void Function() newAddressSave,
  required void Function(DeliveryAccessLocation value) onChangeDeliveryLocation,
  required TextEditingController newAddressHouseNoController,
  required TextEditingController newAddressLandmarkController,
  required TextEditingController newAddressPhoneController,
  required Map<dynamic, dynamic> deliveryAddresses,
  required void Function(CameraPosition position) onCameraMove,
  required bool showBackButton,
}) {
  return Stack(
    children: [
      LayoutBuilder(builder: (context, constraints) {
        mapSize = Size(constraints.maxWidth, constraints.maxHeight);

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentLocation,
            zoom: zoom,
          ),
          zoomControlsEnabled: false,
          myLocationButtonEnabled: true,
          myLocationEnabled: false,
          markers: markers,
          polylines: polylines,
          onMapCreated: (controller) => onMapCreated(controller),
          onCameraMove: (position) => onCameraMove(position),
        );
      }),
      if (showBackButton)
      SafeArea(child: customBackButton(onBack)),
      if (rideNextAction == RideMapNextAction.addAddress)
        Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: button(
                onPressed: newAddressSave,
                text: "Save",
                color: BColors.primaryColor1,
                context: context,
                useWidth: false,
                height: 40,
              ),
            ),
          ),
        ),
      if (showSearchPlace)
        Align(
          alignment: Alignment.bottomCenter,
          child: rideNextAction == RideMapNextAction.addAddress
              ? addNewAddressMap(
                  onCurrentLocation: onCurrentLocation,
                  context: context,
                  houseNoController: newAddressHouseNoController,
                  landmarkController: newAddressLandmarkController,
                  phoneController: newAddressPhoneController,
                  onChangeLocation: () => onChangeDeliveryLocation(DeliveryAccessLocation.pickUpLocation),
                  currentLocation: currentLocation,
                  deliveryAddresses: deliveryAddresses,
                )
              : rideMapBottomWidget(
                  onCurrentLocation: onCurrentLocation,
                  context: context,
                  onQuickPlace: (QuickPlace place) => onQuickPlace(place),
                ),
        )
    ],
  );
}
