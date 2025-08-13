import 'package:flutter/material.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/investmentModel.dart';
import 'package:pickme_mobile/pages/modules/others/investment/widget/investmentDetailsDialog.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'widget/investmentWidget.dart';

class Investment extends StatefulWidget {
  const Investment({super.key});

  @override
  State<Investment> createState() => _InvestmentState();
}

class _InvestmentState extends State<Investment> {
  final _repo = new Repository();

  @override
  void initState() {
    super.initState();
    _repo.fetchInvestment(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: BColors.white),
        backgroundColor: BColors.primaryColor,
        title: Text("Invest in ${Properties.titleShort}", style: Styles.h4WhiteBold),
      ),
      body: investmentWidget(
        context: context,
        onDetials: (InvestmentData data) => _onDetials(data),
      ),
    );
  }

  void _onDetials(InvestmentData data) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: BColors.white,
      builder: (context) => investmentDetailsDialog(
        data: data,
        context: context,
      ),
    );
  }
}
