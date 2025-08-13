import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget forgetPasswordWidget({
  @required TextEditingController? emailController,
  @required FocusNode? emailFocusNode,
  @required void Function()? onSubmit,
  @required BuildContext? context,
  @required Key? key,
}) {
  return Container(
    constraints: const BoxConstraints(maxWidth: 500),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    child: SingleChildScrollView(
      child: Form(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text("Forgot Passowrd", style: Styles.h2Black),
            const SizedBox(height: 20),
            Text("Please enter your email address", style: Styles.h6Black),
            const SizedBox(height: 30),
            Text("Email", style: Styles.h6Black),
            const SizedBox(height: 10),
            textFormField(
              hintText: "",
              controller: emailController,
              focusNode: emailFocusNode,
              validateMsg: Strings.requestField,
              inputType: TextInputType.emailAddress,
              validateEmail: true,
            ),
            const SizedBox(height: 20),
            button(
              onPressed: onSubmit,
              text: "Send",
              color: BColors.primaryColor,
              context: context,
            ),
          ],
        ),
      ),
    ),
  );
}
