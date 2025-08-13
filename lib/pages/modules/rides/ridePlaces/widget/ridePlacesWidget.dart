import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/measureSize.dart';
import 'package:pickme_mobile/components/placeIconData.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/config/mapFunction.dart';
import 'package:pickme_mobile/models/placePredictionModel.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/widget/rideMapBottomWidget.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget ridePlacesWidget({
  required BuildContext context,
  required void Function() onAddMultiStopsPlaces,
  required void Function(String name) onRecentPlace,
  required void Function(Size size) onTopWidgetSize,
  required void Function(QuickPlace place) onQuickPlace,
  required void Function(QuickPlace place) onSecondaryQuickTap,
  required void Function(String text, RidePlaceFields type) onPlaceTyping,
  required Size topWidgetSize,
  required TextEditingController whereToController,
  required FocusNode whereToFocusNode,
  required TextEditingController pickupController,
  required FocusNode pickupFocusNode,
  required List<PlacePredictionModel> placePredictions,
  required void Function(PlacePredictionModel prediction) onPlaceSelected,
  required Function() onClearPickupText,
  required Map<dynamic, dynamic> placesSaved,
  required ScrollController scrollController,
  required bool isRecent,
  required bool isQuickPlaceSecondaryOption,
  required Map<String, dynamic> pickUpMap,
}) {
  List<String> historyList = [];
  if (placesSaved.containsKey("recents")) {
    (placesSaved["recents"] as Map).forEach((key, value) => historyList.add(key));
  }

  String? home = placesSaved["home"] != null ? placesSaved["home"]["name"] : null;
  String? work = placesSaved["work"] != null ? placesSaved["work"]["name"] : null;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isQuickPlaceSecondaryOption) ...[
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
                  subtitle: Column(
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
              ],
              ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                leading: const Icon(
                  Icons.location_on,
                  color: BColors.primaryColor1,
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isQuickPlaceSecondaryOption ? "Location" : "WHERE TO", style: Styles.h7Black),
                    if (whereToFocusNode.hasFocus && whereToController.text.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    ],
                  ],
                ),
                subtitle: textFormField(
                  controller: whereToController,
                  hintText: isQuickPlaceSecondaryOption ? 'Enter location' : 'Enter destination',
                  focusNode: whereToFocusNode,
                  removeBorder: true,
                  onTextChange: (String text) => onPlaceTyping(
                    text,
                    RidePlaceFields.whereTo,
                  ),
                  inputPadding: EdgeInsets.zero,
                ),
                trailing: !isQuickPlaceSecondaryOption
                    ? IconButton(
                        icon: const Icon(Icons.add_box),
                        color: BColors.primaryColor1,
                        onPressed: onAddMultiStopsPlaces,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.only(top: topWidgetSize.height + 10),
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
            : !isQuickPlaceSecondaryOption
                ? SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isRecent) ...[
                          Text("Favorite Locations", style: Styles.h5BlackBold),
                          const SizedBox(height: 10),
                          _layout(
                            text: "Set location on map",
                            color: BColors.primaryColor,
                            icon: Icons.location_on,
                            onTap: () => onQuickPlace(QuickPlace.setLocation),
                          ),
                          const SizedBox(height: 10),
                          _layout(
                            text: "Set home location",
                            color: BColors.primaryColor1,
                            icon: Icons.home_filled,
                            onTap: () => onQuickPlace(QuickPlace.home),
                            subtext: home,
                            context: context,
                            onSecondaryTap: () => onSecondaryQuickTap(QuickPlace.home),
                          ),
                          const SizedBox(height: 10),
                          _layout(
                            text: "Set work location",
                            color: BColors.primaryColor,
                            icon: Icons.cases_rounded,
                            onTap: () => onQuickPlace(QuickPlace.work),
                            subtext: work,
                            context: context,
                            onSecondaryTap: () => onSecondaryQuickTap(QuickPlace.work),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (historyList.isNotEmpty) ...[
                          Text("Recent places", style: Styles.h5Black),
                          const SizedBox(height: 10),
                          for (String name in historyList.reversed)
                            _layout(
                              text: name,
                              color: BColors.transparent,
                              iconColor: BColors.black,
                              icon: Icons.restore,
                              iconSize: 25,
                              onTap: () => onRecentPlace(name),
                            ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  )
                : _layout(
                    text: "Set location on map",
                    color: BColors.primaryColor,
                    icon: Icons.location_on,
                    onTap: () => onQuickPlace(QuickPlace.setLocation),
                  ),
      ),
    ],
  );
}

Widget _layout({
  required String text,
  String? subtext,
  required Color color,
  required IconData icon,
  Color? iconColor,
  double? iconSize,
  required void Function() onTap,
  void Function()? onSecondaryTap,
  BuildContext? context,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        onTap: onTap,
        dense: true,
        visualDensity: const VisualDensity(vertical: -3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: CircleAvatar(
          backgroundColor: color,
          radius: 15,
          child: Icon(
            icon,
            color: iconColor ?? BColors.white,
            size: iconSize ?? 15,
          ),
        ),
        title: Text(text, style: Styles.h6Black),
        subtitle: subtext != null ? Text(subtext, style: Styles.h6BlackBold) : null,
        trailing: context != null
            ? subtext != null
                ? IconButton(
                    onPressed: onSecondaryTap,
                    icon: const Icon(Icons.edit),
                    color: BColors.green,
                  )
                : button(
                    onPressed: onSecondaryTap,
                    text: "Set",
                    color: BColors.red,
                    context: context,
                    useWidth: false,
                    textStyle: Styles.h6BlackBold,
                    textColor: BColors.white,
                    height: 30,
                  )
            : null,
      ),
      const Divider(thickness: .2),
    ],
  );
}
