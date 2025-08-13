import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/salesSummaryModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/utils/webBrower.dart';

import 'widget/walletPaySalesWidget.dart';

class WalletPaySales extends StatefulWidget {
  final SalesSummaryData? salesSummaryData;
  final String? paymentEndTime;

  const WalletPaySales({
    super.key,
    required this.salesSummaryData,
    required this.paymentEndTime,
  });

  @override
  State<WalletPaySales> createState() => _WalletPaySalesState();
}

class _WalletPaySalesState extends State<WalletPaySales> {
  final Repository _repo = new Repository();

  final _codeController = new TextEditingController();
  final _benController = new TextEditingController();

  final _codeFocusNode = new FocusNode();
  final _benFocusNode = new FocusNode();

  String _paymentType = "";

  bool _isLoading = false, _isPayForOthers = false;

  WorkersInfoModel? _beneficialInfo;
  SalesSummaryData? _salesSummaryData;

  @override
  void initState() {
    super.initState();
    _repo.fetchWalletBalance(true);

    _salesSummaryData = widget.salesSummaryData;
    if (widget.salesSummaryData == null) _isPayForOthers = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          walletPaySalesWidget(
            context: context,
            onPayment: () => _onPayment(),
            codeController: _codeController,
            codeFocusNode: _codeFocusNode,
            data: _salesSummaryData,
            paymentType: _paymentType,
            onPaymentType: (String type) {
              _paymentType = type;
              _codeController.clear();
              setState(() {});
            },
            onPaymentForOthers: () => _onPaymentForOthers(),
            benController: _benController,
            benFocusNode: _benFocusNode,
            isPayForOthers: _isPayForOthers,
            onBeneficialInfo: () => _onLoadBeneficialInfo(),
            beneficialInfo: _beneficialInfo,
            onChangeBeneficial: () {
              _beneficialInfo = null;
              _benController.clear();
              setState(() {});
              _benFocusNode.requestFocus();
            },
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  void _onPaymentForOthers() {
    _isPayForOthers = !_isPayForOthers;
    _beneficialInfo = null;
    // _salesSummaryData = null;
    _benController.clear();

    if (_isPayForOthers) {
      toastContainer(text: "Enter beneficiary phone number");
      _benFocusNode.requestFocus();
    } else {
      _salesSummaryData = widget.salesSummaryData;
      _benFocusNode.unfocus();
      _codeFocusNode.unfocus();
    }
    setState(() {});
  }

  Future<void> _onLoadBeneficialInfo() async {
    _benFocusNode.unfocus();

    if (_benController.text.isEmpty) {
      toastContainer(text: "Enter beneficial  phone number", backgroundColor: BColors.red);
      return;
    }

    setState(() => _isLoading = true);
    WorkersInfoModel model = await WorkersInfoProvider().fetch(userId: _benController.text);
    setState(() => _isLoading = false);
    if (model.data == null) {
      toastContainer(text: "Unable to get receiver info, please check ID", backgroundColor: BColors.red);
      return;
    }

    _beneficialInfo = model;
    setState(() {});
  }

  Future<void> _onPayment() async {
    _codeFocusNode.unfocus();
    _benFocusNode.unfocus();

    if (_paymentType.isEmpty) {
      toastContainer(text: "Please select payment method", backgroundColor: BColors.red);
      return;
    }

    if (_paymentType == "wallet" && _codeController.text.isEmpty) {
      toastContainer(text: "Please enter your wallet pin code", backgroundColor: BColors.red);
      return;
    }

    if (_isPayForOthers && _benController.text.isEmpty) {
      toastContainer(text: "Please enter Phone number", backgroundColor: BColors.red);
      return;
    }

    final now = DateTime.now();
    final endTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(widget.paymentEndTime!.split(":")[0]),
      int.parse(widget.paymentEndTime!.split(":")[1]),
      int.parse(widget.paymentEndTime!.split(":")[2]),
    );

    if (!now.isBefore(endTime)) {
      infoDialog(
        context: context,
        type: PanaraDialogType.error,
        text: "Sales payment period has ended!, visit ${Properties.titleShort} office for payment",
        confirmBtnText: "Ok",
      );
      return;
    }

    setState(() => _isLoading = true);
    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.paySales,
          "userid": userModel!.data!.user!.userid,
          "beneficiaryId": _isPayForOthers ? _benController.text : userModel!.data!.user!.userid,
          "pin": _codeController.text,
          "paymentMethod": _paymentType.toUpperCase(),
        },
      ),
    );

    log("$httpResult");
    if (httpResult["ok"]) {
      if (_paymentType == "wallet") {
        toastContainer(
          text: httpResult["data"]["msg"],
          backgroundColor: BColors.green,
        );
        await Repository().fetchSalesSummary(true);
        if (!mounted) return;
        navigation(context: context, pageName: "homepage");
        return;
      }

      String paymentUrl = httpResult["data"]["data"]["authorization_url"];
      setState(() => _isLoading = false);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebBrowser(
            previousPage: "walletPaySales",
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
      if (!mounted) return;
      setState(() => _isLoading = false);
      infoDialog(
        context: context,
        type: PanaraDialogType.error,
        text: httpResult["statusCode"] == 200 ? httpResult["data"]["msg"] : httpResult["error"],
        confirmBtnText: "Ok",
      );
    }
  }
}
