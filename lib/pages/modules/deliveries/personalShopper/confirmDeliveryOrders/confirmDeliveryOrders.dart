import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/pages/modules/deliveries/personalShopper/confirmDeliveryOrders/widget/confirmDeliveryOrdersWidget.dart';
import 'package:pickme_mobile/pages/modules/payments/paymentmethod/paymentmethod.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/confirmDeliveryEstimateWidget.dart';

class ConfirmDeliveryOrders extends StatefulWidget {
  final Map<String, dynamic> itemsMap;

  const ConfirmDeliveryOrders({
    super.key,
    required this.itemsMap,
  });

  @override
  State<ConfirmDeliveryOrders> createState() => _ConfirmDeliveryOrdersState();
}

class _ConfirmDeliveryOrdersState extends State<ConfirmDeliveryOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: confirmDeliveryOrdersWidget(
        context: context,
        itemsMap: widget.itemsMap,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(10),
        child: button(
          onPressed: () => _onContinue(),
          text: "Proceed to payment",
          color: BColors.primaryColor,
          context: context,
        ),
      ),
    );
  }

  void _onContinue() {
    showModalBottomSheet(
      context: context,
      builder: (context) => confirmDeliveryEstimateWidget(
        context: context,
        onContinue: () => _paymentMethod(),
      ),
    );
  }

  void _paymentMethod() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Paymentmethod(
          purpose: ServicePurpose.personalShopper,
        ),
      ),
    );
  }
}
