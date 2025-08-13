import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/config/repository/repo.dart';
import 'package:pickme_mobile/models/salesSummaryModel.dart';
import 'package:pickme_mobile/pages/modules/payments/walletPaySales/walletPaySales.dart';
import 'package:pickme_mobile/providers/salesSummaryProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/salesPaymentWidget.dart';

class SalesPayment extends StatefulWidget {
  const SalesPayment({super.key});

  @override
  State<SalesPayment> createState() => _SalesPaymentState();
}

class _SalesPaymentState extends State<SalesPayment> {
  final Repository _repo = new Repository();

  String _filterType = "My Sales";

  @override
  void initState() {
    super.initState();
    _repo.fetchSalesSummary(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: salesSummaryStream,
        initialData: salesSummaryModel,
        builder: (context, AsyncSnapshot<SalesSummaryModel> snapshot) {
          if (snapshot.hasData) {
            return salesPaymentWidget(
              context: context,
              onPayment: (SalesSummaryData data) => _onPayment(data, false),
              model: snapshot.data,
              onSalesFilter: (String filter) => _onSalesFilter(filter),
              filterType: _filterType,
              onOthersPayment: (SalesSummaryData data) => _onPayment(data, true),
            );
          }
          return Center(
            child: loadingDoubleBounce(BColors.primaryColor),
          );
        },
      ),
    );
  }

  void _onSalesFilter(String filter) {
    _filterType = filter;
    setState(() {});
  }

  void _onPayment(SalesSummaryData data, bool isPayForOthers) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WalletPaySales(
          salesSummaryData: isPayForOthers ? null : data,
          paymentEndTime: data.paymentEndTime,
        ),
      ),
    );
  }
}
