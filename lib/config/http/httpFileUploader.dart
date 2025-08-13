import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'httpServices.dart';

Future<String> httpFileUploader({
  @required String? imageList,
  String fieldName = "file",
}) async {
  String fileUrl = "";
  File imagePath = File(imageList!);
  var stream =
      // ignore: deprecated_member_use
      new http.ByteStream(DelegatingStream.typed(imagePath.openRead()));
  var length = await imagePath.length();

  var uri = Uri.parse("https://${HttpServices.base}${HttpServices.subbase}${HttpServices.fileUpload}");

  var request = new http.MultipartRequest("POST", uri);
  var multipartFile = new http.MultipartFile(
    fieldName,
    stream,
    length,
    filename: basename(imagePath.path),
  );

  request.files.add(multipartFile);
  var response = await request.send();
  await response.stream.bytesToString().then((value) async {
    if (kDebugMode) {
      print(value);
    }
    final decodeData = json.decode(value);
    if (decodeData['imgfile'] != null) {
      String imageLink = decodeData["imgfile"];
      if (kDebugMode) {
        print(imageLink);
      }
      fileUrl = imageLink;
    } else {
      if (kDebugMode) {
        print("Error occurred while uploading image");
      }
    }
  });
  return fileUrl;
}
