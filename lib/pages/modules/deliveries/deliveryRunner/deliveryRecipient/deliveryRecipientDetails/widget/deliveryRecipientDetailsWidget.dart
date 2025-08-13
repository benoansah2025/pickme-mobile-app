import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget deliveryRecipientDetailsWidget({
  required BuildContext context,
  required Key key,
  required TextEditingController nameController,
  required TextEditingController phoneController,
  required TextEditingController packageController,
  required TextEditingController deliveryInstructionController,
  required FocusNode? deliveryInstructionFocusNode,
  required FocusNode? phoneFocusNode,
  required FocusNode? nameFocusNode,
  required void Function() onSubmit,
  required void Function() onPackageType,
  required Map<dynamic, dynamic> deliveryAddresses,
  required RideMapNextAction rideMapNextAction,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Form(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              rideMapNextAction == RideMapNextAction.deliverySendItem ? "Recipient Details" : "PICKUP/ SENDER DETAILS",
              style: Styles.h3BlackBold,
            ),
            const SizedBox(height: 30),
            Text(
              rideMapNextAction == RideMapNextAction.deliverySendItem ? "Recipent Name" : "Sender's Name",
              style: Styles.h6Black,
            ),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Eg: Qhobbie Junior",
              controller: nameController,
              focusNode: nameFocusNode,
              validateMsg: Strings.requestField,
            ),
            const SizedBox(height: 20),
            Text("Phone", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "",
              controller: phoneController,
              focusNode: phoneFocusNode,
              validateMsg: Strings.requestField,
              inputType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            Text("Package Type", style: Styles.h6Black),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onPackageType,
              child: textFormField(
                hintText: "Package Type",
                controller: packageController,
                focusNode: null,
                validateMsg: Strings.requestField,
                enable: false,
                icon: Icons.arrow_drop_down,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              rideMapNextAction == RideMapNextAction.deliverySendItem ? "Delivery Instruction" : "Sending Instruction ",
              style: Styles.h6Black,
            ),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Write here",
              controller: deliveryInstructionController,
              focusNode: deliveryInstructionFocusNode,
              validateMsg: Strings.requestField,
              validate: false,
              maxLine: null,
              minLine: 4,
            ),
            const SizedBox(height: 20),
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: BColors.primaryColor),
                ),
                child: const Icon(
                  Icons.circle,
                  color: BColors.primaryColor,
                  size: 15,
                ),
              ),
              title: Text("PICKUP", style: Styles.h6Black),
              subtitle: Text(
                deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["name"] == ""
                    ? "My current location"
                    : deliveryAddresses[DeliveryAccessLocation.pickUpLocation]["name"],
                style: Styles.h4BlackBold,
              ),
            ),
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.location_on,
                color: BColors.primaryColor1,
              ),
              title: Text("WHERE TO", style: Styles.h6Black),
              subtitle: Text(
                deliveryAddresses[DeliveryAccessLocation.whereToLocation] == null
                    ? "Enter location"
                    : deliveryAddresses[DeliveryAccessLocation.whereToLocation]["name"],
                style: Styles.h4BlackBold,
              ),
            ),
            const SizedBox(height: 20),
            button(
              onPressed: onSubmit,
              text: "Submit",
              color: BColors.primaryColor,
              context: context,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
