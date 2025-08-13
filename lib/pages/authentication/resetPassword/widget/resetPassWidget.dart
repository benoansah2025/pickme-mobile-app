import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/passwordField.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget passwordResetWidget({
  @required BuildContext? context,
  @required TextEditingController? passwordController,
  @required TextEditingController? confirmPasswordController,
  @required FocusNode? passwordFocusNode,
  @required FocusNode? confirmPasswordFocusNode,
  @required void Function()? onSubmit,
  @required Key? key,
}) {
  return SingleChildScrollView(
    child: Container(
      padding: const EdgeInsets.only(left: 20.0, top: 20, right: 20),
      constraints: const BoxConstraints(maxWidth: 500),
      child: Form(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Text("RESET PASSWORD", style: Styles.h2Black),
            const SizedBox(height: 20),
            Text(
              "Create a new password to continue",
              style: Styles.h6Black,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text("Password", style: Styles.h6Black),
            const SizedBox(height: 10),
            PasswordField(
              controller: passwordController,
              hintText: "Enter your password",
              validateMsg: "Enter new password",
              focusNode: passwordFocusNode,
            ),
            const SizedBox(height: 20),
            Text("Confirm Password", style: Styles.h6Black),
            const SizedBox(height: 10),
            PasswordField(
              controller: confirmPasswordController,
              hintText: "Re-enter your password",
              validateMsg: "Confirm password",
              focusNode: confirmPasswordFocusNode,
            ),
            const SizedBox(height: 40),
            button(
              onPressed: onSubmit,
              text: "Continue",
              color: BColors.primaryColor,
              context: context,
            ),
          ],
        ),
      ),
    ),
  );
}
