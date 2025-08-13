import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/pages/modules/worker/workerApplication/registrationEntryCode/registrationEntryCode.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'widget/registrationSelectServiceWidget.dart';

class RegistrationSelectService extends StatefulWidget {
  const RegistrationSelectService({super.key});

  @override
  State<RegistrationSelectService> createState() => _RegistrationSelectServiceState();
}

class _RegistrationSelectServiceState extends State<RegistrationSelectService> {
  final List<Map<String, dynamic>> _serviceList = [
    {
      "title": "Rider",
      "image": Images.service1,
      "check": false,
    },
    {
      "title": "Driver",
      "image": Images.service2,
      "check": false,
    },
    {
      "title": "Shopper",
      "image": Images.service3,
      "check": false,
    },
    {
      "title": "Delivery",
      "image": Images.service4,
      "check": false,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: RichText(
              text: TextSpan(text: "Welcome", style: Styles.h5Black, children: [
                TextSpan(
                  text: "   ${getDisplayName(initials: false)}",
                  style: Styles.h5BlackBold,
                )
              ]),
            ),
          ),
        ],
      ),
      body: registrationSelectServiceWidget(
        context: context,
        serviceList: _serviceList,
        onInfo: (int index) {},
        onService: (int index) => _onService(index),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: button(
          onPressed: () => _onRequestCode(),
          text: "Request Entry Code",
          color: BColors.primaryColor,
          context: context,
        ),
      ),
    );
  }

  void _onRequestCode() {
    bool proceed = false;
    for (var data in _serviceList) {
      if (data["check"]) {
        proceed = true;
        break;
      }
    }

    if (!proceed) {
      toastContainer(
        text: "Select at least one service to proceed",
        backgroundColor: BColors.red,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationEntryCode(
          serviceList: _serviceList,
        ),
      ),
    );
  }

  void _onService(int index) {
    _serviceList[index]["check"] = !_serviceList[index]["check"];
    setState(() {});
  }
}
