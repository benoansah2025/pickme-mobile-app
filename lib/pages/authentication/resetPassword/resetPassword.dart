import 'dart:developer';

import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/resetPassWidget.dart';

class ResetPassword extends StatefulWidget {
  final String email;

  const ResetPassword({
    super.key,
    required this.email,
  });

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final passwordController = new TextEditingController();
  final confirmPasswordController = new TextEditingController();

  FocusNode? passwordFocusNode, confirmNewPasswordFocusNode;

  @override
  void initState() {
    super.initState();
    passwordFocusNode = new FocusNode();
    confirmNewPasswordFocusNode = new FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          passwordResetWidget(
            context: context,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            onSubmit: () => _onSubmit(),
            key: _formKey,
            confirmPasswordFocusNode: confirmNewPasswordFocusNode,
            passwordFocusNode: passwordFocusNode,
          ),
          if (_isLoading) customLoadingPage()
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (confirmPasswordController.text != passwordController.text) {
      toastContainer(
        text: "Passwords do not match",
        backgroundColor: BColors.red,
      );
      return;
    }

    setState(() => _isLoading = true);
    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.auth,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.resetPassword,
          'email': widget.email,
          'password': passwordController.text,
          'password_confirmation': confirmPasswordController.text,
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
      navigation(context: context, pageName: "login");
    } else {
      setState(() => _isLoading = false);
      httpResult["statusCode"] == 200
          ? toastContainer(
              text: httpResult["data"]["msg"],
              backgroundColor: BColors.red,
            )
          : toastContainer(text: httpResult["error"], backgroundColor: BColors.red);
    }
  }
}
