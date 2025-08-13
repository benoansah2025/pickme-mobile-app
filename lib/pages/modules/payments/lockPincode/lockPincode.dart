import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/flutterPincode.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';

import 'widget/lockPincodeWidget.dart';

class LockPincode extends StatefulWidget {
  final bool resetPin;
  final VoidCallback? onSuccess;

  const LockPincode({
    super.key,
    this.resetPin = false,
    this.onSuccess,
  });

  @override
  State<LockPincode> createState() => _LockPincodeState();
}

class _LockPincodeState extends State<LockPincode> {
  final GlobalKey<PinCodeState> _pinCodeKey = GlobalKey<PinCodeState>();
  bool _isResetPin = false, _isLoading = false, _isNormalPinVerified = false;
  String _title = "Enter PIN", _resetPin = "";

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() {
    if (userModel?.data?.user?.paymentPin == Properties.defaultPaymentPin) {
      _isResetPin = true;
      _isNormalPinVerified = true;
      _title = "Set your new PIN";
    } else {
      _isResetPin = widget.resetPin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool invoke) {
        if (invoke) return;
        if (widget.onSuccess == null) {
          navigation(context: context, pageName: "homepage");
        }
      },
      child: Stack(
        children: [
          lockPincodeWidget(
            context: context,
            onPinChange: _onPinChange,
            onFingerPrint: () {},
            pinCodeKey: _pinCodeKey,
            title: _title,
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onPinChange(String pin) async {
    if (pin.length != 4) return;

    if (pin == Properties.defaultPaymentPin) {
      toastContainer(
        text: "Pin is weak, try another pin",
        backgroundColor: BColors.red,
      );
      _pinCodeKey.currentState?.reset();
      return;
    }

    if (_isResetPin) {
      if (!_isNormalPinVerified) {
        // If resetPin is true but normal PIN is not verified, verify it first
        if (await _handleNormalPin(pin)) {
          // Normal PIN is correct; proceed to reset mode
          _isNormalPinVerified = true;
          _title = "Set your new PIN";
          _pinCodeKey.currentState?.reset();
          setState(() {});
        }
      } else {
        _handleResetPin(pin);
      }
    } else {
      _handleNormalPin(pin);
    }
  }

  Future<void> _handleResetPin(String pin) async {
    if (_title == "Confirm PIN") {
      if (_resetPin == pin) {
        setState(() => _isLoading = true);
        Map<String, dynamic> httpResult = await httpChecker(
          httpRequesting: () => httpRequesting(
            endPoint: HttpServices.noEndPoint,
            method: HttpMethod.post,
            httpPostBody: {
              "action": HttpActions.setPincode,
              "userid": userModel!.data!.user!.userid,
              "pin": pin,
            },
          ),
        );

        log("$httpResult");
        if (httpResult["ok"]) {
          await new Repository().fetchProfile();
          setState(() => _isLoading = false);
          toastContainer(
            text: httpResult["data"]["msg"],
            backgroundColor: BColors.green,
          );
          if (!mounted) return;
          navigation(context: context, pageName: "back");
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
      } else {
        _showError("Incorrect PIN not matched...", "Set your new PIN");
      }
    } else {
      _resetPin = pin;
      _title = "Confirm PIN";
      _pinCodeKey.currentState?.reset();
      setState(() {});
    }
  }

  Future<bool> _handleNormalPin(String pin) async {
    setState(() => _isLoading = true);
    userModel = await Repository().fetchProfile();
    setState(() => _isLoading = false);
    
    if (pin == userModel?.data?.user?.paymentPin) {
      if (!_isResetPin) {
        if(!mounted) return false;
        navigation(context: context, pageName: "back");
        if (widget.onSuccess != null) widget.onSuccess!();
      }
      return true;
    } else {
      _showError("Incorrect pin, try again...");
      return false;
    }
  }

  void _showError(String message, [String? newTitle]) {
    _pinCodeKey.currentState?.reset();
    if (newTitle != null) _title = newTitle;
    setState(() {});
    toastContainer(
      text: message,
      backgroundColor: BColors.red,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
