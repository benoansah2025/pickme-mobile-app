import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/models/ridePickUpModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

AlertDialog stopsDialog({
  required BuildContext context,
  required RidePickUpModel ridePickUpModel,
}) {
  return AlertDialog(
    title: Text("Stops", style: Styles.h6BlackBold),
    backgroundColor: BColors.white,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int x = 0; x < ridePickUpModel.busStops!.length; ++x) ...[
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            visualDensity: const VisualDensity(vertical: -3),
            leading: const Icon(Icons.circle, color: BColors.red, size: 20),
            title: Text("Stop ${x + 1}", style: Styles.h6BlackBold),
            subtitle: Text(ridePickUpModel.busStops![x].name!, style: Styles.h5Black),
          ),
          const Divider(indent: 30),
        ],
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(vertical: -3),
          leading: const Icon(Icons.circle, color: BColors.red, size: 20),
          title: Text("Last Stop", style: Styles.h6BlackBold),
          subtitle: Text(ridePickUpModel.whereTo!.name!, style: Styles.h5Black),
        ),
        const SizedBox(height: 10),
        button(
          onPressed: () {
            Navigator.pop(context);
          },
          text: "Close",
          color: BColors.red,
          context: context,
          height: 40,
        )
      ],
    ),
  );
}
