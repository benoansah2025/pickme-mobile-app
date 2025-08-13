import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget deleteAccountDialog({
  @required void Function()? onCancel,
  @required void Function()? onDelete,
}) {
  return AlertDialog(
    contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
    title: const Text(
      'Are you sure you want to delete your account?',
      textAlign: TextAlign.center,
    ),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SimpleDialogOption(
          child: Text(
            'If you delete your account, you will permanently lose your profile, content, and photos. If you delete your account, this action cannot be undone.',
            style: Styles.h4Black,
            textAlign: TextAlign.center,
          ),
        ),
        SimpleDialogOption(
          child: Text(
            'Are you sure you want to delete your account?',
            style: Styles.h4Black,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        style: TextButton.styleFrom(foregroundColor: BColors.black),
        onPressed: onCancel,
        child: const Text('CANCEL'),
      ),
      TextButton(
        style: TextButton.styleFrom(
          foregroundColor: BColors.white,
          backgroundColor: BColors.red,
        ),
        onPressed: onDelete,
        child: const Text('DELETE'),
      ),
    ],
  );
}
