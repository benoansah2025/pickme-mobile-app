import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/pages/modules/deliveries/personalShopper/confirmDeliveryOrders/confirmDeliveryOrders.dart';
import 'package:pickme_mobile/pages/modules/rides/rideMap/rideMap.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/deliveryAddressWidget.dart';

class DeliveryAddress extends StatefulWidget {
  final Map<String, dynamic> itemsMap;

  const DeliveryAddress({
    super.key,
    required this.itemsMap,
  });

  @override
  State<DeliveryAddress> createState() => _DeliveryAddressState();
}

class _DeliveryAddressState extends State<DeliveryAddress> {
  bool _isLoading = false;

  Position? _currentLocation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          deliveryAddressWidget(
            onDelete: () {},
          ),
          if (_isLoading) customLoadingPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAdd(),
        child: const Icon(Icons.add, color: BColors.white),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: button(
          onPressed: () => _onContinue(),
          text: "Continue",
          color: BColors.primaryColor,
          context: context,
        ),
      ),
    );
  }

  void _onContinue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmDeliveryOrders(
          itemsMap: widget.itemsMap,
        ),
      ),
    );
  }

  Future<void> _onAdd() async {
    WidgetsFlutterBinding.ensureInitialized();
    setState(() => _isLoading = true);
    _currentLocation = await Geolocator.getCurrentPosition();
    setState(() => _isLoading = false);

    if (!mounted) return;
    Map<dynamic, dynamic>? addressDetails = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideMap(
          currentLocation: _currentLocation!,
          mapNextAction: RideMapNextAction.addAddress,
        ),
      ),
    );

    debugPrint(addressDetails.toString());
  }
}
