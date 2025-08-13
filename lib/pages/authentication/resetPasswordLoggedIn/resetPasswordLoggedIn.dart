import 'dart:developer';

import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/resetPasswordLoggedInWidget.dart';

class ResetPasswordLoggedIn extends StatefulWidget {
  const ResetPasswordLoggedIn({super.key});

  @override
  State<ResetPasswordLoggedIn> createState() => _ResetPasswordLoggedInState();
}

class _ResetPasswordLoggedInState extends State<ResetPasswordLoggedIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _currentPasswordController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _confirmPasswordController = new TextEditingController();

  FocusNode? _passwordFocusNode, _confirmNewPasswordFocusNode, _currentPasswordFocusNode;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = new FocusNode();
    _confirmNewPasswordFocusNode = new FocusNode();
    _currentPasswordFocusNode = new FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          resetPasswordLoggedInWidget(
            context: context,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            onSubmit: () => _onSubmit(),
            key: _formKey,
            confirmPasswordFocusNode: _confirmNewPasswordFocusNode,
            passwordFocusNode: _passwordFocusNode,
            currentPasswordController: _currentPasswordController,
            currentPasswordFocusNode: _currentPasswordFocusNode,
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

    if (_confirmPasswordController.text != _passwordController.text) {
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
          "action": HttpActions.passwordReset,
          'email': userModel!.data!.user!.email,
          'current_password': _confirmPasswordController.text,
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
        },
      ),
      showToastMsg: false,
    );
    log("$httpResult");
    if (httpResult["ok"]) {
      Repository repo = new Repository();
      await repo.fetchWorkerInfo(true);
      await repo.fetchWorkerInfo(true);
      setState(() => _isLoading = false);

      toastContainer(text: httpResult["data"]["msg"], backgroundColor: BColors.green);
      if (!mounted) return;
      navigation(context: context, pageName: "homepage");
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
