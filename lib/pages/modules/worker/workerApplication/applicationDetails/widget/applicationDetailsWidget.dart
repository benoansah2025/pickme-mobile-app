import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

import '../applicationDetails.dart';

Widget applicationDetailsWidget({
  required BuildContext context,
  required WorkersInfoData data,
  required ScrollController scrollController,
  required void Function() updateApplication,
  required bool isEdit,
  required void Function(
    String field,
    ApplicationDetailsPopup popup,
    String title,
  ) onEditLayout,
  required Function(int index) onServiceRemove,
  required Function() onAddService,
}) {
  return Stack(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.only(bottom: isEdit ? 60 : 0),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text("Application Overview", style: Styles.h3BlackBold),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("My Services", style: Styles.h4BlackBold),
                trailing: isEdit
                    ? button(
                        onPressed: onAddService,
                        text: "Add",
                        color: BColors.primaryColor2,
                        context: context,
                        useWidth: false,
                        textColor: BColors.white,
                        textStyle: Styles.h5BlackBold,
                        height: 35,
                      )
                    : null,
              ),
              for (int x = 0; x < data.services!.length; ++x)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: BColors.lightGray.withOpacity(.5),
                    child: Text("${x + 1}", style: Styles.h5BlackBold),
                  ),
                  title: Text(data.services![x], style: Styles.h5BlackBold),
                  trailing: isEdit
                      ? IconButton(
                          onPressed: () => onServiceRemove(x),
                          icon: const Icon(Icons.delete),
                          color: BColors.red,
                        )
                      : null,
                ),
              const SizedBox(height: 20),
              Text("Personal Details", style: Styles.h5BlackBold),
              const SizedBox(height: 10),
              _layout(
                title: "Name",
                subtitle: data.name!,
                isEdit: isEdit,
                onTap: () => onEditLayout(
                  "name",
                  ApplicationDetailsPopup.textbox,
                  "Name",
                ),
              ),
              _layout(
                title: "Date of Birth",
                subtitle: getReaderDate(data.dob!),
                isEdit: isEdit,
                onTap: () => onEditLayout(
                  "dob",
                  ApplicationDetailsPopup.date,
                  "Date of Birth",
                ),
              ),
              _layout(
                title: "Gender",
                subtitle: data.gender!,
                isEdit: isEdit,
                onTap: () => onEditLayout(
                  "gender",
                  ApplicationDetailsPopup.selection,
                  "Gender",
                ),
              ),
              Text("Image Preview", style: Styles.h6Black),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _layoutImage(
                  context: context,
                  image: data.picture,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                  isEdit: isEdit,
                  onTap: () => onEditLayout(
                    "picture",
                    ApplicationDetailsPopup.file,
                    "",
                  ),
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
                      subtitle: data.licenseNumber!,
                      isEdit: isEdit,
                      onTap: () => onEditLayout(
                        "licenseNumber",
                        ApplicationDetailsPopup.textbox,
                        "License Number",
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .35,
                    child: _layout(
                      title: "Expiry Date",
                      subtitle: data.expiryDate!,
                      isEdit: isEdit,
                      onTap: () => onEditLayout(
                        "expiryDate",
                        ApplicationDetailsPopup.date,
                        "Expiry Date",
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _layoutImage(
                    context: context,
                    image: data.licenseFront,
                    height: null,
                    width: MediaQuery.of(context).size.width * .3,
                    fit: BoxFit.fitWidth,
                    isEdit: isEdit,
                    onTap: () => onEditLayout(
                      "licenseFront",
                      ApplicationDetailsPopup.file,
                      "",
                    ),
                  ),
                  const SizedBox(width: 10),
                  _layoutImage(
                    context: context,
                    image: data.licenseBack,
                    height: null,
                    width: MediaQuery.of(context).size.width * .3,
                    fit: BoxFit.fitWidth,
                    isEdit: isEdit,
                    onTap: () => onEditLayout(
                      "licenseBack",
                      ApplicationDetailsPopup.file,
                      "",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _layout(
                title: "Ghana Card No.",
                subtitle: data.ghanacardNo!,
                isEdit: isEdit,
                onTap: () => onEditLayout(
                  "ghanacardNo",
                  ApplicationDetailsPopup.textbox,
                  "Ghana Card No.",
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _layoutImage(
                    context: context,
                    image: data.ghanaCardFront,
                    height: null,
                    width: MediaQuery.of(context).size.width * .3,
                    fit: BoxFit.fitWidth,
                    isEdit: isEdit,
                    onTap: () => onEditLayout(
                      "ghanaCardFront",
                      ApplicationDetailsPopup.file,
                      "",
                    ),
                  ),
                  const SizedBox(width: 10),
                  _layoutImage(
                    context: context,
                    image: data.ghanaCardBack,
                    height: null,
                    width: MediaQuery.of(context).size.width * .3,
                    fit: BoxFit.fitWidth,
                    isEdit: isEdit,
                    onTap: () => onEditLayout(
                      "ghanaCardBack",
                      ApplicationDetailsPopup.file,
                      "",
                    ),
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
                      subtitle: data.vehicleType ?? "N/A",
                      isEdit: isEdit,
                      onTap: () => onEditLayout(
                        "vehicleTypeId",
                        ApplicationDetailsPopup.selection,
                        "Vehicle Type",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .3,
                    child: _layout(
                      title: "${Properties.titleShort.toUpperCase()} Roll Number",
                      subtitle: data.pickmeRollNo!,
                      isEdit: isEdit,
                      onTap: () => onEditLayout(
                        "pickmeRollNo",
                        ApplicationDetailsPopup.textbox,
                        "${Properties.titleShort.toUpperCase()} Roll Number",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .3,
                    child: _layout(
                      title: "Vehicle Make",
                      subtitle: data.vehicleMake ?? "N/A",
                      isEdit: isEdit,
                      onTap: () => onEditLayout(
                        "vehicleMake",
                        ApplicationDetailsPopup.textbox,
                        "Vehicle Make",
                      ),
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
                      subtitle: data.vehicleModel ?? "N/A",
                      isEdit: isEdit,
                      onTap: () => onEditLayout(
                        "vehicleModel",
                        ApplicationDetailsPopup.textbox,
                        "Vehicle Model",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .3,
                    child: _layout(
                      title: "Vehicle Year",
                      subtitle: data.vehicleYear ?? "N/A",
                      isEdit: isEdit,
                      onTap: () => onEditLayout(
                        "vehicleYear",
                        ApplicationDetailsPopup.selection,
                        "Vehicle Year",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .3,
                    child: _layout(
                      title: "Vehicle Color",
                      subtitle: data.vehicleColor ?? "N/A",
                      isEdit: isEdit,
                      onTap: () => onEditLayout(
                        "vehicleColor",
                        ApplicationDetailsPopup.color,
                        "Vehicle Color",
                      ),
                      extra: data.vehicleTypeId,
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
                      subtitle: data.vehicleNumber ?? "N/A",
                      isEdit: isEdit,
                      onTap: () => onEditLayout(
                        "vehicleNumber",
                        ApplicationDetailsPopup.textbox,
                        "Vehicle Number",
                      ),
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
                      subtitle: data.insuranceExpiryDate ?? "N/A",
                      isEdit: isEdit,
                      onTap: () => onEditLayout(
                        "insuranceExpiryDate",
                        ApplicationDetailsPopup.date,
                        "Insuarance Expiry Date",
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .35,
                    child: _layout(
                      title: "Roadworthy Expiry Date",
                      subtitle: data.roadWorthyExpiryDate ?? "N/A",
                      isEdit: isEdit,
                      onTap: () => onEditLayout(
                        "roadWorthyExpiryDate",
                        ApplicationDetailsPopup.date,
                        "Roadworthy Expiry Date",
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _layoutImage(
                    context: context,
                    image: data.insuranceImage,
                    height: null,
                    width: MediaQuery.of(context).size.width * .35,
                    fit: BoxFit.fitWidth,
                    isEdit: isEdit,
                    onTap: () => onEditLayout(
                      "insuranceImage",
                      ApplicationDetailsPopup.file,
                      "",
                    ),
                  ),
                  const SizedBox(width: 10),
                  _layoutImage(
                    context: context,
                    image: data.roadWorthyImage,
                    height: null,
                    width: MediaQuery.of(context).size.width * .35,
                    fit: BoxFit.fitWidth,
                    isEdit: isEdit,
                    onTap: () => onEditLayout(
                      "roadWorthyImage",
                      ApplicationDetailsPopup.file,
                      "",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      if (isEdit)
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: BColors.white,
            padding: const EdgeInsets.all(10),
            child: button(
              onPressed: updateApplication,
              text: "Update",
              color: BColors.primaryColor,
              context: context,
            ),
          ),
        ),
    ],
  );
}

Widget _layoutImage({
  required void Function() onTap,
  required bool isEdit,
  required BoxFit? fit,
  required double? height,
  required double? width,
  required String? image,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: isEdit ? onTap : null,
    child: Stack(
      children: [
        if (image?.contains("http") ?? false)
          cachedImage(
            context: context,
            image: image,
            height: height,
            width: width,
            fit: fit ?? BoxFit.fill,
          ),
        if (!(image?.contains("http") ?? false)) ...[
          image != null
              ? Image.file(
                  File(image),
                  height: height,
                  width: width,
                  fit: fit ?? BoxFit.fill,
                )
              : Image.asset(
                  Images.imageLoadingError,
                  height: height,
                  width: width,
                  fit: fit ?? BoxFit.fill,
                )
        ],
        if (isEdit)
          const Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: BColors.primaryColor2,
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: BColors.white,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

Widget _layout({
  required String title,
  required String subtitle,
  required bool isEdit,
  required void Function() onTap,
  String? extra,
}) {
  return ListTile(
    onTap: isEdit ? onTap : null,
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: Styles.h6Black),
    subtitle: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        title.toLowerCase().contains("color")
            ? SvgPicture.asset(
                getVehicleTypePicture(extra ?? ""),
                height: 30,
                // ignore: deprecated_member_use
                color: convertToColor(subtitle),
              )
            : Text(subtitle, style: Styles.h6BlackBold),
        if (isEdit) ...[
          const SizedBox(width: 3),
          const Icon(
            Icons.edit,
            color: BColors.black,
            size: 20,
          ),
        ],
      ],
    ),
    dense: true,
    visualDensity: const VisualDensity(vertical: -3),
  );
}
