import 'dart:developer';

import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/pages/authentication/otpVerification/otpVerification.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/forgetPasswordWidget.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailController = new TextEditingController();

  FocusNode? _emailFocusNode;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = new FocusNode();
  }

  @override
  void dispose() {
    _emailFocusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          forgetPasswordWidget(
            context: context,
            emailController: _emailController,
            emailFocusNode: _emailFocusNode,
            onSubmit: () => _onSubmit(),
            key: _formKey,
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    _emailFocusNode!.unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Map<String, dynamic> httpResult = await httpChecker(
        httpRequesting: () => httpRequesting(
          endPoint: HttpServices.auth,
          method: HttpMethod.post,
          httpPostBody: {
            "action": HttpActions.forgotPassword,
            "email": _emailController.text,
          },
        ),
        showToastMsg: false,
      );
      log("$httpResult");
      if (httpResult["ok"]) {
        setState(() => _isLoading = false);
        toastContainer(
          text: httpResult["data"]["msg"],
          backgroundColor: BColors.green,
        );
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerification(
              loginType: LoginType.email,
              phoneEmail: _emailController.text,
              authNextAction: AuthNextAction.forgotPasswordVerify,
            ),
          ),
        );
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
}
