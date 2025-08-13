import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/tripEstimateModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

AlertDialog rideDetialsDialog({
  required BuildContext context,
  required void Function() onClose,
  required Car data,
}) {
  return AlertDialog(
    title: Text("Ride Details", style: Styles.h6BlackBold),
    backgroundColor: BColors.white,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        ListTile(
          leading: Image.asset(
            data.vehicleTypeId == "2"
                ? Images.ride2
                : data.vehicleTypeId == "3"
                    ? Images.ride3
                    : Images.ride1,
            width: 50,
            height: 50,
            fit: BoxFit.fitHeight,
          ),
          title: Text(getVehicleTypeName(data.vehicleTypeId!), style: Styles.h6BlackBold),
          subtitle: Text("${Properties.curreny} ${data.totalFee}", style: Styles.h5BlackBold),
        ),
        const Divider(),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: -3),
          title: Text("Base Fee", style: Styles.h6BlackBold),
          trailing: Text("${Properties.curreny} ${data.baseFee ?? 'N/A'}", style: Styles.h6Black),
        ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: -3),
          title: Text("Km Fee", style: Styles.h6BlackBold),
          trailing: Text("${Properties.curreny} ${data.kmFee ?? 'N/A'}", style: Styles.h6Black),
        ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: -3),
          title: Text("Minute Fee", style: Styles.h6BlackBold),
          trailing: Text("${Properties.curreny} ${data.minuteFee ?? 'N/A'}", style: Styles.h6Black),
        ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: -3),
          title: Text("Vehicle Base Fare", style: Styles.h6BlackBold),
          trailing: Text("${Properties.curreny} ${data.vehicleTypeBaseFare ?? 'N/A'}", style: Styles.h6Black),
        ),
        const SizedBox(height: 20),
        button(
          onPressed: onClose,
          text: "Close",
          color: BColors.red,
          context: context,
          height: 40,
        )
      ],
    ),
  );
}
