import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/customBackButton.dart';
import 'package:pickme_mobile/pages/homepage/workerHome/widget/workerHomeMap.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget workerMapWidget({
  required BuildContext context,
  required LatLng currentLocation,
  required Set<Marker> markers,
  required void Function(GoogleMapController controller) onMapCreated,
  required double zoom,
  required Set<Polyline> polylines,
  required void Function() onCurrentLocation,
  required void Function() onPaySales,
  required void Function() onBack,
  // required void Function() onTTSVolume,
  required void Function() onGoogleMap,
  // required void Function() onDirection,
  required void Function() onRadius,
  required void Function() onHitmap,
  required void Function() onSideHomeDetails,
  required void Function() onCancelRequest,
  // required bool isTTSVolumeMute,
  required bool isDirecting,
  required void Function(int index) onOnOfflineToggle,
  required WorkerMapNextAction? mapNextAction,
  required bool isShowHomeDetails,
  required bool showCancelButton,
  Set<Circle> circles = const <Circle>{},
  required bool isWorkerToggleLoading,
}) {
  return Stack(
    children: [
      GoogleMap(
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
        circles: circles,
      ),
      Positioned(
        bottom: 60,
        right: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mapNextAction == null) ...[
              _floatingLayout(
                onTap: onRadius,
                icon: const Icon(
                  Icons.radar,
                  color: BColors.black,
                ),
              ),
              const SizedBox(height: 10),
            ],
            _floatingLayout(
              onTap: onCurrentLocation,
              icon: const Icon(
                Icons.gps_fixed,
                color: BColors.black,
              ),
            ),
            if (mapNextAction == null) ...[
              const SizedBox(height: 10),
              _floatingLayout(
                onTap: onHitmap,
                icon: const Icon(
                  FeatherIcons.hexagon,
                  color: BColors.black,
                ),
              ),
            ],
            if (mapNextAction == WorkerMapNextAction.accept || mapNextAction == WorkerMapNextAction.startTrip) ...[
              // _floatingLayout(
              //   onTap: onDirection,
              //   backgroundColor: isDirecting ? BColors.primaryColor1 : BColors.white,
              //   icon: Icon(
              //     FeatherIcons.activity,
              //     color: isDirecting ? BColors.white : BColors.black,
              //   ),
              // ),
              if (isDirecting) ...[
                // const SizedBox(height: 10),
                // _floatingLayout(
                //   onTap: onTTSVolume,
                //   icon: Icon(
                //     isTTSVolumeMute ? FeatherIcons.volume2 : FeatherIcons.volumeX,
                //     color: !isTTSVolumeMute ? BColors.white : BColors.black,
                //   ),
                //   backgroundColor: !isTTSVolumeMute ? BColors.primaryColor1 : BColors.white,
                // ),
              ],
              const SizedBox(height: 10),
              _floatingLayout(
                onTap: onGoogleMap,
                icon: const Icon(FeatherIcons.map, color: BColors.black),
              ),
            ],
          ],
        ),
      ),
      if (mapNextAction != null)
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customBackButton(onBack),
              showCancelButton
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: button(
                        onPressed: onCancelRequest,
                        text: "Cancel Trip",
                        color: BColors.red,
                        context: context,
                        useWidth: false,
                        textStyle: Styles.h5Black,
                        textColor: BColors.white,
                        padding: const EdgeInsets.all(10),
                        height: 40,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      if (mapNextAction == null)
        workerHomeMap(
          context: context,
          onPaySales: onPaySales,
          onOnOfflineToggle: (int index) => onOnOfflineToggle(index),
          onShowHomeDetails: () => onSideHomeDetails(),
          isShowHomeDetails: isShowHomeDetails,
          isWorkerToggleLoading: isWorkerToggleLoading,
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
