import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget registrationPersonalDetailsWidget({
  required BuildContext context,
  required void Function() onSnap,
  required void Function() onDOB,
  required void Function() onGender,
  required Key key,
  required TextEditingController nameController,
  required TextEditingController dobController,
  required TextEditingController genderController,
  required FocusNode nameFocusNode,
  required String? imagePath,
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
            Text("Personal Photo Uploads", style: Styles.h3BlackBold),
            const SizedBox(height: 20),
            Text(
              "1. Face the camera directly with your eyes open and the entire face clearly visible \n\n2. Make sure the environment is well lit to keep you in focus, and to free the photo of glare \n\n3.  No edited or filtered photos permitted",
              style: Styles.h6Black,
            ),
            const SizedBox(height: 30),
            Center(
              child: InkWell(
                onTap: onSnap,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: BColors.assDeep),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      children: [
                        if (imagePath != null) ...[
                          Image.file(
                            File(imagePath),
                            width: 140,
                            height: 140,
                            fit: BoxFit.fitWidth,
                          ),
                          Container(
                            width: 140,
                            height: 140,
                            color: BColors.black.withOpacity(.4),
                          ),
                        ],
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.camera_alt_rounded,
                                color: BColors.assDeep,
                                size: 40,
                              ),
                              const SizedBox(height: 5),
                              Text("Take a shot", style: Styles.h5Ashdeep),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Personal Details", style: Styles.h3BlackBold),
            const SizedBox(height: 20),
            Text("Name", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter fullname",
              controller: nameController,
              focusNode: nameFocusNode,
              validateMsg: Strings.requestField,
              inputType: TextInputType.name,
            ),
            const SizedBox(height: 20),
            Text("Date of birth", style: Styles.h6Black),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onDOB,
              child: textFormField(
                hintText: "Select date of birth",
                controller: dobController,
                focusNode: null,
                validateMsg: Strings.requestField,
                enable: false,
                icon: Icons.calendar_month,
              ),
            ),
            const SizedBox(height: 20),
            Text("Gender", style: Styles.h6Black),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onGender,
              child: textFormField(
                hintText: "Select gender",
                controller: genderController,
                focusNode: null,
                validateMsg: Strings.requestField,
                enable: false,
                icon: Icons.arrow_drop_down,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}
