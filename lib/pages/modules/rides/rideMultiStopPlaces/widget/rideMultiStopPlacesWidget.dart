import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/measureSize.dart';
import 'package:pickme_mobile/components/placeIconData.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/config/mapFunction.dart';
import 'package:pickme_mobile/models/placePredictionModel.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget rideMultiStopPlacesWidget({
  required BuildContext context,
  required void Function(int index) onRemoveStopOver,
  required void Function(int index) onClearStopText,
  required void Function(RidePlaceFields type, int index) onMapPickerStop,
  required void Function(Size size) onTopWidgetSize,
  required void Function(String text, RidePlaceFields type, int? index) onPlaceTyping,
  required Size topWidgetSize,
  required List<Map<String, dynamic>> multiPlaceList,
  required TextEditingController pickupController,
  required FocusNode pickupFocusNode,
  required List<PlacePredictionModel> placePredictions,
  required void Function(PlacePredictionModel prediction) onPlaceSelected,
  required Function() onClearPickupText,
  required Map<String, dynamic> pickUpMap,
}) {
  return Stack(
    children: [
      MeasureSize(
        onChange: (Size size) => onTopWidgetSize(size),
        child: Container(
          decoration: const BoxDecoration(
            color: BColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  leading: Container(
                    padding: const EdgeInsets.all(2),
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
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("PICKUP", style: Styles.h7Black),
                      if (pickupFocusNode.hasFocus && pickupController.text.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      ],
                    ],
                  ),
                  subtitle: 
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textFormField(
                        controller: pickupController,
                        hintText: 'Enter pickup location',
                        focusNode: pickupFocusNode,
                        removeBorder: true,
                        onTextChange: (String text) => onPlaceTyping(
                          text,
                          RidePlaceFields.pickUp,
                          null,
                        ),
                        icon: pickupFocusNode.hasFocus ? Icons.close : null,
                        onIconTap: onClearPickupText,
                        inputPadding: EdgeInsets.zero,
                      ),
                      if (!pickupFocusNode.hasFocus &&
                          pickupController.text.isNotEmpty &&
                          pickUpMap["address"] != null) ...[
                        // const SizedBox(height: 5),
                        !isCodePlaceName(pickupController.text)
                            ? pickUpMap["address"] != ""
                                ? Text(pickUpMap["address"], style: Styles.h7PrimaryBold)
                                : const SizedBox()
                            : Text("Near by: ${pickUpMap["address"]}", style: Styles.h7PrimaryBold),
                      ],
                    ],
                  ),
                  trailing: !pickupFocusNode.hasFocus
                      ? button(
                          onPressed: onClearPickupText,
                          text: "Change",
                          color: BColors.primaryColor,
                          context: context,
                          useWidth: false,
                          textStyle: Styles.h6Black,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          height: 32,
                          icon: const Icon(
                            Icons.watch_later_outlined,
                            color: BColors.white,
                          ),
                        )
                      : null,
                ),
                const Divider(thickness: .4, indent: 50),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("STOP OVERS", style: Styles.h7Black),
                      // if (whereToFocusNode.hasFocus &&
                      //     whereToController.text.isNotEmpty) ...[
                      //   const SizedBox(width: 10),
                      //   const SizedBox(
                      //     width: 10,
                      //     height: 10,
                      //     child: CircularProgressIndicator(strokeWidth: 3),
                      //   ),
                      // ],
                    ],
                  ),
                ),
                for (int x = 0; x < multiPlaceList.length; ++x)
                  ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    leading: const Icon(
                      Icons.square,
                      size: 15,
                      color: BColors.black,
                    ),
                    title: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      height: 30,
                      child: textFormField(
                        controller: multiPlaceList[x]["place"],
                        hintText: 'Add stop over',
                        focusNode: multiPlaceList[x]["focus"],
                        removeBorder: true,
                        onTextChange: (String text) => onPlaceTyping(
                          text,
                          RidePlaceFields.stopOvers,
                          x,
                        ),
                        inputPadding: EdgeInsets.zero,
                        icon: !(multiPlaceList[x]["focus"] as FocusNode).hasFocus && multiPlaceList[x]["showClose"]
                            ? Icons.delete
                            : null,
                        iconColor: BColors.red,
                        iconPadding: EdgeInsets.zero,
                        onIconTap: () => onRemoveStopOver(x),
                      ),
                    ),
                    subtitle: const SizedBox(
                      height: 5,
                      child: Divider(thickness: .4),
                    ),
                    trailing: (multiPlaceList[x]["focus"] as FocusNode).hasFocus
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => onClearStopText(x),
                                icon: const Icon(Icons.close),
                              ),
                              button(
                                onPressed: () => onMapPickerStop(RidePlaceFields.stopOvers, x),
                                text: "Map",
                                color: BColors.primaryColor1,
                                context: context,
                                useWidth: false,
                                textStyle: Styles.h6Black,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                height: 32,
                              ),
                            ],
                          )
                        : null,
                  ),
              ],
            ),
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.only(top: topWidgetSize.height + 10),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - (topWidgetSize.height + 10),
        ),
        child: placePredictions.isNotEmpty
            ? ListView.builder(
                itemCount: placePredictions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      getPlaceIconData(placePredictions[index].types!, placePredictions[index].name ?? ""),
                      color: BColors.black,
                    ),
                    title: Text(placePredictions[index].name ?? "N/A", style: Styles.h6BlackBold),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: placePredictions[index].vicinity ?? "N/A", style: Styles.h6Black),
                            ],
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                    trailing: Text("${placePredictions[index].distanceInKm!} Km", style: Styles.h6Black),
                    onTap: () => onPlaceSelected(placePredictions[index]),
                  );
                },
              )
            : Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const Icon(FeatherIcons.clock, size: 60),
                        const SizedBox(height: 20),
                        Text(
                          "Add multiple stops during your trip",
                          style: Styles.h5BlackBold,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Your total trip time along with the stopover waiting time will be calculated as per the standard time pricing.",
                          style: Styles.h5Black,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    ],
  );
}
