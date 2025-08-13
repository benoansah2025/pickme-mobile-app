import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/passwordField.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget loginWidget({
  @required TextEditingController? phoneController,
  @required TextEditingController? emailController,
  @required TextEditingController? passwordController,
  @required FocusNode? phoneFocusNode,
  @required FocusNode? emailFocusNode,
  @required FocusNode? passwordFocusNode,
  @required void Function()? onLogin,
  @required void Function(LoginType type)? onLoginType,
  @required void Function()? onSignUp,
  @required void Function()? onForgotPassword,
  @required void Function(bool value)? onRememberMeCheck,
  @required void Function(int index)? onThirdPartyLogin,
  @required bool? isRememberMe,
  @required BuildContext? context,
  @required Key? key,
  required LoginType loginType,
}) {
  List<String> thirdPartyIcons = [
    Images.google,
    Images.apple,
  ];

  return Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      constraints: const BoxConstraints(maxWidth: 500),
      child: SingleChildScrollView(
        child: Form(
          key: key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Text("Hiii", style: Styles.h2Black),
                  const SizedBox(width: 10),
                  Image.asset(Images.hand),
                ],
              ),
              Text("you're welcome", style: Styles.h2Black),
              SizedBox(height: loginType == LoginType.phone ? 40 : 20),
              Row(
                children: [
                  IconButton(
                    onPressed: () => onLoginType!(LoginType.email),
                    icon: const Icon(Icons.email_outlined),
                    color: loginType == LoginType.email ? BColors.black : BColors.assDeep,
                  ),
                  Container(
                    width: 2,
                    height: 20,
                    color: BColors.assDeep,
                  ),
                  IconButton(
                    onPressed: () => onLoginType!(LoginType.phone),
                    icon: const Icon(Icons.phone_android_sharp),
                    color: loginType == LoginType.phone ? BColors.black : BColors.assDeep,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Sign in with ${loginType == LoginType.phone ? 'mobile number' : 'email'}",
                    style: Styles.h5BlackBold,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(loginType == LoginType.phone ? "Phone" : "Email", style: Styles.h6Black),
              const SizedBox(height: 10),
              if (loginType == LoginType.phone)
                textFormField(
                  hintText: "",
                  controller: phoneController,
                  focusNode: phoneFocusNode,
                  validateMsg: Strings.requestField,
                  inputType: TextInputType.phone,
                ),
              if (loginType == LoginType.email) ...[
                textFormField(
                  hintText: "Email (eg. example@mail.com) ",
                  controller: emailController,
                  focusNode: emailFocusNode,
                  validateMsg: Strings.requestField,
                  validateEmail: true,
                ),
                const SizedBox(height: 20),
                Text("Password", style: Styles.h6Black),
                const SizedBox(height: 10),
                PasswordField(
                  hintText: "Enter your password",
                  controller: passwordController,
                  validateMsg: Strings.requestField,
                  focusNode: passwordFocusNode,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: button(
                    onPressed: onForgotPassword,
                    text: "Forgot password?",
                    color: BColors.white,
                    context: context,
                    useWidth: false,
                    textColor: BColors.black,
                    textStyle: Styles.h6BlackBold,
                  ),
                ),
              ],
              SizedBox(height: loginType == LoginType.phone ? 40 : 20),
              button(
                onPressed: onLogin,
                text: "Log In",
                color: BColors.primaryColor,
                context: context,
              ),
              SizedBox(height: loginType == LoginType.phone ? 40 : 20),
              Center(child: Text("or continue with", style: Styles.h6Black)),
              const SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int x = 0; x < thirdPartyIcons.length; ++x)
                      button(
                        onPressed: () => onThirdPartyLogin!(x),
                        text: "Sign in with ${x == 0 ? 'Google' : 'Apple'}",
                        color: BColors.black,
                        context: context,
                        useWidth: false,
                        textStyle: Styles.h6BlackBold,
                        colorFill: false,
                        textColor: BColors.black,
                        icon: Image.asset(thirdPartyIcons[x], width: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Don't have an account? ", style: Styles.h6Black),
                    button(
                      onPressed: onSignUp,
                      text: "Create one",
                      color: BColors.white,
                      context: context,
                      useWidth: false,
                      textColor: BColors.primaryColor1,
                      textStyle: Styles.h5BlackBold,
                      padding: const EdgeInsets.all(3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}
