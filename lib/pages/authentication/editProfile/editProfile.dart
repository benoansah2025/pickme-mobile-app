import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/downloadFile.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/sharePreference.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';
import 'package:pickme_mobile/spec/theme.dart';
import 'package:pickme_mobile/utils/captureImage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widget/editProfileWidget.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  bool _isLoading = false, _isLocalUpload = false;

  FocusNode? _nameFocusNode, _emailFocusNode, _editOccupationFocusNode, _phoneFocusNode;

  String _profilePic = "";

  @override
  void initState() {
    super.initState();
    _nameController.text = userModel!.data!.user!.name!;
    _emailController.text = userModel!.data!.user!.email ?? "";
    _phoneController.text = userModel!.data!.user!.phone ?? "";
    _dobController.text = userModel!.data!.user!.dob ?? "";
    _genderController.text = userModel!.data!.user!.gender ?? "";
    _profilePic = userModel!.data!.user!.picture ?? "";

    _nameFocusNode = new FocusNode();
    _emailFocusNode = new FocusNode();
    _editOccupationFocusNode = new FocusNode();
    _phoneFocusNode = new FocusNode();
  }

  @override
  void dispose() {
    _nameFocusNode!.dispose();
    _emailFocusNode!.dispose();
    _editOccupationFocusNode!.dispose();
    _phoneFocusNode!.dispose();
    super.dispose();
  }

  void _onFocusAllNodes() {
    _nameFocusNode!.unfocus();
    _emailFocusNode!.unfocus();
    _editOccupationFocusNode!.unfocus();
    _phoneFocusNode!.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: BColors.white),
        backgroundColor: BColors.primaryColor,
        title: Text("Profile", style: Styles.h4WhiteBold),
      ),
      body: Stack(
        children: [
          editProfileWidget(
            context: context,
            nameFocusNode: _nameFocusNode,
            nameController: _nameController,
            emailFocusNode: _emailFocusNode,
            emailController: _emailController,
            phoneController: _phoneController,
            phoneFocusNode: _phoneFocusNode,
            formKey: _formKey,
            isLocalUpload: _isLocalUpload,
            onUploadProfilePicture: () => _onUploadProfilePicture(),
            profilePic: _profilePic,
            dobController: _dobController,
            genderController: _genderController,
            onDOB: () => _onDate(),
            onGender: () => _onGender(),
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
      bottomNavigationBar: _isLoading
          ? null
          : Container(
              color: BColors.white,
              padding: const EdgeInsets.all(10),
              child: button(
                onPressed: () => _onEditProfile(),
                text: "Update",
                color: BColors.primaryColor,
                context: context,
              ),
            ),
    );
  }

  Future<void> _onDate() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
      builder: (BuildContext? context, Widget? child) {
        return Theme(
          data: Themes.datePickerTheme(),
          child: child!,
        );
      },
    );
    if (selected != null) {
      _dobController.text = selected.toIso8601String().split("T")[0];
      setState(() {});
    }
  }

  void _onGender() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select gender'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _genderController.text = "Male";
                });
                Navigator.of(context).pop();
              },
              child: const Text('Male', style: TextStyle(fontSize: 20)),
            ),
            const Divider(),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _genderController.text = "Female";
                });
                Navigator.of(context).pop();
              },
              child: const Text('Female', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  void _onEditProfile() async {
    _onFocusAllNodes();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String? uploadPic = _profilePic;
      if (_profilePic.contains("http")) {
        await downloadFile(
          _profilePic,
          filePath: await getFilePath(_profilePic.split("/").last),
          onDownloadComplete: (String? savePath) async {
            uploadPic = savePath;
            setState(() {});
          },
        );
      }

      final formData = FormData.fromMap({
        "action": HttpActions.updateProfile,
        "userid": userModel!.data!.user!.userid,
        "name": _nameController.text,
        "email": _emailController.text,
        "gender": _genderController.text.toUpperCase(),
        "dob": _dobController.text,
        "picture": uploadPic != null && uploadPic != ""
            ? await MultipartFile.fromFile(
                uploadPic!,
                filename: _profilePic.toString().split("/").last,
              )
            : "",
      });

      final dio = Dio();
      try {
        final response = await dio.post(
          "${HttpServices.fullurl}${HttpServices.auth}",
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
          SharedPreferences? prefs = await SharedPreferences.getInstance();
          String encodedData = prefs.getString("userDetails")!;
          var decodedData = json.decode(encodedData);
          decodedData["data"]["user"] = data["data"]["user"];
          await saveStringShare(key: "userDetails", data: jsonEncode(decodedData));
          userModel = UserModel.fromJson(decodedData);
          toastContainer(
            text: data["msg"],
            backgroundColor: BColors.green,
          );

          if (!mounted) return;
          navigation(context: context, pageName: "homepage");
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
  }

  Future<void> _onUploadProfilePicture() async {
    File imagePath = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageCapture(),
      ),
    );
    // ignore: unnecessary_null_comparison
    if (imagePath != null) {
      setState(() {
        _profilePic = imagePath.path;
        _isLocalUpload = true;
      });
    }
  }
}
