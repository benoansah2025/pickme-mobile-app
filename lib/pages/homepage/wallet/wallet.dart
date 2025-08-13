import 'package:flutter/material.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/modules/payments/lockPincode/lockPincode.dart';

import 'widget/walletWidget.dart';

class Wallet extends StatefulWidget {
  final bool isWorker;

  const Wallet({
    super.key,
    required this.isWorker,
  });

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String _filterType = "all";
  bool _showWallet = false;

  final Repository _repo = new Repository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPincode();
    });
    _repo.fetchWalletBalance(true);
    _repo.fetchWalletTransaction(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: walletWidget(
        context: context,
        onAddMoney: () => navigation(context: context, pageName: "addMoney"),
        onTransfer: () => navigation(context: context, pageName: "transferMoney"),
        onWithdraw: () {},
        onContactUs: () => navigation(context: context, pageName: "support"),
        onTransactionFilter: (String filter) => _onTransactionFilter(filter),
        filterType: _filterType,
        onCopyID: () => copyToClipboard(
          userModel!.data!.user!.userid!,
        ),
        isWorker: widget.isWorker,
        showWallet: _showWallet,
      ),
    );
  }

  void _onTransactionFilter(String filter) {
    _filterType = filter;
    setState(() {});
  }

  Future<void> _showPincode() async {
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LockPincode(),
      );

      _showWallet = true;
      setState(() {});
    }
  }
}
