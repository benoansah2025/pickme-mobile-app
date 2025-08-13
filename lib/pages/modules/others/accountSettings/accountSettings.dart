import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/infoDialog.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/config/auth/appLogout.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/pages/modules/others/accountSettings/widget/accountSettingsWidget.dart';
import 'package:pickme_mobile/pages/modules/payments/lockPincode/lockPincode.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: BColors.white),
        backgroundColor: BColors.primaryColor,
        title: Text("Settings", style: Styles.h4WhiteBold),
      ),
      body: Stack(
        children: [
          accountSettingsWidget(
            context: context,
            onEdit: () => navigation(
              context: context,
              pageName: 'editProfile',
            ),
            onResetPassword: () => navigation(
              context: context,
              pageName: 'resetpasswordloggedin',
            ),
            onSetPaymentPincode: () => _onSetPaymentPincode(),
            onRate: () {},
            onFeedback: () {},
            onTerms: () {},
            onLogout: () => _onLogoutDialog(),
            onDeleteAccount: () => navigation(
              context: context,
              pageName: 'deleteAccount',
            ),
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onSetPaymentPincode() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LockPincode(resetPin: true),
    );
  }

  void _onLogoutDialog() {
    infoDialog(
      context: context,
      text: 'Do you want to logout',
      onConfirmBtnTap: () async {
        navigation(context: context, pageName: "back");
        onLogout(
          loading: ()=> setState(() => _isLoading = true),
          notLoading: ()=>  setState(() => _isLoading = false),
          context: context,
        );
      },
      confirmBtnText: "Logout",
      closeOnConfirmBtnTap: false,
    );
  }
}
