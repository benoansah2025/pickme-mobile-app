import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget vendorServiceDetailsWidget({
  required BuildContext context,
  required void Function() onServicePhoto,
  required Key key,
  required TextEditingController serviceNameController,
  required TextEditingController emailController,
  required TextEditingController phoneController,
  required FocusNode serviceNameFocusNode,
  required FocusNode emailFocusNode,
  required FocusNode phoneFocusNode,
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
            Text("Service Photo Uploads", style: Styles.h3BlackBold),
            const SizedBox(height: 30),
            Center(
              child: InkWell(
                onTap: onServicePhoto,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: BColors.assDeep),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SizedBox(
                    width: 300,
                    height: 150,
                    child: Stack(
                      children: [
                        if (imagePath != null) ...[
                          imagePath.contains("http")
                              ? cachedImage(
                                  context: context,
                                  image: imagePath,
                                  height: 150,
                                  width: 300,
                                  fit: BoxFit.contain,
                                )
                              : Image.file(
                                  File(imagePath),
                                  width: 300,
                                  height: 150,
                                  fit: BoxFit.contain,
                                ),
                          Container(
                            width: 300,
                            height: 150,
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
                              Text("Take image", style: Styles.h5Ashdeep),
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
            Text("Service Details", style: Styles.h3BlackBold),
            const SizedBox(height: 20),
            Text("Name", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter service name",
              controller: serviceNameController,
              focusNode: serviceNameFocusNode,
              validateMsg: Strings.requestField,
              inputType: TextInputType.name,
            ),
            const SizedBox(height: 20),
            Text("Phone", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter phone number",
              controller: phoneController,
              focusNode: phoneFocusNode,
              validateMsg: Strings.requestField,
              inputType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            Text("Email", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter email address",
              controller: emailController,
              focusNode: emailFocusNode,
              validateMsg: Strings.requestField,
              inputType: TextInputType.emailAddress,
              validateEmail: true,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}
