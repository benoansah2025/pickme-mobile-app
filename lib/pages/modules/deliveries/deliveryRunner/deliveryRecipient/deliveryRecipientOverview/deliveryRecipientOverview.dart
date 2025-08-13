import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/arrays.dart';

import '../deliveryCharges/deliveryCharges.dart';
import 'widget/deliveryRecipientOverviewWidget.dart';

class DeliveryRecipientOverview extends StatefulWidget {
  final RideMapNextAction rideMapNextAction;
  final ServicePurpose servicePurpose;
  final Map<dynamic, dynamic> deliveryAddresses;

  const DeliveryRecipientOverview({
    super.key,
    required this.rideMapNextAction,
    required this.servicePurpose,
    required this.deliveryAddresses,
  });

  @override
  State<DeliveryRecipientOverview> createState() => _DeliveryRecipientOverviewState();
}

class _DeliveryRecipientOverviewState extends State<DeliveryRecipientOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: deliveryRecipientOverviewWidget(
        context: context,
        deliveryAddresses: widget.deliveryAddresses,
        onProceed: () => _onProceed(),
        rideMapNextAction: widget.rideMapNextAction,
      ),
    );
  }

  void _onProceed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Deliverycharges(
          rideMapNextAction: widget.rideMapNextAction,
          servicePurpose: widget.servicePurpose,
          deliveryAddresses: widget.deliveryAddresses,
        ),
      ),
    );
  }
}
