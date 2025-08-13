import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'widget/myServicesWidget.dart';

class MyServices extends StatefulWidget {
  final bool isWorkerStatus;

  const MyServices({
    super.key,
    this.isWorkerStatus = false,
  });

  @override
  State<MyServices> createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {
  final Repository _repo = new Repository();
  final _firebaseService = new FirebaseService();

  StreamSubscription<WorkersInfoModel>? _workerInfoSubscription;

  List<Map<String, dynamic>>? _servicesList;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repo.fetchWorkerInfo(true);
    _loadServices();
  }

  @override
  void dispose() {
    _workerInfoSubscription?.cancel();
    _workerInfoSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: BColors.white),
        backgroundColor: BColors.primaryColor,
        title: Text("My Services", style: Styles.h4WhiteBold),
      ),
      body: _servicesList != null
          ? Stack(
              children: [
                myServicesWidget(
                  context: context,
                  servicesList: _servicesList!,
                  onService: (int index) => _onService(index),
                ),
                if (_isLoading) customLoadingPage(),
              ],
            )
          : customLoadingPage(),
      bottomNavigationBar: _servicesList != null
          ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: button(
                onPressed: () => _onSave(),
                text: widget.isWorkerStatus ? "Go Online" : "Done",
                color: BColors.primaryColor,
                context: context,
              ),
            )
          : null,
    );
  }

  Future<void> _onSave() async {
    Map<String, dynamic> reqBody = {
      "userId": userModel!.data!.user!.userid,
      "services": [
        for (var data in _servicesList!)
          if (data["allow"]) data["name"]
      ],
    };
    if (widget.isWorkerStatus) {
      _firebaseService.saveWorkerServices(reqBody);
      if (!mounted) return;
      Navigator.pop(context, {
        "services": [
          for (var data in _servicesList!)
            if (data["allow"]) data["name"]
        ],
      });
      return;
    }

    setState(() => _isLoading = true);
    Response response = await _firebaseService.saveWorkerServices(reqBody);
    setState(() => _isLoading = false);

    int statusCode = response.statusCode;
    Map<String, dynamic> body = jsonDecode(response.body);

    if (statusCode == 200) {
      if (!mounted) return;
      infoDialog(
        context: context,
        type: PanaraDialogType.success,
        text: body["msg"],
        confirmBtnText: "Ok",
      );
    } else {
      log(body["error"].toString());
      if (!mounted) return;
      infoDialog(
        context: context,
        type: PanaraDialogType.error,
        text: body["msg"],
        confirmBtnText: "Ok",
      );
    }
  }

  void _onService(int index) {
    if (index == 0) {
      toastContainer(text: "Main service cannot be turn off", backgroundColor: BColors.red);
      return;
    }

    _servicesList![index]["allow"] = !_servicesList![index]["allow"];
    setState(() {});
  }

  void _loadServices() {
    _workerInfoSubscription = workersInfoStream.listen((WorkersInfoModel model) async {
      List<Map<String, dynamic>> servicesList = [
        for (String service in model.data!.services!)
          {
            "name": service,
            "allow": true,
          }
      ];
      List<String>? firebaseWorkerServices = await _firebaseService.getWorkerServices(userModel!.data!.user!.userid!);
      if (firebaseWorkerServices == null) {
        _servicesList = servicesList;
      } else {
        for (var data in servicesList) {
          data["allow"] = firebaseWorkerServices.contains(data["name"]);
        }
        _servicesList = servicesList;
      }

      if (mounted) setState(() {});
    });
  }
}
