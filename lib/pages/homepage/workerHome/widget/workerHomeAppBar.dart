import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

AppBar workerHomeAppBar({
  required void Function() onDrawer,
  required void Function(String? tap) onSos,
}) {
  return AppBar(
    backgroundColor: BColors.primaryColor,
    leading: IconButton(
      onPressed: onDrawer,
      icon: const Icon(Icons.menu),
      color: BColors.white,
    ),
    title: Text("Ride", style: Styles.h4WhiteBold),
    actions: [
      GestureDetector(
        onTap: () => onSos(null),
        onLongPress: () => onSos("openEmergency"),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: BColors.red,
            radius: 30,
            child: Text("SOS", style: Styles.h6WhiteBold),
          ),
        ),
      ),
    ],
  );
}
