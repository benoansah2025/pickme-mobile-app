import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/models/userModel.dart';

import 'httpServices.dart';

enum HttpMethod { post, get }

Future<Map<String, dynamic>> httpRequesting({
  required String endPoint,
  required HttpMethod method,
  Map<String, dynamic>? httpPostBody,
  Map<String, dynamic>? queryParameters,
  bool showLog = false,
}) async {
  final authToken = userModel?.data?.authToken;
  final headers = authToken != null ? {"Authorization": "Bearer $authToken"} : null;

  if (kDebugMode) {
    print("${HttpServices.base}${HttpServices.subbase}$endPoint");
    log("=>body ${jsonEncode(httpPostBody)}");
  }

  try {
    Uri uri = Uri.https(
      HttpServices.base,
      "${HttpServices.subbase}$endPoint",
      queryParameters,
    );

    final response = method == HttpMethod.get
        ? await http.get(uri, headers: headers).timeout(const Duration(seconds: 30))
        : await http.post(uri, headers: headers, body: httpPostBody).timeout(const Duration(seconds: 30));

    if (showLog) log("body => ${response.body}");

    try {
      final responseData = json.decode(response.body);
      return {
        "statusCode": response.statusCode,
        "data": responseData,
        "url": "${HttpServices.base}${HttpServices.subbase}$endPoint",
      };
    } on FormatException catch (e, stackTrace) {
      FirebaseService().reportErrors(
        e.toString(),
        stackTrace.toString(),
        requestBody: {
          ...httpPostBody ?? {},
          "function": "httpRequester FormatException",
        },
        url: "${HttpServices.base}${HttpServices.subbase}$endPoint",
      );
      return {
        "statusCode": response.statusCode,
        "data": null,
        "url": "${HttpServices.base}${HttpServices.subbase}$endPoint",
        "error": e.toString(),
      };
    }
  } catch (e, stackTrace) {
    FirebaseService().reportErrors(
      e.toString(),
      stackTrace.toString(),
      requestBody: {
        ...httpPostBody ?? {},
        "function": "httpRequester Exception",
      },
      url: "${HttpServices.base}${HttpServices.subbase}$endPoint",
    );

    return {
      "statusCode": null,
      "data": null,
      "url": "${HttpServices.base}${HttpServices.subbase}$endPoint",
      "error": e.toString(),
    };
  }
}
