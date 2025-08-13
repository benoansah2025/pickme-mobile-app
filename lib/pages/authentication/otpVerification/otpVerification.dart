import 'dart:async';
import 'dart:developer';

import 'package:otp_autofill/otp_autofill.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/config/sharePreference.dart';
import 'package:pickme_mobile/pages/authentication/login/login.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/pages/authentication/resetPassword/resetPassword.dart';
import 'package:pickme_mobile/pages/authentication/signUp/signUp.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/otpVerificationWidget.dart';

class OtpVerification extends StatefulWidget {
  final LoginType? loginType;
  final String? phoneEmail, otpCode;
  final AuthNextAction? authNextAction;

  const OtpVerification({
    super.key,
    @required this.loginType,
    @required this.phoneEmail,
    @required this.authNextAction,
    this.otpCode,
  });

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  static const int _initialMinutes = 7;
  Duration duration = const Duration(minutes: _initialMinutes);
  Timer? _timer;
  String _remainingTime = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _codeController = new TextEditingController();

  FocusNode? _codeFocusNode;

  bool _isLoading = false;

  late OTPTextEditController controller;
  late OTPInteractor _otpInteractor;

  final _otpController = OtpFieldController();
  String? _verificationOtpCode, _inputOtpCode;

  @override
  void initState() {
    super.initState();
    _verificationOtpCode = widget.otpCode;
    _codeFocusNode = new FocusNode();
    _startTimer();
    _initInteractor();
    controller = OTPTextEditController(
      codeLength: 6,
      onCodeReceive: (code) => _onOtpCodeReceived(code: code),
      otpInteractor: _otpInteractor,
    )..startListenUserConsent(
        (code) {
          final exp = RegExp(r'(\d{6})');
          String ot = exp.stringMatch(code ?? '') ?? '';
          _otpController.set(ot.split(''));
          return ot;
        },
        strategies: [
          // SampleStrategy(),
        ],
      );
  }

  @override
  void dispose() {
    _codeFocusNode!.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          otpVerificationWidget(
            context: context,
            codeController: _codeController,
            codeFocusNode: _codeFocusNode,
            onSubmit: () => _onSubmit(),
            key: _formKey,
            phoneEmail: widget.phoneEmail!,
            remainingTime: _remainingTime,
            onResend: () => _onResend(),
            loginType: widget.loginType!,
            otpController: _otpController,
            onOTPTextChange: (String text) => _onOTPTextChange(text),
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  void _onOTPTextChange(String text) {
    _inputOtpCode = text;
    setState(() {});
  }

  Future<void> _onOtpCodeReceived({String? code}) async {
    debugPrint('Your Application receive code - $code');
    bool match = _inputOtpCode == _verificationOtpCode;
    if (match) {
      if (widget.authNextAction == AuthNextAction.loginPhoneVerifyUserNotExit) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpPage(
                phoneNumber: widget.phoneEmail,
              ),
            ),
            (Route<dynamic> route) => false);
      } else if (widget.authNextAction == AuthNextAction.loginPhoneVerifyUserExit ||
          widget.authNextAction == AuthNextAction.signUpPhoneVerify) {
        setState(() => _isLoading = true);
        saveBoolShare(key: "auth", data: true);

        Repository repo = new Repository();
        await repo.fetchWorkerInfo(true);
        await repo.fetchAllTrips(true);
        // setState(() => _isLoading = false);

        if (!mounted) return;
        navigation(context: context, pageName: "homepage");
      }
    } else {
      toastContainer(
        text: "Invalid verification code",
        backgroundColor: BColors.red,
      );
    }
  }

  Future<void> _initInteractor() async {
    _otpInteractor = OTPInteractor();

    // You can receive your app signature by using this method.
    final appSignature = await _otpInteractor.getAppSignature();

    debugPrint('Your app signature: $appSignature');
  }

  Future<void> _onResend() async {
    _codeFocusNode!.unfocus();
    setState(() => _isLoading = true);
    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.auth,
        method: HttpMethod.post,
        httpPostBody: widget.loginType == LoginType.email
            ? {
                "action": HttpActions.resendEmailVerification,
                "email": widget.phoneEmail,
              }
            : {
                "action": HttpActions.phoneLogin,
                "phone": widget.phoneEmail,
              },
      ),
      showToastMsg: false,
    );
    log("$httpResult");
    if (httpResult["ok"]) {
      setState(() => _isLoading = false);
      if (widget.loginType == LoginType.email) {
        toastContainer(
          text: httpResult["data"]["msg"],
          backgroundColor: BColors.green,
        );
      }
      _resetTimer();
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

  Future<void> _onSubmit() async {
    _codeFocusNode!.unfocus();

    if (widget.loginType == LoginType.phone) {
      _onOtpCodeReceived(code: null);
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Map<String, dynamic> httpResult = await httpChecker(
        httpRequesting: () => httpRequesting(
          endPoint: HttpServices.auth,
          method: HttpMethod.post,
          httpPostBody: {
            "action": widget.authNextAction == AuthNextAction.forgotPasswordVerify
                ? HttpActions.verifyPin
                : HttpActions.verifyEmail,
            "email": widget.phoneEmail,
            "token": _codeController.text,
          },
        ),
        showToastMsg: false,
      );
      log("$httpResult");
      setState(() => _isLoading = false);
      if (httpResult["ok"]) {
        toastContainer(
          text: httpResult["data"]["msg"],
          backgroundColor: BColors.green,
        );
        if (widget.authNextAction == AuthNextAction.loginEmailVerify) {
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              (Route<dynamic> route) => false);
        } else if (widget.authNextAction == AuthNextAction.forgotPasswordVerify) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPassword(
                email: widget.phoneEmail!,
              ),
            ),
          );
        }
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimer());
  }

  void _updateTimer() {
    setState(() {
      final seconds = duration.inSeconds - 1;
      if (seconds < 0) {
        _timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }

      _remainingTime =
          "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}";
    });
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      duration = const Duration(minutes: _initialMinutes);
      _startTimer();
    });
  }
}
