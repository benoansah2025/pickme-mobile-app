import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:pickme_mobile/config/auth/appLogout.dart';
import 'package:pickme_mobile/config/firebase/firebaseAuth.dart';
import 'package:pickme_mobile/config/firebase/firebaseProfile.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/models/placemarkModel.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/providers/vehicleTypesProvider.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:path_provider/path_provider.dart';

void logStatement(var l) => log(jsonEncode(l));

String getVehicleTypePicture(String vehicleTypeId) {
  return vehicleTypeId == "3" || vehicleTypeId.toLowerCase() == "bike"
      ? Images.moto
      : vehicleTypeId == "2" || vehicleTypeId.toLowerCase() == "okada"
          ? Images.okada
          : vehicleTypeId == "4" || vehicleTypeId.toLowerCase() == "van"
              ? Images.van
              : Images.carSvg;
}

String getVehicleTypeName(String vehicleTypeId) {
  String name = "";
  if (vehicleTypesModel != null) {
    for (var data in vehicleTypesModel!.data!) {
      if (data.id == vehicleTypeId) {
        name = data.name!;
        break;
      }
    }
  }
  return name;
}

String formatDuration(
  int seconds, {
  bool shorten = false,
  bool displayFullDuration = true,
}) {
  if (seconds < 60) {
    return "$seconds ${shorten ? 's' : 'sec'}${seconds == 1 ? '' : shorten ? '' : 's'}";
  } else if (seconds < 3600) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    // If showSeconds is true or hours are not present, display seconds.
    return "$minutes ${shorten ? 'm' : 'min'}${minutes == 1 ? '' : shorten ? '' : 's'}"
        "${(remainingSeconds > 0 && displayFullDuration) ? " $remainingSeconds ${shorten ? 's' : 'sec'}${remainingSeconds == 1 ? '' : shorten ? '' : 's'}" : ""}";
  } else {
    int hours = seconds ~/ 3600;
    int remainingMinutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    // If showSeconds is true, and we're not displaying hours, show seconds.
    return "$hours ${shorten ? 'h' : 'hr'}${hours == 1 ? '' : shorten ? '' : 's'}"
        "${remainingMinutes > 0 ? " $remainingMinutes ${shorten ? 'm' : 'min'}${remainingMinutes == 1 ? '' : shorten ? '' : 's'}" : ""}"
        "${(remainingSeconds > 0 && displayFullDuration) ? " $remainingSeconds ${shorten ? 's' : 'sec'}${remainingSeconds == 1 ? '' : shorten ? '' : 's'}" : ""}";
  }
}

void shareFiles({
  @required List<XFile>? file,
  @required String? description,
}) async {
  final result = await Share.shareXFiles(file ?? [], text: '$description');

  if (result.status == ShareResultStatus.success) {
    if (kDebugMode) {
      print('Thank you for sharing the picture!');
    }
  }
}

void inviteFrinds() {
  Share.share('${Properties.titleShort}, Elevating access to quality services everywhere');
}

void callLauncher(String link) async {
  Uri url = Uri.parse(link);
  if (!await launchUrl(url)) {
    throw 'Could not open, try different text';
  }
}

String getReaderDate(String date, {bool showTime = false}) {
  try {
    DateTime dateTime = DateTime.parse(date);
    String newDt = DateFormat.yMMMEd().format(dateTime);
    String newTime = DateFormat.Hm().format(dateTime);
    return showTime ? "$newDt  $newTime" : newDt;
  } catch (e) {
    return "";
  }
}

String getReaderTime(String time) {
  try {
    // Parse the input time string into a DateTime object
    DateFormat inputFormat = DateFormat("HH:mm:ss");
    DateTime parsedTime = inputFormat.parse(time);

    // Format the DateTime object into a readable time format
    DateFormat outputFormat = DateFormat("h:mm a");
    return outputFormat.format(parsedTime);
  } catch (e) {
    return "N/A";
  }
}

Future<String> getFilePath(String uniqueFileName) async {
  String path = '';

  Directory dir = await getApplicationDocumentsDirectory();

  if (uniqueFileName.contains("?")) {
    path = '${dir.path}/${uniqueFileName.split("?").first}';
  } else {
    path = '${dir.path}/$uniqueFileName';
  }

  return path;
}

bool checkIfDeviceIsTablet() {
  bool isTablet = false;

  // ignore: deprecated_member_use
  final data = MediaQueryData.fromView(WidgetsBinding.instance.window);

  if (data.size.shortestSide < 550) {
    isTablet = false;
  } else {
    isTablet = true;
  }
  return isTablet;
}

Future<String> saveJsonFile({
  @required String? filename,
  @required dynamic data,
}) async {
  final file = File(
    '${(await getApplicationDocumentsDirectory()).path}/$filename.json',
  );
  await file.writeAsString(json.encode(data));

  String encodedData = await file.readAsString();
  return encodedData;
}

Future<void> deleteFile(String path) async {
  final file = File(path);
  await file.delete();
}

String getTimeago(DateTime dateTime) {
  return timeago.format(dateTime, locale: 'en_short', allowFromNow: true);
}

String sentenceCase(String input) {
  return input.substring(0, 1).toUpperCase() + input.substring(1).toLowerCase();
}

