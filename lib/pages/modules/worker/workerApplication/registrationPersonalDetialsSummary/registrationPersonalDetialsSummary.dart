import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/congratPage.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/homepage/mainHomepage.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'widget/registrationPersonalDetialsSummaryWidget.dart';

class RegistrationPersonalDetialsSummary extends StatefulWidget {
  final Map<String, dynamic> meta;
  final List<Map<String, dynamic>> serviceList;

  const RegistrationPersonalDetialsSummary(
    this.meta, {
    super.key,
    required this.serviceList,
  });

  @override
  State<RegistrationPersonalDetialsSummary> createState() => _RegistrationPersonalDetialsSummaryState();
}

class _RegistrationPersonalDetialsSummaryState extends State<RegistrationPersonalDetialsSummary> {
  final ScrollController _scrollController = new ScrollController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          registrationPersonalDetialsSummaryWidget(
            context: context,
            meta: widget.meta,
            onConfirm: () => _onConfirm(),
            scrollController: _scrollController,
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    _onScrollEnd();

    setState(() => _isLoading = true);
    final dio = Dio();

    List<String> servicesList = [];
    for (var data in widget.serviceList) {
      if (data["check"]) {
        servicesList.add(data["title"]);
      }
    }

    Map<String, dynamic> meta = widget.meta;
    final formData = FormData.fromMap({
      "action": HttpActions.registerWorker,
      "userid": userModel!.data!.user!.userid,
      "name": meta["name"],
      "dob": meta["dob"],
      "gender": meta["gender"],
      "licenseNumber": meta["license"],
      "expiryDate": meta["expiryDate"],
      "vehicleType": meta["vehicletype"],
      "pickmeRollNo": meta["pickRoll"],
      "vehicleMake": meta["vehicleMake"],
      "vehicleModel": meta["vehicleModel"],
      "vehicleYear": meta["vehicleYear"],
      "vehicleNumber": meta["vehicleNumber"],
      "vehicleColor": meta["vehicleColor"],
      "insuranceExpiryDate": meta["insuranceDate"],
      "roadWorthyExpiryDate": meta["roadWorthyDate"],
      for (int x = 0; x < servicesList.length; ++x) "services[$x]": servicesList[x].toUpperCase(),
      "mainService": servicesList.first,
      "ghanacardNo": meta["cardNo"],
      "picture": await MultipartFile.fromFile(
        meta["imagePath"],
        filename: meta["imagePath"].toString().split("/").last,
      ),
      "licenseFrontImage": await MultipartFile.fromFile(
        meta["licenseImageFrontPath"],
        filename: meta["licenseImageFrontPath"].toString().split("/").last,
      ),
      "licenseBackImage": await MultipartFile.fromFile(
        meta["licenseImageBackPath"],
        filename: meta["licenseImageBackPath"].toString().split("/").last,
      ),
      "ghanaCardFrontImage": await MultipartFile.fromFile(
        meta["ghanaCardFrontPath"],
        filename: meta["ghanaCardFrontPath"].toString().split("/").last,
      ),
      "ghanaCardBackImage": await MultipartFile.fromFile(
        meta["ghanaCardBackPath"],
        filename: meta["ghanaCardBackPath"].toString().split("/").last,
      ),
      "insuranceImage": await MultipartFile.fromFile(
        meta["insurancePath"],
        filename: meta["insurancePath"].toString().split("/").last,
      ),
      "roadWorthyImage": await MultipartFile.fromFile(
        meta["roadWorthyPath"],
        filename: meta["roadWorthyPath"].toString().split("/").last,
      ),
    });

    try {
      final response = await dio.post(
        HttpServices.fullurl,
        data: formData,
        options: Options(
          headers: {"Authorization": "Bearer ${userModel!.data!.authToken}"},
        ),
      );
      var statusCode = response.statusCode;
      var data = response.data;
      log("body => $data");
      setState(() => _isLoading = false);
      if (statusCode == 200 && data["ok"]) {
        _onCongratPage();
      } else {
        toastContainer(
          text: data["msg"],
          backgroundColor: BColors.red,
        );
      }
    } catch (e) {
      log(e.toString());
      setState(() => _isLoading = false);
      toastContainer(
        text: e.toString(),
        backgroundColor: BColors.red,
      );
    }
  }

  void _onCongratPage() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => CongratPage(
            homeButtonText: "Ok",
            fillBottomButton: true,
            onHome: (context) => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainHomepage(selectedPage: 4),
                ),
                (Route<dynamic> route) => false),
            widget: Column(
              children: [
                Text(
                  "We're reviewing your document",
                  style: Styles.h3BlackBold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Text(
                  "This process usually takes less than a day for us to complete ",
                  style: Styles.h5Black,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
        (Route<dynamic> route) => false);
  }

  void _onScrollEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }
}
