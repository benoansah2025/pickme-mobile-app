import 'package:flutter/material.dart';
import 'package:pickme_mobile/pages/modules/deliveries/deliveryRunner/deliveryRecipient/deliveryCharges/widget/deliveryChargesWidget.dart';
import 'package:pickme_mobile/pages/modules/payments/paymentmethod/paymentmethod.dart';
import 'package:pickme_mobile/spec/arrays.dart';

class Deliverycharges extends StatefulWidget {
  final RideMapNextAction rideMapNextAction;
  final ServicePurpose servicePurpose;
  final Map<dynamic, dynamic> deliveryAddresses;

  const Deliverycharges({
    super.key,
    required this.rideMapNextAction,
    required this.servicePurpose,
    required this.deliveryAddresses,
  });

  @override
  State<Deliverycharges> createState() => _DeliverychargesState();
}

class _DeliverychargesState extends State<Deliverycharges> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: deliveryChargesWidget(
        context: context,
        onProceed: () => _onProceed(),
        rideMapNextAction: widget.rideMapNextAction,
      ),
    );
  }

  void _onProceed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Paymentmethod(
          purpose: widget.servicePurpose,
          deliveryAddresses: widget.deliveryAddresses,
        ),
      ),
    );
  }
}
