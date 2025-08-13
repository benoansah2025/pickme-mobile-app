import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/pages/modules/deliveries/deliveryRunner/deliverySingleMultiOption/deliverySingleMultiOption.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/deliveryChooseVehicleWidget.dart';

class DeliveryChooseVehicle extends StatefulWidget {
  final DeliveryType type;

  const DeliveryChooseVehicle({
    super.key,
    required this.type,
  });

  @override
  State<DeliveryChooseVehicle> createState() => _DeliveryChooseVehicleState();
}

class _DeliveryChooseVehicleState extends State<DeliveryChooseVehicle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: deliveryChooseVehicleWidget(
        onAction: (String action) {},
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: button(
          onPressed: () => _onNext(),
          text: "Next",
          color: BColors.primaryColor,
          context: context,
        ),
      ),
    );
  }

  void _onNext() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliverySingleMultiOption(
          deliveryType: widget.type,
        ),
      ),
    );
  }
}
