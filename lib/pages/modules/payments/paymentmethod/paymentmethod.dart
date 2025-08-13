import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/pages/modules/payments/walletPayRide/walletPayRide.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/paymentmethodWidget.dart';

class Paymentmethod extends StatefulWidget {
  final ServicePurpose purpose;
  final Map<dynamic, dynamic>? deliveryAddresses;
  final Map<String, dynamic>? paymentMethod;

  const Paymentmethod({
    super.key,
    this.purpose = ServicePurpose.ride,
    this.deliveryAddresses,
    this.paymentMethod,
  });

  @override
  State<Paymentmethod> createState() => _PaymentmethodState();
}

class _PaymentmethodState extends State<Paymentmethod> {
  final _promoCodeController = new TextEditingController();
  final _promoCodeFocusNode = new FocusNode();

  String _method = "cash";
  Map<dynamic, dynamic> _paymentMethod = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.paymentMethod != null) {
      _paymentMethod = widget.paymentMethod!;
      _method = _paymentMethod["paymentMethod"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          paymentmethodWidget(
            context: context,
            promoCodeController: _promoCodeController,
            promoCodeFocusNode: _promoCodeFocusNode,
            onApplyPromo: () => _onAppyPromo(),
            onDone: () => _onDone(),
            purpose: widget.purpose,
            onPaymentMethod: (String method) => _onPaymentMethod(method),
            method: _method.toLowerCase(),
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onAppyPromo() async {
    _promoCodeFocusNode.unfocus();

    if (_promoCodeController.text.isEmpty) {
      toastContainer(text: "Enter code to proceed", backgroundColor: BColors.red);
      return;
    }

    setState(() => _isLoading = true);
    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.applyDiscount,
          "promoCode": _promoCodeController.text,
        },
      ),
    );

    log("$httpResult");
    if (httpResult["ok"]) {
      setState(() => _isLoading = false);
      toastContainer(
        text: httpResult["data"]["msg"] ?? "Success",
        backgroundColor: BColors.green,
      );

      _paymentMethod = {
        "paymentMethod": _method.toUpperCase(),
        "promoCode": _promoCodeController.text,
        "discountPercentage": httpResult["data"]["data"]["percentage"],
      };
      if (!mounted) return;
      Navigator.pop(context, _paymentMethod);
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
      return;
    }
  }

  void _onPaymentMethod(String method) {
    _method = method;
    setState(() {});
  }

  void _onDone() {
    if (widget.purpose == ServicePurpose.ride) {
      _paymentMethod = {
        "paymentMethod": _method.toUpperCase(),
        "promoCode": _promoCodeController.text,
        "discountPercentage": widget.paymentMethod?["discountPercentage"] ?? "",
      };
      Navigator.pop(context, _paymentMethod);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WalletPayRide(
            purpose: widget.purpose,
            deliveryAddresses: widget.deliveryAddresses,
          ),
        ),
      );
    }
  }
}
