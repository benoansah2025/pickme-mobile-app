import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';
import 'package:pickme_mobile/config/mapFunction.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/models/driverRequestModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

class WorkerRideRequestDialog extends StatefulWidget {
  final VoidCallback onReject;
  final VoidCallback onAccept;
  final int remainTimeInSec;
  final DriverRequestModel model;

  const WorkerRideRequestDialog({
    required this.onReject,
    required this.onAccept,
    required this.remainTimeInSec,
    required this.model,
    super.key,
  });

  @override
  State<WorkerRideRequestDialog> createState() => _WorkerRideRequestDialogState();
}

class _WorkerRideRequestDialogState extends State<WorkerRideRequestDialog> {
  int remainTimeSec = 0;
  Timer? _timer;

  WorkersInfoModel? _riderDetailsInfoModel;

  @override
  void initState() {
    super.initState();
    _loadRiderInfoDetails();
    remainTimeSec = widget.remainTimeInSec;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainTimeSec == 0) {
          timer.cancel();
          navigation(context: context, pageName: "back");
        } else {
          remainTimeSec--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRiderInfoDetails() async {
    _riderDetailsInfoModel = await WorkersInfoProvider().fetch(userId: widget.model.currentRideDetails!.riderId);
    await saveHive(
      key: "riderRating",
      data: "${_riderDetailsInfoModel!.data != null ? _riderDetailsInfoModel!.data!.rating : 'N/A'}",
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: double.maxFinite,
        decoration: const BoxDecoration(
          color: BColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 20),
            Text("Incoming Request", style: Styles.h6BlackBold),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: circular(
                child: cachedImage(
                  context: context,
                  image: widget.model.currentRideDetails!.riderPicture,
                  height: 50,
                  width: 50,
                  placeholder: Images.defaultProfilePicOffline,
                ),
                size: 50,
              ),
              title: Text(
                widget.model.currentRideDetails!.riderName!,
                style: Styles.h4BlackBold,
              ),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: BColors.yellow1),
                  const SizedBox(width: 10),
                  _riderDetailsInfoModel == null
                      ? loadingDoubleBounce(BColors.primaryColor, size: 20)
                      : Text(
                          "${_riderDetailsInfoModel!.data != null ? _riderDetailsInfoModel!.data!.rating : 'N/A'}",
                          style: Styles.h6BlackBold,
                        ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${Properties.curreny} ${widget.model.currentTripDetails!.estimatedTotalAmount}",
              style: Styles.h2Black,
            ),
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
              title: Text(
                "${formatDuration(widget.model.currentRideDetails!.riderDuration!)} (${widget.model.currentRideDetails!.riderDistanceInKm} Km) away",
                style: Styles.h5BlackBold,
              ),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.model.currentRideDetails!.riderLocationInText!,
                    style: Styles.h4BlackBold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.model.currentRideDetails!.riderNearbyLocation != "") ...[
                    const SizedBox(height: 5),
                    !isCodePlaceName(widget.model.currentRideDetails!.riderNearbyLocation!)
                        ? widget.model.currentRideDetails!.riderNearbyLocation != ""
                            ? Text(
                                widget.model.currentRideDetails!.riderNearbyLocation!,
                                style: Styles.h6PrimaryBold,
                              )
                            : const SizedBox()
                        : Text(
                            "Nearby: ${widget.model.currentRideDetails!.riderNearbyLocation}",
                            style: Styles.h6PrimaryBold,
                          ),
                  ]
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.location_on,
                color: BColors.primaryColor1,
              ),
              title: Text(
                "${formatDuration(widget.model.currentRideDetails!.destinationDuration!)} (${widget.model.currentRideDetails!.destinationDistanceInKm} Km) trip",
                style: Styles.h5BlackBold,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.model.currentRideDetails!.destinationInText!,
                    style: Styles.h4BlackBold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.model.currentRideDetails!.stops!.isNotEmpty)
                    Text("(${widget.model.currentRideDetails!.stops!.length}) additional stop points",
                        style: Styles.h5Primary1Bold),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                button(
                  onPressed: widget.onReject,
                  text: "Reject $remainTimeSec",
                  color: BColors.primaryColor1,
                  context: context,
                  divideWidth: .45,
                  colorFill: false,
                  backgroundcolor: BColors.white,
                  textColor: BColors.primaryColor1,
                  borderWidth: 2,
                ),
                button(
                  onPressed: widget.onAccept,
                  text: "Accept",
                  color: BColors.primaryColor,
                  context: context,
                  divideWidth: .45,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
