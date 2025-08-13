import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget registrationVehicleDetailsWidget({
  required BuildContext context,
  required void Function() onRoadWorthyDate,
  required void Function() onVehicleType,
  required void Function() onVehicleYear,
  required void Function() onInsuranceDate,
  required void Function() onInsuranceImage,
  required void Function() onRoadWorthyImage,
  required void Function() onSelectColor,
  required Key key,
  required TextEditingController pickRollController,
  required TextEditingController vehicletypeController,
  required TextEditingController vehicleYearController,
  required TextEditingController roadWorthyDateController,
  required TextEditingController insuranceDateController,
  required TextEditingController vehicleColorController,
  required TextEditingController vehicleNumberController,
  required TextEditingController vehicleModelController,
  required TextEditingController vehicleMakeController,
  required FocusNode pickRollFocusNode,
  required FocusNode vehicleColorFocusNode,
  required FocusNode vehicleNumberFocusNode,
  required FocusNode vehicleModelFocusNode,
  required FocusNode vehicleMakeFocusNode,
  required String? roadWorthyPath,
  required String? insurancePath,
  required ScrollController scrollController,
  required String? vehicleTypeId,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      controller: scrollController,
      child: Form(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text("Caution", style: Styles.h3BlackBold),
            const SizedBox(height: 20),
            Text(
              "Make sure all information provided is accurate and truthful. Any evidence of false information will delay or lead to the rejection of your application",
              style: Styles.h6Black,
            ),
            const SizedBox(height: 30),
            Text("Vehicle type", style: Styles.h6Black),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onVehicleType,
              child: textFormField(
                hintText: "Select type...",
                controller: vehicletypeController,
                focusNode: null,
                validateMsg: Strings.requestField,
                enable: false,
                icon: Icons.arrow_drop_down,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "${Properties.titleShort.toUpperCase()} roll number",
              style: Styles.h6Black,
            ),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter number",
              controller: pickRollController,
              focusNode: pickRollFocusNode,
              validateMsg: Strings.requestField,
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Text(
              "Vehicle Make (if you chose a car initially)",
              style: Styles.h6Black,
            ),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter number",
              controller: vehicleMakeController,
              focusNode: vehicleMakeFocusNode,
              validateMsg: Strings.requestField,
            ),
            const SizedBox(height: 20),
            Text("Vehicle Model", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter model",
              controller: vehicleModelController,
              focusNode: vehicleModelFocusNode,
              validateMsg: Strings.requestField,
            ),
            const SizedBox(height: 20),
            Text("Vehicle Year", style: Styles.h6Black),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onVehicleYear,
              child: textFormField(
                hintText: "Select year",
                controller: vehicleYearController,
                focusNode: null,
                validateMsg: Strings.requestField,
                enable: false,
                icon: Icons.arrow_drop_down,
              ),
            ),
            const SizedBox(height: 20),
            Text("Vehicle Number", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter number",
              controller: vehicleNumberController,
              focusNode: vehicleNumberFocusNode,
              validateMsg: Strings.requestField,
            ),
            const SizedBox(height: 20),
            Text("Vehicle Color", style: Styles.h6Black),
            const SizedBox(height: 10),
            if (vehicleColorController.text.isEmpty)
              GestureDetector(
                onTap: onSelectColor,
                child: textFormField(
                  hintText: "Select color",
                  controller: vehicleColorController,
                  focusNode: vehicleColorFocusNode,
                  validateMsg: Strings.requestField,
                  enable: false,
                  icon: Icons.arrow_drop_down,
                ),
              ),
            if (vehicleColorController.text.isNotEmpty)
              Container(
                color: BColors.grey.withOpacity(.2),
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                     getVehicleTypePicture(vehicleTypeId!),
                      height: 35,
                      // ignore: deprecated_member_use
                      color: Color(
                        int.parse("0x${vehicleColorController.text}"),
                      ),
                    ),
                    button(
                      onPressed: onSelectColor,
                      text: "Change Color",
                      color: BColors.primaryColor1,
                      context: context,
                      useWidth: false,
                      height: 35,
                      textStyle: Styles.h6BlackBold,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Text("Insurance Expiry Date", style: Styles.h6Black),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onInsuranceDate,
              child: textFormField(
                hintText: "Select date",
                controller: insuranceDateController,
                focusNode: null,
                validateMsg: Strings.requestField,
                enable: false,
                icon: Icons.arrow_drop_down,
              ),
            ),
            const SizedBox(height: 20),
            Text("Road Worthy Expiry Date", style: Styles.h6Black),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onRoadWorthyDate,
              child: textFormField(
                hintText: "Select date",
                controller: roadWorthyDateController,
                focusNode: null,
                validateMsg: Strings.requestField,
                enable: false,
                icon: Icons.arrow_drop_down,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                button(
                  onPressed: onInsuranceImage,
                  text: "Insurance Image",
                  color: BColors.primaryColor1,
                  context: context,
                  useWidth: false,
                  textStyle: Styles.h6BlackBold,
                  icon: const Icon(Icons.receipt, color: BColors.white),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                ),
                button(
                  onPressed: onRoadWorthyImage,
                  text: "Road Worthy Image",
                  color: BColors.primaryColor1,
                  context: context,
                  useWidth: false,
                  textStyle: Styles.h6BlackBold,
                  icon: const Icon(Icons.receipt, color: BColors.white),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (insurancePath != null)
                  Image.file(
                    File(insurancePath),
                    width: MediaQuery.of(context).size.width * .45,
                  ),
                if (roadWorthyPath != null)
                  Image.file(
                    File(roadWorthyPath),
                    width: MediaQuery.of(context).size.width * .45,
                  ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}
