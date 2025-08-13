import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/modules/worker/workerApplication/registrationPersonalDetails/registrationPersonalDetails.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/registrationEntryCodeWidget.dart';

class RegistrationEntryCode extends StatefulWidget {
  final List<Map<String, dynamic>> serviceList;
  const RegistrationEntryCode({
    super.key,
    required this.serviceList,
  });

  @override
  State<RegistrationEntryCode> createState() => _RegistrationEntryCodeState();
}

class _RegistrationEntryCodeState extends State<RegistrationEntryCode> {
  final _codeController = new TextEditingController();
  final _codeFocusNode = new FocusNode();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          registrationEntryCodeWidget(
            context: context,
            onSend: () => _onSend(),
            codeController: _codeController,
            codeFocusNode: _codeFocusNode,
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onSend() async {
    _codeFocusNode.unfocus();

    String code = _codeController.text.trim();
    if (code.isEmpty) {
      toastContainer(
        text: "Enter entry code",
        backgroundColor: BColors.red,
      );
      return;
    }

    setState(() => _isLoading = true);
    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.checkEntryCode,
          "userid": userModel!.data!.user!.userid,
          "code": _codeController.text,
        },
      ),
      showToastMsg: false,
    );
    log("$httpResult");
    if (httpResult["ok"]) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegistrationPersonalDetails(
            serviceList: widget.serviceList,
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
