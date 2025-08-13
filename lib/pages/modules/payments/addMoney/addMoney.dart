import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/utils/webBrower.dart';

import 'widget/addMoneyWidget.dart';

class AddMoney extends StatefulWidget {
  const AddMoney({super.key});

  @override
  State<AddMoney> createState() => _AddMoneyState();
}

class _AddMoneyState extends State<AddMoney> {
  final _amountController = new TextEditingController();
  FocusNode? _amountFocusNode;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountFocusNode = new FocusNode();
    _amountFocusNode!.requestFocus();
  }

  @override
  void dispose() {
    _amountFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          addMoneyWidget(
            context: context,
            amountController: _amountController,
            amountFocusNode: _amountFocusNode!,
            onContinue: () => _onContinue(),
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onContinue() async {
    _amountFocusNode?.unfocus();

    if (_amountController.text.isEmpty) {
      toastContainer(text: "Enter amount", backgroundColor: BColors.red);
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.loadWallet,
          "userid": userModel!.data!.user!.userid,
          "amount": _amountController.text,
        },
      ),
    );

    log("$httpResult");
    if (httpResult["ok"]) {
      setState(() => _isLoading = false);
      String paymentUrl = httpResult["data"]["data"]["authorization_url"];

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebBrowser(
            previousPage: "addmoney",
            url: paymentUrl,
            title: "Make Payment",
            meta: {
              "payment": true,
              "reference": httpResult["data"]["data"]["reference"],
            },
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
