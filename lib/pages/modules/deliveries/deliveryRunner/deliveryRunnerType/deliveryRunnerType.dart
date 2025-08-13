import 'package:flutter/material.dart';
import 'package:pickme_mobile/pages/modules/deliveries/deliveryRunner/deliveryChooseVehicle/deliveryChooseVehicle.dart';
import 'package:pickme_mobile/spec/arrays.dart';

import 'widget/deliveryRunnerTypeWidget.dart';

class DeliveryRunnerType extends StatefulWidget {
  const DeliveryRunnerType({super.key});

  @override
  State<DeliveryRunnerType> createState() => _DeliveryRunnerTypeState();
}

class _DeliveryRunnerTypeState extends State<DeliveryRunnerType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: deliveryRunnerTypeWidget(
        onDeliveryType: (DeliveryType type) => _onDeliveryType(type),
      ),
    );
  }

  void _onDeliveryType(DeliveryType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryChooseVehicle(type: type),
      ),
    );
  }
}
