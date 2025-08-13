import 'package:flutter/material.dart';
import 'package:pickme_mobile/config/auth/googleService.dart';
import 'package:pickme_mobile/config/deleteCache.dart';
import 'package:pickme_mobile/config/firebase/firebaseAuth.dart';
import 'package:pickme_mobile/config/http/httpActions.dart';
import 'package:pickme_mobile/config/http/httpChecker.dart';
import 'package:pickme_mobile/config/http/httpRequester.dart';
import 'package:pickme_mobile/config/http/httpServices.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/sharePreference.dart';

Future<void> onLogout({
  required void Function() loading,
  required void Function() notLoading,
  required BuildContext context,
}) async {
  loading();

  await httpChecker(
    httpRequesting: () => httpRequesting(
      endPoint: HttpServices.auth,
      method: HttpMethod.post,
      httpPostBody: {
        "action": HttpActions.logout,
      },
    ),
    showToastMsg: false,
  );
  await deleteCache();
  await FireAuth().signOut();
  // await GoogleService().googleSignOut();
  saveBoolShare(key: 'auth', data: false);

  notLoading();

  if (context.mounted) {
    navigation(context: context, pageName: 'login');
  }
}
