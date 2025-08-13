import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/firebase/firebaseUtils.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';

import 'widget/transferMoneyWidget.dart';

class TransferMoney extends StatefulWidget {
  const TransferMoney({super.key});

  @override
  State<TransferMoney> createState() => _TransferMoneyState();
}

class _TransferMoneyState extends State<TransferMoney> {
  final Repository _repo = new Repository();

  final _amountController = new TextEditingController();
  final _recieverIdController = new TextEditingController();

  FocusNode? _amountFocusNode, _recieverIdFocusNode;

  bool _isLoading = false;

  UserModel? _receiverInfo;

  @override
  void initState() {
    super.initState();
    _amountFocusNode = new FocusNode();
    _recieverIdFocusNode = new FocusNode();
    _recieverIdFocusNode!.requestFocus();
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
          transferMoneyWidget(
            context: context,
            amountController: _amountController,
            amountFocusNode: _amountFocusNode!,
            onTransferMoney: () => _onTransferMoney(),
            recieverIdController: _recieverIdController,
            recieverIdFocusNode: _recieverIdFocusNode!,
            onLoadReceiverInfo: () => _onLoadReceiverInfo(),
            receiverInfo: _receiverInfo,
            onChangeReceiver: () => _onChangeReceiver(),
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  void _onChangeReceiver() {
    _receiverInfo = null;
    setState(() {});
  }

  Future<void> _onLoadReceiverInfo() async {
    _recieverIdFocusNode!.unfocus();

    if (_recieverIdController.text.isEmpty) {
      toastContainer(text: "Enter receiver Id", backgroundColor: BColors.red);
      return;
    }

    setState(() => _isLoading = true);
    UserModel? model = await _repo.fetchProfile(userId: _recieverIdController.text);
    setState(() => _isLoading = false);
    if (model == null) {
      toastContainer(text: "Unable to get receiver info, please check ID", backgroundColor: BColors.red);
      return;
    }

    _receiverInfo = model;
    setState(() {});
  }

  Future<void> _onTransferMoney() async {
    _amountFocusNode?.unfocus();

    if (_amountController.text.isEmpty) {
      toastContainer(text: "Enter amount", backgroundColor: BColors.red);
      setState(() {});
      return;
    }

    if (double.parse(_amountController.text) > double.parse(userModel!.data!.user!.walletBalance!)) {
      toastContainer(text: "Insufficient amount, please top up", backgroundColor: BColors.red);
      return;
    }

    setState(() => _isLoading = true);
    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.transferWalletMoney,
          "senderId": userModel!.data!.user!.userid,
          "recipientId": _receiverInfo!.data!.user!.userid,
          "amount": _amountController.text,
        },
      ),
    );

    log("$httpResult");
    if (httpResult["ok"]) {
      await sendNotification(
        _receiverInfo!.data!.user!.firebaseKey!,
        '🚖 Pickme',
        'Payment received ${Properties.curreny} ${_amountController.text}',
         {"page": "wallet"}
      );
      await sendNotification(
        userModel!.data!.user!.firebaseKey!,
        '🚖 Pickme',
        'Transfer of ${Properties.curreny} ${_amountController.text} to ${_receiverInfo!.data!.user!.name}',
        {"page": "wallet"}
      );
      setState(() => _isLoading = false);
      toastContainer(
        text: httpResult["data"]["msg"],
        backgroundColor: BColors.green,
      );

      if (!mounted) return;
      navigation(context: context, pageName: "wallet");
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
