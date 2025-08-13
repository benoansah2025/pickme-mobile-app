
import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget vendorPersonalDetailsWidget({
  required BuildContext context,
  required Key key,
  required TextEditingController vendorNameController,
  required TextEditingController regionController,
  required TextEditingController townController,
  required FocusNode vendorNameFocusNode,
  required FocusNode townFocusNode,
  required ScrollController scrollController,
  required void Function() onRegion,
  required TextEditingController districtController,
  required TextEditingController streetnameController,
  required FocusNode districtFocusNode,
  required FocusNode streetnameFocusNode,
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
            Text("Vendor Details", style: Styles.h3BlackBold),
            const SizedBox(height: 20),
            Text("Vendor Name", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter name",
              controller: vendorNameController,
              focusNode: vendorNameFocusNode,
              validateMsg: Strings.requestField,
              inputType: TextInputType.name,
            ),
            const SizedBox(height: 20),
            Text("Region", style: Styles.h6Black),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onRegion,
              child: textFormField(
                hintText: "Select region",
                controller: regionController,
                focusNode: null,
                validateMsg: Strings.requestField,
                enable: false,
                icon: Icons.arrow_drop_down,
              ),
            ),
            const SizedBox(height: 20),
            Text("Town", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter town",
              controller: townController,
              focusNode: townFocusNode,
              validateMsg: Strings.requestField,
            ),
            const SizedBox(height: 20),
            Text("District", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter district",
              controller: districtController,
              focusNode: districtFocusNode,
              validateMsg: Strings.requestField,
            ),
            const SizedBox(height: 20),
            Text("Streetname", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter Streetname",
              controller: streetnameController,
              focusNode: streetnameFocusNode,
              validateMsg: Strings.requestField,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}
