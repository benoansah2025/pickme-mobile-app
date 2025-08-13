import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/notificationsModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

class NotificationTripDialog extends StatefulWidget {
  final NotificationData data;

  const NotificationTripDialog({
    super.key,
    required this.data,
  });

  @override
  State<NotificationTripDialog> createState() => _CompletedTripDialogState();
}

class _CompletedTripDialogState extends State<NotificationTripDialog> {
  // String? _staticMapImage;
  // WorkersInfoModel? _workersInfoModel;

  @override
  void initState() {
    super.initState();
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
          const SizedBox(height: 10),
          ListTile(
            title: Text(
              getReaderDate(
                widget.data.tripDetailsModel!.createAt!.toDate().toString(),
                showTime: true,
              ),
              style: Styles.h5BlackBold,
            ),
            subtitle: Text(
              widget.data.tripDetailsModel!.status!,
              style: Styles.h6BlackBold,
            ),
            trailing: SvgPicture.asset(
              getVehicleTypePicture(widget.data.tripDetailsModel!.vehicleType ?? ""),
              height: 25,
              // ignore: deprecated_member_use
              color: convertToColor(widget.data.tripDetailsModel!.vehicleColor ?? ""),
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
            subtitle: Text(widget.data.tripDetailsModel!.pickupLocation!, style: Styles.h6BlackBold),
          ),
          const Divider(indent: 50),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            leading: const Icon(Icons.location_on, color: BColors.primaryColor1),
            subtitle: Text(widget.data.tripDetailsModel!.destinationLocation!, style: Styles.h6BlackBold),
            title: Text("Destination", style: Styles.h6Black),
          ),
          const Divider(),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            leading: Text("Estimated price", style: Styles.h5BlackBold),
            trailing: Text(
              "${Properties.curreny} ${widget.data.tripDetailsModel!.estimatedTotalAmount}",
              style: Styles.h5BlackBold,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> _getWorkerInfo() async {
    // WorkersInfoModel model = await WorkersInfoProvider().fetch(userId: widget.data.tripDetailsModel!.driverId!);
    // _workersInfoModel = model;
    if (!mounted) return;
    setState(() {});
  }
}
