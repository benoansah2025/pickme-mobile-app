import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadFile(
  String? url, {
  String? filePath,
  String? defaultFileName,
  void Function(int receive, int total, String precentCompletedText, double percentCompleteValue)? onProgress,
  @required void Function(String? savePath)? onDownloadComplete,
  bool useTempDir = false,
}) async {
  try {
    Dio dio = new Dio();
    String fileName = defaultFileName ?? url!.substring(url.lastIndexOf("/") + 1);
    String savePath = filePath ??
        await getFilePath(
          fileName,
          useTempDir: useTempDir,
        );
    log(savePath);

    bool isExit = await File(savePath).exists();

    if (isExit) {
      onDownloadComplete!(savePath);
      return;
    }

    await dio.download(
      url!,
      savePath,
      onReceiveProgress: (receive, total) {
        String percentCompleted = "0%";
        double percentValue = 0;
        if (total != -1) {
          percentValue = receive / total * 100;
          percentCompleted = "${percentValue.toStringAsFixed(0)}%";
        }
        if (onProgress != null) {
          onProgress(receive, total, percentCompleted, percentValue);
        }
      },
    );
    onDownloadComplete!(savePath);
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<String> getFilePath(
  String uniqueFileName, {
  bool useTempDir = false,
}) async {
  String path = '';

  Directory dir = useTempDir ? await getTemporaryDirectory() : await getApplicationDocumentsDirectory();

  if (uniqueFileName.contains("?")) {
    path = '${dir.path}/${uniqueFileName.split("?").first}';
  } else {
    path = '${dir.path}/$uniqueFileName';
  }

  return path;
}
