import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/models/businessListingsModel.dart';
import 'package:pickme_mobile/pages/modules/vendors/addVendor/addVendor.dart';
import 'package:pickme_mobile/spec/colors.dart';

import '../renewSubscription/renewSubscription.dart';
import 'widget/vendorDetailsWidget.dart';
import 'widget/vendorSubscriptionInfoDialog.dart';

class VendorDetails extends StatefulWidget {
  final ListingDetails data;

  const VendorDetails({super.key, required this.data});

  @override
  State<VendorDetails> createState() => _VendorDetailsState();
}

class _VendorDetailsState extends State<VendorDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundColor: BColors.primaryColor1,
              child: IconButton(
                color: BColors.white,
                onPressed: () => _onEditVendor(),
                icon: const Icon(Icons.edit),
              ),
            ),
          ),
        ],
      ),
      body: vendorDetailsWidget(
        context: context,
        data: widget.data,
        onSubscriptionInfo: () => _onSubscriptionInfo(),
      ),
      bottomNavigationBar: widget.data.status == "APPROVED"
          ? Padding(
              padding: EdgeInsets.all(10),
              child: button(
                onPressed: () => _onRenewSubscription(),
                text: "Renew Subscription",
                color: BColors.primaryColor,
                context: context,
              ),
            )
          : null,
    );
  }

  void _onEditVendor() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddVendor(listingDetails: widget.data),
      ),
    );
  }

  void _onRenewSubscription() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RenewSubscription(data: widget.data),
      ),
    );
  }

  void _onSubscriptionInfo() {
    showDialog(
      context: context,
      builder: (context) => vendorSubscriptionInfoDialog(
        context: context,
        data: widget.data,
      ),
    );
  }
}
