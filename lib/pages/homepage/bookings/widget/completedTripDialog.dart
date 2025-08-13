import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';
import 'package:pickme_mobile/config/mapFunction.dart';
import 'package:pickme_mobile/models/allTripsModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

class CompletedTripDialog extends StatefulWidget {
  final AllTripsData trip;
  final List<LatLng> pathCoordinates;
  final bool isRider;

  const CompletedTripDialog({
    super.key,
    required this.pathCoordinates,
    required this.trip,
    this.isRider = true,
  });

  @override
  State<CompletedTripDialog> createState() => _CompletedTripDialogState();
}

class _CompletedTripDialogState extends State<CompletedTripDialog> {
  String? _staticMapImage;
  WorkersInfoModel? _workersInfoModel;

  @override
  void initState() {
    super.initState();
    _generateMapImage();
    _getWorkerInfo();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_staticMapImage == null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: loadingDoubleBounce(BColors.primaryColor),
            ),
          if (_staticMapImage != null) Image.network(_staticMapImage!),
          const SizedBox(height: 10),
          ListTile(
            title: Text("${widget.trip.dateCreated}", style: Styles.h5BlackBold),
            trailing: SvgPicture.asset(
              getVehicleTypePicture(widget.trip.vehicleType ?? ""),
              height: 25,
              // ignore: deprecated_member_use
              color: convertToColor(widget.trip.vehicleColor ?? ""),
            ),
          ),
          const Divider(),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
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
            title: Text("Pickup", style: Styles.h7Black),
            subtitle: Text(widget.trip.pickupLocation!, style: Styles.h6BlackBold),
          ),
          const Divider(indent: 50),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            leading: const Icon(Icons.location_on, color: BColors.primaryColor1),
            subtitle: Text(widget.trip.destinationLocation!, style: Styles.h6BlackBold),
            title: Text(
              "Ride Duration: ${widget.trip.totalMinutes != null ? formatDuration(widget.trip.totalMinutes) : ""} (${widget.trip.totalKm ?? 'N/A '}km)",
              style: Styles.h6Black,
            ),
          ),
          const Divider(),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            leading: Text("Total", style: Styles.h5BlackBold),
            trailing: Text("${Properties.curreny} ${widget.trip.grandTotal!}", style: Styles.h5BlackBold),
          ),
          const Divider(color: BColors.assDeep1),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            leading: Text("Ride price", style: Styles.h5BlackBold),
            trailing: Text("${Properties.curreny} ${widget.trip.grandTotal}", style: Styles.h5BlackBold),
          ),
          const Divider(),
          if (!widget.isRider && !widget.trip.isPass24Hours!) ...[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text("Rider Info", style: Styles.h5BlackBold),
            ),
            ListTile(
              onTap: () => _onCall("${widget.trip.riderPhone}"),
              leading: CircleAvatar(
                backgroundColor: BColors.primaryColor,
                child: Text(getDisplayName(username: widget.trip.riderName!), style: Styles.h5WhiteBold),
              ),
              title: Text(widget.trip.riderName!, style: Styles.h5BlackBold),
              subtitle: Text("${widget.trip.riderPhone}", style: Styles.h6BlackBold),
            ),
          ],
          if (widget.isRider) ...[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text("Driver Info", style: Styles.h5BlackBold),
            ),
            ListTile(
              onTap: () => !widget.trip.isPass24Hours! ? _onCall("${widget.trip.driverPhone}") : null,
              leading: _workersInfoModel == null
                  ? SizedBox(
                      height: 50,
                      width: 50,
                      child: loadingDoubleBounce(BColors.primaryColor, size: 20),
                    )
                  : circular(
                      child: cachedImage(
                        context: context,
                        image: _workersInfoModel!.data!.picture ?? "",
                        height: 50,
                        width: 50,
                        placeholder: Images.defaultProfilePicOffline,
                      ),
                      size: 50,
                    ),
              title: Text(widget.trip.driverName!, style: Styles.h5BlackBold),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.trip.vehicleModel} ${widget.trip.vehicleMake} (${widget.trip.vehicleNumber!})",
                    style: Styles.h6BlackBold,
                  ),
                  if (!widget.trip.isPass24Hours!) Text("${widget.trip.driverPhone}", style: Styles.h6BlackBold),
                ],
              ),
              trailing: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: BColors.yellow1),
                      const SizedBox(width: 10),
                      Text("${widget.trip.riderRating}", style: Styles.h6BlackBold),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _onCall(String phone) async {
    callLauncher("tel: $phone");
  }

  Future<void> _generateMapImage() async {
    Map? cacheData = await getHive("generateMapImage");
    String cacheImageLink = "";
    if (cacheData != null) {
      cacheImageLink = cacheData[widget.trip.tripId] ?? "";
    }
    var pathCoordinates = widget.pathCoordinates;

    if (cacheImageLink == "") {
      _staticMapImage = await generateStaticMapUrl(
        startLat: pathCoordinates.first.latitude,
        startLng: pathCoordinates.first.longitude,
        endLat: pathCoordinates.last.latitude,
        endLng: pathCoordinates.last.longitude,
        pathCoordinates: pathCoordinates,
      );
      cacheData = {
        ...cacheData ?? {},
        ...{widget.trip.tripId: _staticMapImage}
      };
      await saveHive(key: "generateMapImage", data: cacheData);
    } else {
      _staticMapImage = cacheImageLink;
    }
    setState(() {});
  }

  Future<void> _getWorkerInfo() async {
    WorkersInfoModel model = await WorkersInfoProvider().fetch(userId: widget.trip.driverId!);
    _workersInfoModel = model;
    if (!mounted) return;
    setState(() {});
  }
}
