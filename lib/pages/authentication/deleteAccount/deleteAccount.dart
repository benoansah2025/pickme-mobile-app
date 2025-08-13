import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/auth/googleService.dart';
import 'package:pickme_mobile/config/deleteCache.dart';
import 'package:pickme_mobile/config/firebase/firebaseAuth.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/sharePreference.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'widget/deleteAccountDialog.dart';
import 'widget/deleteAccountWidget.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  final FireAuth _firebaseAuth = new FireAuth();
  // final GoogleService _googleService = new GoogleService();

  final List<Map<String, dynamic>> _reasonList = [
    {"reason": "I don't find it useful", "selected": false},
    {"reason": "I don't understand how it works", "selected": false},
    {"reason": "I have safety concerns", "selected": false},
    {"reason": "I have privacy concerns", "selected": false},
    {"reason": "Created another account", "selected": false},
    {"reason": "Just need a break", "selected": false},
    {"reason": "App crushes too often", "selected": false},
    {"reason": "Something Else", "selected": false},
    {"reason": "Others", "selected": false},
  ];

  final _reasonController = new TextEditingController();
  final _passwordController = new TextEditingController();

  FocusNode? _reasonFocusNode, _passwordFocusNode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reasonFocusNode = new FocusNode();
    _passwordFocusNode = new FocusNode();
  }

  @override
  void dispose() {
    _reasonFocusNode!.dispose();
    _passwordFocusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: BColors.white),
        backgroundColor: BColors.primaryColor,
        title: Text("Delete Account", style: Styles.h4WhiteBold),
      ),
      body: Stack(
        children: [
          deleteAccountWidget(
            context: context,
            onSelectReason: (int index) => _onSelectReason(index),
            onDelete: () => _onDeleteDialog(),
            reasonController: _reasonController,
            reasonFocusNode: _reasonFocusNode,
            reasonList: _reasonList,
            passwordController: _passwordController,
            passwordFocusNode: _passwordFocusNode,
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  void _onSelectReason(int index) {
    _reasonFocusNode!.unfocus();
    _reasonList[index]["selected"] = !_reasonList[index]["selected"];
    setState(() {});
  }

  Future<void> _onDeleteDialog() async {
    if (_passwordController.text.isEmpty) {
      toastContainer(
        text: "Enter password to proceed",
        backgroundColor: BColors.red,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (builder) {
        return deleteAccountDialog(
          onCancel: () => Navigator.pop(context),
          onDelete: () => _onDelete(),
        );
      },
    );
  }

  Future<void> _onDelete() async {
    Navigator.pop(context);
    _reasonFocusNode!.unfocus();
    _passwordFocusNode!.unfocus();

    setState(() => _isLoading = true);
    List<String> reasons = [
      for (var data in _reasonList)
        if (data["selected"]) data["reason"] == "Others" ? _reasonController.text : data["reason"]
    ];

    Map<String, dynamic> httpResult = await httpChecker(
      httpRequesting: () => httpRequesting(
        endPoint: HttpServices.auth,
        method: HttpMethod.post,
        httpPostBody: {
          "action": HttpActions.deleteAccount,
          "userid": userModel!.data!.user!.userid,
          "reason": json.encode(reasons),
          "password": _passwordController.text,
        },
      ),
    );
    if (httpResult['ok']) {
      saveBoolShare(key: "auth", data: false);
      await deleteCache();
      await _firebaseAuth.signOut();
      // await _googleService.googleSignOut();
      setState(() => _isLoading = false);
      toastContainer(
        text: httpResult["data"]['msg'],
        backgroundColor: BColors.green,
      );
      if (!mounted) return;
      navigation(context: context, pageName: 'logout');
    } else {
      setState(() => _isLoading = false);
      toastContainer(
        text: httpResult["data"]["msg"],
        backgroundColor: BColors.red,
      );
    }
  }
}
