import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/strings.dart';

Future<Map<String, dynamic>> httpChecker({
  required Future<Map<String, dynamic>> Function()? httpRequesting,
  bool showToastMsg = false,
}) async {
  try {
    final Map<String, dynamic> httpMap = await httpRequesting!();

    if (httpMap["statusCode"] == 0) {
      return _buildErrorResponse(Strings.noInternet, Strings.noInternet);
    } else if (httpMap["statusCode"] >= 100 && httpMap["statusCode"] <= 199) {
      _showToast("${httpMap["statusCode"]}-${httpMap["data"]["msg"]}", showToastMsg);
      return _buildErrorResponse("Information responses");
    } else if (httpMap["statusCode"] >= 200 && httpMap["statusCode"] <= 299) {
      return {
        "ok": httpMap["data"] is Map ? httpMap["data"]["ok"] ?? true : true,
        "statusCode": httpMap["statusCode"],
        "data": httpMap["data"],
        "statusMsg": "Successful responses",
      };
    } else if (httpMap["statusCode"] >= 300 && httpMap["statusCode"] <= 399) {
      _showToast("${httpMap["statusCode"]}-${httpMap["data"]["msg"]}", showToastMsg);
      return _buildErrorResponse("Redirects");
    } else if (httpMap["statusCode"] >= 400 && httpMap["statusCode"] <= 499) {
      _showToast("${httpMap["statusCode"]}-${httpMap["data"]["msg"]}", showToastMsg);
      return {
        "ok": false,
        "statusCode": httpMap["statusCode"],
        "data": httpMap["data"],
        "statusMsg": "Client errors",
        "error": httpMap["data"]["msg"],
      };
    } else {
      _showToast(Strings.requestError, showToastMsg);
      return _buildErrorResponse("Errors", "Internal Error");
    }
  } on TimeoutException catch (error) {
    if (kDebugMode) {
      print(error);
    }
    _showToast(Strings.connectionTImeout, showToastMsg);
    return _buildErrorResponse("Errors", Strings.connectionTImeout);
  } on SocketException catch (error) {
    if (kDebugMode) {
      print(error);
    }
    _showToast(Strings.noInternet, showToastMsg);
    return _buildErrorResponse("Errors", Strings.noInternet);
  } catch (e, stackTrace) {
    if (showToastMsg) {
      toastContainer(text: Strings.requestError, backgroundColor: BColors.red);
    }
    log("Caught unexpected error: $e\nStack trace: $stackTrace");
    FirebaseService().reportErrors(
      e.toString(),
      stackTrace.toString(),
      requestBody: {
        "function": "httpChecker",
      },
    );

    return _buildErrorResponse("Errors", "${Strings.requestError} $e");
  }
}

void _showToast(String message, bool showToastMsg) {
  if (showToastMsg) {
    toastContainer(text: message, backgroundColor: BColors.red);
  }
}

Map<String, dynamic> _buildErrorResponse(String statusMsg, [String? error]) {
  return {
    "ok": false,
    "statusCode": null,
    "data": null,
    "statusMsg": statusMsg,
    "error": error,
  };
}
