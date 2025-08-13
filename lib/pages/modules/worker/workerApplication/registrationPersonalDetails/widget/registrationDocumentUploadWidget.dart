import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget registrationDocumentUploadWidget({
  required BuildContext context,
  required void Function() onExpiryDate,
  required void Function(String side) onUploadLicense,
  required void Function(String side) onUploadGhanaCard,
  required Key key,
  required TextEditingController licenseController,
  required TextEditingController expiryDateController,
  required TextEditingController cardNoController,
  required FocusNode licenseFocusNode,
  required FocusNode cardFocusNode,
  required String? licenseImageFrontPath,
  required String? licenseImageBackPath,
  required String? ghanaCardFrontPath,
  required String? ghanaCardBackPath,
  required ScrollController scrollController,
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
            Text("Document Uploads", style: Styles.h3BlackBold),
            const SizedBox(height: 20),
            Text(
              "Make sure all information is readable, not blurry and that all corners of the document is visible",
              style: Styles.h6Black,
            ),
            const SizedBox(height: 30),
            Text("License Number", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter number",
              controller: licenseController,
              focusNode: licenseFocusNode,
              validateMsg: Strings.requestField,
            ),
            const SizedBox(height: 20),
            Text("Expiry Date", style: Styles.h6Black),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onExpiryDate,
              child: textFormField(
                hintText: "Select date",
                controller: expiryDateController,
                focusNode: null,
                validateMsg: Strings.requestField,
                enable: false,
                icon: Icons.calendar_month,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                button(
                  onPressed: () => onUploadLicense("front"),
                  text: "License Front",
                  color: BColors.primaryColor1,
                  context: context,
                  useWidth: false,
                  textStyle: Styles.h6BlackBold,
                  icon: const Icon(Icons.receipt, color: BColors.white),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                button(
                  onPressed: () => onUploadLicense("back"),
                  text: "License Back",
                  color: BColors.primaryColor1,
                  context: context,
                  useWidth: false,
                  textStyle: Styles.h6BlackBold,
                  icon: const Icon(Icons.receipt, color: BColors.white),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (licenseImageFrontPath != null)
                  Image.file(
                    File(licenseImageFrontPath),
                    width: MediaQuery.of(context).size.width * .45,
                  ),
                if (licenseImageBackPath != null)
                  Image.file(
                    File(licenseImageBackPath),
                    width: MediaQuery.of(context).size.width * .45,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text("Ghana Card No", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Eg: GHA-xxxxxxxxxxx",
              controller: cardNoController,
              focusNode: cardFocusNode,
              validateMsg: Strings.requestField,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                button(
                  onPressed: () => onUploadGhanaCard("front"),
                  text: "Ghana Card Front",
                  color: BColors.primaryColor1,
                  context: context,
                  useWidth: false,
                  textStyle: Styles.h6BlackBold,
                  icon: const Icon(Icons.receipt, color: BColors.white),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                ),
                button(
                  onPressed: () => onUploadGhanaCard("back"),
                  text: "Ghana Card Back",
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
                if (ghanaCardFrontPath != null)
                  Image.file(
                    File(ghanaCardFrontPath),
                    width: MediaQuery.of(context).size.width * .45,
                  ),
                if (ghanaCardBackPath != null)
                  Image.file(
                    File(ghanaCardBackPath),
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
