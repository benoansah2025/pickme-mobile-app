import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget otpVerificationWidget({
  @required TextEditingController? codeController,
  @required FocusNode? codeFocusNode,
  @required void Function()? onSubmit,
  @required void Function()? onResend,
  required void Function(String text) onOTPTextChange,
  required BuildContext context,
  @required Key? key,
  required String phoneEmail,
  required String remainingTime,
  required LoginType loginType,
  required OtpFieldController otpController,
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
            Text("OTP CONFIRMATION", style: Styles.h2Black),
            const SizedBox(height: 20),
            Text(
              "Please enter the code sent to \n$phoneEmail",
              style: Styles.h6Black,
            ),
            const SizedBox(height: 30),
            Text("Verification code", style: Styles.h6Black),
            const SizedBox(height: 10),
            if (loginType == LoginType.email)
              textFormField(
                hintText: "Enter email verification code",
                controller: codeController,
                focusNode: codeFocusNode,
                validateMsg: Strings.requestField,
              ),
            if (loginType == LoginType.phone)
              OTPTextField(
                controller: otpController,
                length: 6,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldWidth: 45,
                fieldStyle: FieldStyle.box,
                outlineBorderRadius: 15,
                style: const TextStyle(fontSize: 17),
                onChanged: (String text) => onOTPTextChange(text),
                onCompleted: (String text) => onOTPTextChange(text),
              ),
            const SizedBox(height: 30),
            Center(
              child: RichText(
                text: TextSpan(
                  text: "Your code will expire in ",
                  style: Styles.h6Black,
                  children: [
                    TextSpan(text: remainingTime, style: Styles.h6BlackBold),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            button(
              onPressed: onSubmit,
              text: "Send",
              color: BColors.primaryColor,
              context: context,
            ),
            const SizedBox(height: 30),
            Center(
              child: Text("Didn't receive a code? ", style: Styles.h6Black),
            ),
            const SizedBox(height: 10),
            button(
              onPressed: onResend,
              text: "Resend Code",
              color: BColors.white,
              context: context,
              textColor: BColors.black,
              showBorder: false,
              textStyle: Styles.h5BlackBoldUnderline,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}
