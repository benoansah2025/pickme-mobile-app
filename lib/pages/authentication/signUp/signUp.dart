import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:pickme_mobile/config/firebase/firebaseAuth.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/sharePreference.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/authentication/otpVerification/otpVerification.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';

import 'widget/signUpWidget.dart';

class SignUpPage extends StatefulWidget {
  final User? user;
  final String? phoneNumber;

  const SignUpPage({
    super.key,
    this.user,
    this.phoneNumber,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _phoneController = new TextEditingController();
  final _fullNameController = new TextEditingController();
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _confirmPasswordController = new TextEditingController();

  FocusNode? _fullNameFocusNode, _emailFocusNode, _passwordFocusNode, _confirmPasswordFocusNode, _phoneFocusNode;

  bool _isLoading = false;

  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = new FocusNode();
    _passwordFocusNode = new FocusNode();
    _fullNameFocusNode = new FocusNode();
    _confirmPasswordFocusNode = new FocusNode();
    _phoneFocusNode = new FocusNode();

    _phoneController.text = "+233 ";
    if (widget.phoneNumber == null) {
      _phoneController.addListener(() {
        if (!_phoneController.text.startsWith("+233 ")) {
          // Store the current text length
          final previousTextLength = _phoneController.text.length;
          // Update the text to start with "+233 "
          _phoneController.value = const TextEditingValue(
            text: "+233 ",
            // Ensure the cursor is placed at the end of the text
            selection: TextSelection.collapsed(offset: 5),
          );
          // Move the cursor to the end of the previous text, if any
          if (previousTextLength > 5) {
            _phoneController.selection = TextSelection.collapsed(offset: previousTextLength);
          }
        }
      });
    } else {
      _phoneController.text = widget.phoneNumber!;
    }

    if (widget.user != null) {
      _emailController.text = "${widget.user!.email}";
      _fullNameController.text = "${widget.user!.displayName}";
      _phoneController.text = "${widget.user!.phoneNumber}";
      _photoUrl = widget.user!.photoURL;
      _passwordController.text = Properties.defaultPassword;
      _confirmPasswordController.text = Properties.defaultPassword;
    }
  }

  @override
  void dispose() {
    _emailFocusNode!.dispose();
    _passwordFocusNode!.dispose();
    _fullNameFocusNode!.dispose();
    _confirmPasswordFocusNode!.dispose();
    _phoneFocusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _isLoading = false;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              signUpWidget(
                context: context,
                emailController: _emailController,
                emailFocusNode: _emailFocusNode,
                onLogin: () => navigation(
                  context: context,
                  pageName: "login",
                ),
                passwordController: _passwordController,
                passwordFocusNode: _passwordFocusNode,
                key: _formKey,
                onSignUp: () => _onSignUp(),
                fullNameController: _fullNameController,
                confirmPasswordController: _confirmPasswordController,
                fullNameFocusNode: _fullNameFocusNode,
                confirmPasswordFocusNode: _confirmPasswordFocusNode,
                phoneController: _phoneController,
                phoneFocusNode: _phoneFocusNode,
                user: widget.user,
                enablePhone: widget.phoneNumber == null,
              ),
              if (_isLoading) customLoadingPage(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSignUp() async {
    _emailFocusNode!.unfocus();
    _passwordFocusNode!.unfocus();
    _fullNameFocusNode!.unfocus();
    _confirmPasswordFocusNode!.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_phoneController.text.length < 9) {
      toastContainer(
        text: "Phone number invalid",
        backgroundColor: BColors.red,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      toastContainer(
        text: "Password not match",
        backgroundColor: BColors.red,
      );
      return;
    }

    setState(() => _isLoading = true);
    FireAuth firebaseAuth = new FireAuth();
    String? token = await firebaseAuth.getToken();

    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.auth,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.register, //required
          "name": _fullNameController.text,
          "phone": _phoneController.text.trim(), //required
          "email": _emailController.text.toLowerCase().trim(),
          "dob": "",
          "gender": "",
          "picture": _photoUrl ?? "",
          "payment_pin": Properties.defaultPaymentPin,
          "password": _passwordController.text, //required
          "password_confirmation": _confirmPasswordController.text, //required
          "firebaseKey": token ?? "",
          "email_verified": widget.user != null || widget.phoneNumber != null ? "YES" : "NO", // YES/NO
        },
      ),
      showToastMsg: false,
    );
    log("login data $httpResult");
    if (httpResult["ok"]) {
      saveStringShare(
        key: "userDetails",
        data: json.encode(httpResult["data"]),
      );
      userModel = UserModel.fromJson(httpResult["data"]);

      // user used either google or apple sign in
      if (widget.user != null) {
        setState(() => _isLoading = false);
        saveBoolShare(key: "auth", data: true);
        if (!mounted) return;
        navigation(context: context, pageName: "homepage");
      }

      // user have already confirm phone number otp
      if (widget.phoneNumber != null) {
        if (!mounted) return;
        await continueSignUpOnFirebase(
          firebaseUserId: null,
          userModel: userModel,
          context: context,
        );
        setState(() => _isLoading = false);
        saveBoolShare(key: "auth", data: true);
        if (!mounted) return;
        navigation(context: context, pageName: "homepage");
      }

      if (!mounted) return;
      String otpCode = httpResult["data"]["data"]["otpCode"];
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => OtpVerification(
              loginType: LoginType.phone,
              phoneEmail: _phoneController.text,
              authNextAction: AuthNextAction.signUpPhoneVerify,
              otpCode: otpCode,
            ),
          ),
          (Route<dynamic> route) => false);
    } else {
      setState(() => _isLoading = false);
      httpResult["statusCode"] == 200
          ? toastContainer(
              text: httpResult["data"]["msg"],
              backgroundColor: BColors.red,
            )
          : toastContainer(
              text: httpResult["error"],
              backgroundColor: BColors.red,
            );
    }
  }
}
