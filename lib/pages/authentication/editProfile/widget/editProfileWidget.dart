import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget editProfileWidget({
  required BuildContext context,
  required TextEditingController? nameController,
  required TextEditingController? emailController,
  required TextEditingController? phoneController,
  required TextEditingController? dobController,
  required TextEditingController? genderController,
  required FocusNode? nameFocusNode,
  required FocusNode? emailFocusNode,
  required FocusNode? phoneFocusNode,
  required Function()? onDOB,
  required Function()? onGender,
  required GlobalKey<FormState>? formKey,
  @required String? profilePic,
  @required bool? isLocalUpload,
  @required void Function()? onUploadProfilePicture,
}) {
  return SingleChildScrollView(
    child: Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Center(
            child: circular(
              child: isLocalUpload!
                  ? Image.file(
                      File(profilePic!),
                      height: 160,
                      width: 160,
                      fit: BoxFit.fitWidth,
                    )
                  : cachedImage(
                      context: context,
                      image: profilePic,
                      height: 160,
                      width: 160,
                      placeholder: Images.defaultProfilePicOffline,
                      fit: BoxFit.fitWidth,
                    ),
              size: 160,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: button(
              onPressed: onUploadProfilePicture,
              text: 'Upload',
              color: BColors.primaryColor1,
              context: context,
              useWidth: false,
              textColor: BColors.white,
              height: 30,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Full name", style: Styles.h6Black),
                const SizedBox(height: 10),
                textFormField(
                  hintText: 'Enter your full name',
                  controller: nameController,
                  focusNode: nameFocusNode,
                  validate: true,
                  validateMsg: Strings.requestField,
                ),
                const SizedBox(height: 10),
                Text("Date of Birth (Optional)", style: Styles.h6Black),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onDOB,
                  child: textFormField(
                    hintText: 'Select DOB',
                    controller: dobController,
                    focusNode: null,
                    validate: false,
                    enable: false,
                    icon: Icons.calendar_month,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Gender (Optional)", style: Styles.h6Black),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onGender,
                  child: textFormField(
                    hintText: 'Select Gender',
                    controller: genderController,
                    focusNode: null,
                    validate: false,
                    enable: false,
                    icon: Icons.arrow_drop_down,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Email", style: Styles.h6Black),
                const SizedBox(height: 10),
                textFormField(
                  hintText: 'Email (eg. example@mail.com) ',
                  controller: emailController,
                  focusNode: emailFocusNode,
                  validateEmail: false,
                  validate: false,
                  validateMsg: Strings.requestField,
                  inputType: TextInputType.emailAddress,
                  enable: emailController!.text.isEmpty,
                  borderColor: emailController.text.isEmpty ? BColors.assDeep : BColors.background,
                  backgroundColor: emailController.text.isEmpty ? BColors.white : BColors.background,
                ),
                const SizedBox(height: 10),
                Text("Phone", style: Styles.h6Black),
                const SizedBox(height: 10),
                textFormField(
                  hintText: '',
                  controller: phoneController,
                  focusNode: phoneFocusNode,
                  validate: true,
                  borderColor: phoneController!.text.isEmpty ? BColors.assDeep : BColors.background,
                  backgroundColor: phoneController.text.isEmpty ? BColors.white : BColors.background,
                  enable: phoneController.text.isEmpty,
                ),
                const SizedBox(height: 10),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
