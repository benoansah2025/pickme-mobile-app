import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/rideMap.dart';
import 'package:pickme_mobile/spec/arrays.dart';

import 'widget/deliverySingleMultiOptionWidget.dart';

class DeliverySingleMultiOption extends StatefulWidget {
  final DeliveryType deliveryType;

  const DeliverySingleMultiOption({
    super.key,
    required this.deliveryType,
  });

  @override
  State<DeliverySingleMultiOption> createState() => _DeliverySingleMultiOptionState();
}

class _DeliverySingleMultiOptionState extends State<DeliverySingleMultiOption> {
  bool _isLoading = false;

  Position? _currentLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          deliverySingleMultiOptionWidget(
            onDeliveryOption: (ServicePurpose purpose) => _onDeliveryOption(
              purpose,
            ),
            deliveryType: widget.deliveryType,
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
    );
  }

  Future<void> _onDeliveryOption(ServicePurpose purpose) async {
    WidgetsFlutterBinding.ensureInitialized();
    setState(() => _isLoading = true);
    _currentLocation = await Geolocator.getCurrentPosition();
    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideMap(
          currentLocation: _currentLocation!,
          mapNextAction: widget.deliveryType == DeliveryType.send
              ? RideMapNextAction.deliverySendItem
              : RideMapNextAction.deliveryReceiveItem,
          servicePurpose: purpose,
        ),
      ),
    );
  }
}
