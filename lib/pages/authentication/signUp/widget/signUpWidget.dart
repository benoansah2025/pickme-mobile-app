import 'package:firebase_auth/firebase_auth.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/passwordField.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget signUpWidget({
  @required TextEditingController? fullNameController,
  @required TextEditingController? emailController,
  @required TextEditingController? passwordController,
  @required TextEditingController? confirmPasswordController,
  @required TextEditingController? phoneController,
  @required FocusNode? fullNameFocusNode,
  @required FocusNode? phoneFocusNode,
  @required FocusNode? emailFocusNode,
  @required FocusNode? confirmPasswordFocusNode,
  @required FocusNode? passwordFocusNode,
  @required void Function()? onLogin,
  @required void Function()? onSignUp,
  @required BuildContext? context,
  @required Key? key,
  required User? user,
  required bool enablePhone,
}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    constraints: const BoxConstraints(maxWidth: 500),
    child: SingleChildScrollView(
      child: Form(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text("Create your personal account", style: Styles.h3BlackBold),
            const SizedBox(height: 30),
            Text("Full name", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Enter your full name",
              controller: fullNameController,
              focusNode: fullNameFocusNode,
              validateMsg: Strings.requestField,
              inputType: TextInputType.name,
            ),
            const SizedBox(height: 20),
            Text("Email", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "Email (eg. example@mail.com) ",
              controller: emailController,
              focusNode: emailFocusNode,
              validateMsg: Strings.requestField,
              validateEmail: false,
              validate: false,
              enable: user == null,
              inputType: TextInputType.emailAddress,
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
              enable: enablePhone,
            ),
            const SizedBox(height: 20),
            if (user == null) ...[
              Text("Password", style: Styles.h6Black),
              const SizedBox(height: 10),
              PasswordField(
                hintText: "Enter your password",
                controller: passwordController,
                validateMsg: Strings.requestField,
                focusNode: passwordFocusNode,
              ),
              const SizedBox(height: 20),
              Text("Confirm Password", style: Styles.h6Black),
              const SizedBox(height: 10),
              PasswordField(
                hintText: "Re-enter your password",
                controller: confirmPasswordController,
                validateMsg: Strings.requestField,
                focusNode: confirmPasswordFocusNode,
              ),
              const SizedBox(height: 20),
            ],
            button(
              onPressed: onSignUp,
              text: "Sign Up",
              color: BColors.primaryColor,
              context: context,
            ),
            const SizedBox(height: 20),
            if (user == null) ...[
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Already have an account? ", style: Styles.h6Black),
                    button(
                      onPressed: onLogin,
                      text: "Sign in",
                      color: BColors.white,
                      context: context,
                      useWidth: false,
                      textColor: BColors.black,
                      textStyle: Styles.h6BlackBold,
                      padding: const EdgeInsets.all(3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    ),
  );
}
