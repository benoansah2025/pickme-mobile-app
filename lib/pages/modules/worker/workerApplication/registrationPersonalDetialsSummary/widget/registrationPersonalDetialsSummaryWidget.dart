import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget registrationPersonalDetialsSummaryWidget({
  required BuildContext context,
  required Map<String, dynamic> meta,
  required void Function() onConfirm,
  required ScrollController scrollController,
}) {
  return Stack(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.only(bottom: 60),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text("Application Overview", style: Styles.h3BlackBold),
              const SizedBox(height: 20),
              Text("Personal Details", style: Styles.h5BlackBold),
              const SizedBox(height: 10),
              _layout(title: "Name", subtitle: meta["name"]),
              _layout(title: "Date of Birth", subtitle: getReaderDate(meta["dob"])),
              _layout(title: "Gender", subtitle: meta["gender"]),
              Text("Image Preview", style: Styles.h6Black),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(meta["imagePath"]),
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text("Documents Details", style: Styles.h4BlackBold),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .35,
                    child: _layout(
                      title: "License Number",
                      subtitle: meta["license"],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .35,
                    child: _layout(
                      title: "Expiry Date",
                      subtitle: meta["expiryDate"],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.file(
                    File(meta["licenseImageFrontPath"]),
                    width: MediaQuery.of(context).size.width * .3,
                  ),
                  const SizedBox(width: 10),
                  Image.file(
                    File(meta["licenseImageBackPath"]),
                    width: MediaQuery.of(context).size.width * .3,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _layout(title: "Ghana Card No.", subtitle: meta["cardNo"]),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.file(
                    File(meta["ghanaCardFrontPath"]),
                    width: MediaQuery.of(context).size.width * .3,
                  ),
                  const SizedBox(width: 10),
                  Image.file(
                    File(meta["ghanaCardBackPath"]),
                    width: MediaQuery.of(context).size.width * .3,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text("Vehicle Details", style: Styles.h4BlackBold),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .3,
                    child: _layout(
                      title: "Vehicle Type",
                      subtitle: meta["vehicletype"],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .3,
                    child: _layout(
                      title: "${Properties.titleShort.toUpperCase()} Roll Number",
                      subtitle: meta["pickRoll"],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .3,
                    child: _layout(
                      title: "Vehicle Make",
                      subtitle: meta["vehicleMake"],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .3,
                    child: _layout(
                      title: "Vehicle Model",
                      subtitle: meta["vehicleModel"],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .3,
                    child: _layout(
                      title: "Vehicle Year",
                      subtitle: meta["vehicleYear"],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .3,
                    child: _layout(
                      title: "Vehicle Color",
                      subtitle: meta["vehicleColor"],
                      extra: meta["vehicletype"],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .3,
                    child: _layout(
                      title: "Vehicle Number",
                      subtitle: meta["vehicleNumber"],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .35,
                    child: _layout(
                      title: "Insuarance Expiry Date",
                      subtitle: meta["insuranceDate"],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .35,
                    child: _layout(
                      title: "Roadworthy Expiry Date",
                      subtitle: meta["roadWorthyDate"],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.file(
                    File(meta["insurancePath"]),
                    width: MediaQuery.of(context).size.width * .35,
                  ),
                  const SizedBox(width: 10),
                  Image.file(
                    File(meta["roadWorthyPath"]),
                    width: MediaQuery.of(context).size.width * .35,
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: BColors.white,
          padding: const EdgeInsets.all(10),
          child: button(
            onPressed: onConfirm,
            text: "Confirm",
            color: BColors.primaryColor,
            context: context,
          ),
        ),
      ),
    ],
  );
}

Widget _layout({
  required String title,
  required String subtitle,
  String? extra,
}) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: Styles.h6Black),
    subtitle: title.toLowerCase().contains("color")
        ? SvgPicture.asset(
            getVehicleTypePicture(extra ?? ""),
            height: 30,
            // ignore: deprecated_member_use
            color: Color(int.parse("0x$subtitle")),
          )
        : Text(subtitle, style: Styles.h6BlackBold),
    dense: true,
    visualDensity: const VisualDensity(vertical: -3),
  );
}
