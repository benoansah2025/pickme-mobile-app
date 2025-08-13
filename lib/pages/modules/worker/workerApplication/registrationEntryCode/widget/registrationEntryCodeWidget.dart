import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget registrationEntryCodeWidget({
  required BuildContext context,
  required TextEditingController codeController,
  required FocusNode codeFocusNode,
  required void Function() onSend,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text("Entry Code", style: Styles.h3BlackBold),
          const SizedBox(height: 20),
          Text(
            "Kindly come to the pickme office for your entry code to proceed. We want to physically verify all documents.",
            style: Styles.h6Black,
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              text: "Here's what you need when coming to the office.\n\n",
              children: [
                TextSpan(
                  text:
                      "* Original copy of your Ghana Card \n* Original copy of your driver's license \n* The car you  intend to use for the pickme service;\n\n\n",
                  style: Styles.h6BlackBold,
                ),
                TextSpan(
                  text:
                      "we would like to check the DVLA road worthiness sticker and the insurance sticker provided by the insurance company\n\n\n",
                  style: Styles.h6Black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Please enter the code sent to \n**** **** ${displayChars(text: userModel!.data!.user!.phone!)}",
            style: Styles.h4BlackBold,
          ),
          const SizedBox(height: 20),
          textFormField(
            hintText: "",
            controller: codeController,
            focusNode: codeFocusNode,
          ),
          const SizedBox(height: 30),
          button(
            onPressed: onSend,
            text: "Send",
            color: BColors.primaryColor,
            context: context,
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
