import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/firebase/firebaseService.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';

import 'widget/emergencyWidget.dart';

class Emergency extends StatefulWidget {
  const Emergency({super.key});

  @override
  State<Emergency> createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  List<Map> _contactList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: BColors.white),
        backgroundColor: BColors.primaryColor,
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: _firebaseService.getEmergency(userModel!.data!.user!.userid!),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                _contactList = snapshot.data!;
              }

              return emergencyWidget(
                context: context,
                onAddContact: () => _onAddContact(),
                onRemoveContact: (int index) => _onRemoveContact(index),
                onCall: (String? number) => callLauncher("tel:${number ?? Properties.contactDetails["phone"]}"),
                contactList: _contactList,
              );
            },
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onRemoveContact(int index) async {
    _contactList.removeAt(index);
    await _saveEmergencyContacts();
  }

  void _onAddContact() {
    if (_contactList.length == 3) {
      toastContainer(text: "Maximum of 3 contacts can only be added", backgroundColor: BColors.red);
      return;
    }

    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: BColors.white,
          title: const Text('Enter Details'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                textFormField(
                  hintText: "Enter Name",
                  controller: nameController,
                  focusNode: null,
                  labelText: "Name",
                ),
                const SizedBox(height: 10),
                textFormField(
                  hintText: "Enter Phone",
                  controller: phoneController,
                  focusNode: null,
                  labelText: "Phone",
                  inputType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  String name = nameController.text;
                  String phone = phoneController.text;

                  bool isDuplicate = _contactList.any(
                    (contact) => contact['name'] == name || contact['phone'] == phone,
                  );

                  if (isDuplicate) {
                    toastContainer(
                      text: "This contact already exists.",
                      backgroundColor: BColors.red,
                    );
                    return;
                  }

                  if (name.isNotEmpty && phone.isNotEmpty) {
                    _contactList.add({"name": name, "phone": phone});
                    Navigator.of(context).pop();
                    await _saveEmergencyContacts();
                  } else {
                    toastContainer(text: "Name or phone cannot be empty", backgroundColor: BColors.red);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveEmergencyContacts() async {
    Map<String, dynamic> reqBody = {
      "emergency": _contactList,
      "userId": userModel!.data!.user!.userid,
    };

    setState(() => _isLoading = true);
    Response response = await _firebaseService.saveEmergency(reqBody);
    setState(() => _isLoading = false);

    int statusCode = response.statusCode;
    Map<String, dynamic> body = jsonDecode(response.body);

    if (statusCode != 200) {
      if (!mounted) return;
      infoDialog(
        context: context,
        type: PanaraDialogType.error,
        text: body["msg"],
        confirmBtnText: "Ok",
      );
    } else {
      toastContainer(text: body["msg"], backgroundColor: BColors.green);
      setState(() {});
    }
  }
}