Future<bool> handleLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error('Location permissions are permanently denied, we cannot request permissions.');
  }
  return serviceEnabled;
}

Future<PlacemarkModel?> getLocationDetails({
  @required double? lat,
  @required double? log,
}) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lat!, log!);
  if (placemarks.isNotEmpty) {
    // debugPrint("placemark ${placemarks[0].toJson()}");
    return PlacemarkModel.fromJson(placemarks[0].toJson());
  } else {
    return null;
  }
}

String formatNumber(String num) {
  var formattedNumber = NumberFormat.compactCurrency(
    decimalDigits: 0,
    symbol: '', // if you want to add currency symbol then pass that in this else leave it empty.
  ).format(double.parse(num));
  return formattedNumber;
}

Future<void> continueSignUpOnFirebase({
  @required String? firebaseUserId,
  @required UserModel? userModel,
  required BuildContext context,
}) async {
  FireAuth firebaseAuth = new FireAuth();
  FireProfile fireProfile = new FireProfile();
  if (firebaseUserId == null) {
    await firebaseAuth.signIn(
      email: userModel!.data!.user!.email ??
          "${userModel.data!.user!.userid!}@${removeWhiteSpace(Properties.titleShort).toLowerCase()}.com",
      password: Properties.defaultPassword,
      name: '${userModel.data!.user!.name}',
      userId: userModel.data!.user!.userid,
    );
  } else {
    await fireProfile.createAccount(
      email: userModel!.data!.user!.email ??
          "${userModel.data!.user!.userid!}@${removeWhiteSpace(Properties.titleShort).toLowerCase()}.com",
      name: '${userModel.data!.user!.name}',
      userId: userModel.data!.user!.userid,
      firebaseUserId: firebaseUserId,
    );
    await firebaseAuth.saveToken();
  }

  if (context.mounted) await _saveUserToken(context);
}

Future<void> _saveUserToken(BuildContext context) async {
  Map<String, dynamic> reqBody = {
    "token": userModel?.data?.authToken,
    "userId": userModel!.data!.user!.userid,
  };

  Response response = await FirebaseService().saveUserToken(reqBody);

  int statusCode = response.statusCode;
  Map<String, dynamic> body = jsonDecode(response.body);

  if (statusCode != 200) {
    toastContainer(text: body["msg"], backgroundColor: BColors.red);
    if (context.mounted) {
      onLogout(
        loading: () {},
        notLoading: () {},
        context: context,
      );
    }
  } else {
    log(body["msg"]);
  }
}

String removeWhiteSpace(String text) {
  String s = text.replaceAll(RegExp(r"\s+"), "");
  return s;
}

String getDisplayName({String? username, bool initials = true}) {
  if (userModel == null) return "";

  String name = username ?? userModel!.data!.user!.name!;
  String displayName = "";
  List<String> nameSplit = [];
  if (name.contains(" ")) {
    nameSplit = name.split(" ");
    if (initials) {
      displayName = "${nameSplit[0][0]}${nameSplit[1][0]}".toUpperCase();
    } else {
      displayName = nameSplit[0];
    }
  } else {
    if (initials) {
      displayName = name.substring(0, 2).toUpperCase();
    } else {
      displayName = name;
    }
  }
  return displayName;
}

String displayChars({
  required String text,
  int charsDisplay = 2,
}) {
  String lastChars = text.substring(text.length - charsDisplay);
  return lastChars;
}

Color getStatusColor(String status) {
  if (status.toLowerCase() == "PENDING") {
    return BColors.primaryColor;
  } else if (status.toLowerCase() == "APPROVED") {
    return BColors.green;
  } else if (status.toLowerCase() == "REJECTED") {
    return BColors.red;
  } else {
    return BColors.primaryColor;
  }
}

void copyToClipboard(String text) {
  FlutterClipboard.copy(text).then(
    (value) => toastContainer(text: "Copied", backgroundColor: BColors.green),
  );
}

Color convertToColor(String color) {
  try {
    String filteredColor = color;
    if (color.contains("#")) {
      filteredColor = filteredColor.replaceAll("#", "");
    }
    return Color(int.parse("0xFF$color"));
  } catch (e) {
    return BColors.black;
  }
}

String cleanString(String input) {
  // List of substrings to remove
  List<String> substringsToRemove = ['<b>', '</b>', '<wbr>', '<wbr/>', '/'];

  // Iterate over each substring and remove it from the input string
  for (String substring in substringsToRemove) {
    input = input.replaceAll(substring, '');
  }

  List<Map> replaceString = [
    {"key": "Rd", "value": "Road"},
    {"key": "Ln", "value": "Lane"},
    {"key": "St", "value": "Street"},
  ];

  for (Map data in replaceString) {
    input = input.replaceAll(data["key"], data["value"]);
  }

  return input;
}

// checking if worker account is approved
bool checkWorkerAccountStatus({bool showMsg = false}) {
  bool allow = true;

  String? accountStatus = workersInfoModel?.data?.status;
  if (accountStatus != "APPROVED") {
    if (showMsg) {
      toastContainer(
        text: "Your account is $accountStatus",
        backgroundColor: BColors.red,
      );
    }
    allow = false;
  }
  return allow;
}
