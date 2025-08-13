import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/businessListingsModel.dart';
import 'package:pickme_mobile/models/subscriptionsModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/modules/vendors/addVendor/widget/subscriptionInfoDialog.dart';
import 'package:pickme_mobile/pages/modules/vendors/addVendor/widget/vendorSubscriptionWidget.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/utils/webBrower.dart';

class RenewSubscription extends StatefulWidget {
  final ListingDetails data;

  const RenewSubscription({super.key, required this.data});

  @override
  State<RenewSubscription> createState() => _RenewSubscriptionState();
}

class _RenewSubscriptionState extends State<RenewSubscription> {
  final _repo = new Repository();

  final _codeController = new TextEditingController();

  final _codeFocusNode = FocusNode();

  bool _isLoading = false;

  SubscriptionData? _selectedSubscription;

  String _paymentType = "";

  @override
  void initState() {
    super.initState();
    _repo.fetchSubscriptions(true);
  }

  @override
  dispose() {
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          vendorSubscriptionWidget(
            context: context,
            scrollController: null,
            onSubscriptionInfo: (SubscriptionData data) => _onSubscriptionInfo(data),
            onSubscription: (SubscriptionData data) => _onSubscription(data),
            selectedSubscription: _selectedSubscription,
            paymentType: _paymentType,
            onPaymentType: (String type) {
              _paymentType = type;
              setState(() {});
            },
            codeController: _codeController,
            codeFocusNode: _codeFocusNode,
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
      bottomNavigationBar: !_isLoading
          ? Padding(
              padding: EdgeInsets.all(10),
              child: button(
                onPressed: () => _onRenewSubscription(),
                text: "Make Payment",
                color: BColors.primaryColor,
                context: context,
              ),
            )
          : null,
    );
  }

  Future<void> _onRenewSubscription() async {
    _codeFocusNode.unfocus();

    if (_selectedSubscription == null) {
      toastContainer(text: "Please select a subscription plan", backgroundColor: BColors.red);
      return;
    }

    if (_paymentType.isEmpty) {
      toastContainer(text: "Please select a payment type", backgroundColor: BColors.red);
      return;
    }

    if (_paymentType == "wallet" && _codeController.text.isEmpty) {
      toastContainer(text: "Please enter a code", backgroundColor: BColors.red);
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.noEndPoint,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.renewBusinessListings,
          "userid": userModel!.data!.user!.userid,
          "subscriptionId": _selectedSubscription?.id,
          "listingId": widget.data.businessId,
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
            previousPage: "renewSubscription",
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

  void _onSubscriptionInfo(SubscriptionData data) {
    showDialog(
      context: context,
      builder: (context) => subscriptionInfoDialog(context: context, data: data),
    );
  }

  void _onSubscription(SubscriptionData data) => setState(() => _selectedSubscription = data);
}
