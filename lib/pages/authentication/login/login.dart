import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:pickme_mobile/config/auth/appleService.dart';
import 'package:pickme_mobile/config/auth/googleService.dart';
import 'package:pickme_mobile/config/checkConnection.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/config/sharePreference.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/authentication/otpVerification/otpVerification.dart';
import 'package:pickme_mobile/pages/authentication/signUp/signUp.dart';
import 'package:pickme_mobile/providers/locationProdiver.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/strings.dart';

import 'widget/loginWidget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GoogleService _googleService = new GoogleService();
  final AppleService _appleService = new AppleService();

  final _phoneController = new TextEditingController();
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();

  FocusNode? _emailFocusNode, _passwordFocusNode, _phoneFocusNode;

  bool _isLoading = false, _isRememberMe = false;
  LoginType _loginType = LoginType.phone;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = new FocusNode();
    _passwordFocusNode = new FocusNode();
    _phoneFocusNode = new FocusNode();

    _phoneController.text = "+233 ";
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
  }

  @override
  void dispose() {
    _emailFocusNode!.dispose();
    _passwordFocusNode!.dispose();
    _phoneFocusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _isLoading = false;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            loginWidget(
              context: context,
              emailController: _emailController,
              emailFocusNode: _emailFocusNode,
              onForgotPassword: () => navigation(
                context: context,
                pageName: "forgetPassword",
              ),
              onLogin: () => _onLogin(user: null),
              passwordController: _passwordController,
              passwordFocusNode: _passwordFocusNode,
              key: _formKey,
              onRememberMeCheck: (bool value) => _onRememberMeCheck(value),
              isRememberMe: _isRememberMe,
              onThirdPartyLogin: (int index) => _onThirdPartyLogin(index),
              onSignUp: () => navigation(
                context: context,
                pageName: "signup",
              ),
              onLoginType: (LoginType type) => _onLoginType(type),
              phoneController: _phoneController,
              phoneFocusNode: _phoneFocusNode,
              loginType: _loginType,
            ),
            if (_isLoading) customLoadingPage(),
          ],
        ),
      ),
    );
  }

  void _onLoginType(LoginType type) {
    _loginType = type;
    setState(() {});
  }

  Future<void> _onThirdPartyLogin(int index) async {
    setState(() => _isLoading = true);
    bool connection = await checkConnection();
    if (!connection) {
      setState(() => _isLoading = false);
      toastContainer(text: Strings.noInternet, backgroundColor: BColors.red);
      return;
    }

    User? user;
    if (index == 0) {
      user = await _googleService.googleSignIn();
      setState(() => _isLoading = false);
      if (user == null) {
        toastContainer(
          text: Strings.gmailAccessError,
          backgroundColor: BColors.red,
        );
        return;
      }
    } else {
      user = await _appleService.signInWithApple();
      setState(() => _isLoading = false);
      if (user == null) {
        toastContainer(
          text: "Error access account",
          backgroundColor: BColors.red,
        );
        return;
      }
    }
    _loginType = LoginType.email;
    await _onLogin(user: user);
  }

  void _onRememberMeCheck(bool value) {
    _isRememberMe = value;
    setState(() {});
  }

  Future<void> _onLogin({
    @required User? user,
  }) async {
    _emailFocusNode!.unfocus();
    _passwordFocusNode!.unfocus();
    _phoneFocusNode!.unfocus();

    if (_loginType == LoginType.phone && _phoneController.text.length < 9) {
      toastContainer(
        text: "Phone number invalid",
        backgroundColor: BColors.red,
      );
      return;
    }

    if (user == null && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    await LocationProvider().getCurrentLocation();

    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.auth,
        method: HttpMethod.post,
        httpPostBody: _loginType == LoginType.phone
            ? {
                "action": HttpActions.phoneLogin,
                "phone": _phoneController.text.trim(),
                "signature": "",
              }
            : {
                "action": HttpActions.emailLogin,
                "email": user != null ? user.email : _emailController.text.toLowerCase().trim(),
                "password": user != null ? Properties.defaultPassword : _passwordController.text,
              },
      ),
      showToastMsg: false,
    );
    log("login data $httpResult");
    if (httpResult["ok"]) {
      bool accountExit = httpResult["data"]["data"]["userExists"] != null && httpResult["data"]["data"]["userExists"];

      if (_loginType == LoginType.phone) {
        if (accountExit) {
          String otpCode = httpResult["data"]["data"]["otpCode"];
          saveStringShare(
            key: "userDetails",
            data: json.encode(httpResult["data"]),
          );
          userModel = UserModel.fromJson(httpResult["data"]);

          if (!mounted) return;
          await continueSignUpOnFirebase(
            firebaseUserId: user?.uid,
            userModel: userModel,
            context: context,
          );

          setState(() => _isLoading = false);
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OtpVerification(
                loginType: LoginType.phone,
                phoneEmail: _phoneController.text,
                authNextAction: AuthNextAction.loginPhoneVerifyUserExit,
                otpCode: otpCode,
              ),
            ),
          );
        } else {
          String otpCode = httpResult["data"]["data"]["otpCode"];
          setState(() => _isLoading = false);
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OtpVerification(
                loginType: LoginType.phone,
                phoneEmail: _phoneController.text,
                authNextAction: AuthNextAction.loginPhoneVerifyUserNotExit,
                otpCode: otpCode,
              ),
            ),
          );
        }
      } else {
        saveStringShare(
          key: "userDetails",
          data: json.encode(httpResult["data"]),
        );
        userModel = UserModel.fromJson(httpResult["data"]);

        if (!mounted) return;
        await continueSignUpOnFirebase(
          firebaseUserId: user?.uid,
          userModel: userModel,
          context: context,
        );
        saveBoolShare(key: "auth", data: true);
        Repository repo = new Repository();
        await repo.fetchWorkerInfo(true);
        await repo.fetchAllTrips(true);

        if (!mounted) return;
        navigation(context: context, pageName: "homepage");
      }
    } else {
      setState(() => _isLoading = false);
      try {
        if (httpResult["data"] != null && !httpResult["data"]["data"]["emailVerified"]) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OtpVerification(
                loginType: LoginType.email,
                phoneEmail: _emailController.text,
                authNextAction: AuthNextAction.loginEmailVerify,
              ),
            ),
          );
        } else {
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
      } catch (e) {
        if (user != null) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SignUpPage(user: user),
            ),
          );
          return;
        }
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
}
