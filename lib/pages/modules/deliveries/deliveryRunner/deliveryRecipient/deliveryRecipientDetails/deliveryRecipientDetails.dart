import 'package:flutter/material.dart';
import 'package:pickme_mobile/pages/modules/deliveries/deliveryRunner/deliveryRecipient/deliveryRecipientOverview/deliveryRecipientOverview.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';

import 'widget/deliveryRecipientDetailsWidget.dart';

class DeliveryRecipientDetails extends StatefulWidget {
  final RideMapNextAction rideMapNextAction;
  final ServicePurpose servicePurpose;
  final Map<dynamic, dynamic> deliveryAddresses;

  const DeliveryRecipientDetails({
    super.key,
    required this.rideMapNextAction,
    required this.servicePurpose,
    required this.deliveryAddresses,
  });

  @override
  State<DeliveryRecipientDetails> createState() => _DeliveryRecipientDetailsState();
}

class _DeliveryRecipientDetailsState extends State<DeliveryRecipientDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = new TextEditingController();
  final _phoneController = new TextEditingController();
  final _packageController = new TextEditingController();
  final _deliveryInstructionController = new TextEditingController();

  FocusNode? _deliveryInstructionFocusNode, _phoneFocusNode, _nameFocusNode;

  @override
  void initState() {
    super.initState();
    _deliveryInstructionFocusNode = new FocusNode();
    _phoneFocusNode = new FocusNode();
    _nameFocusNode = new FocusNode();

    _phoneController.text = "+233 ";
    _phoneController.addListener(() {
      if (!_phoneController.text.startsWith("+233 ")) {
        // Store the current text length
        final previousTextLength = _phoneController.text.length;
        // Update the text to start with "+233 "
        _phoneController.value = const TextEditingValue(
          text: "+233 ",
          // Ensure the cursor is placed at the end of the text
          selection: TextSelection.collapsed(offset: 5),
        );
        // Move the cursor to the end of the previous text, if any
        if (previousTextLength > 5) {
          _phoneController.selection = TextSelection.collapsed(offset: previousTextLength);
        }
      }
    });
  }

  @override
  void dispose() {
    _deliveryInstructionFocusNode!.dispose();
    _phoneFocusNode!.dispose();
    _nameFocusNode!.dispose();
    super.dispose();
  }

  void _unFocusAllNode() {
    _deliveryInstructionFocusNode!.unfocus();
    _phoneFocusNode!.unfocus();
    _nameFocusNode!.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (widget.servicePurpose == ServicePurpose.deliveryRunnerMultiple)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add_box),
              color: BColors.primaryColor1,
              iconSize: 50,
            ),
        ],
      ),
      body: deliveryRecipientDetailsWidget(
        context: context,
        key: _formKey,
        nameController: _nameController,
        phoneController: _phoneController,
        packageController: _packageController,
        deliveryInstructionController: _deliveryInstructionController,
        deliveryInstructionFocusNode: _deliveryInstructionFocusNode,
        phoneFocusNode: _phoneFocusNode,
        nameFocusNode: _nameFocusNode,
        onSubmit: () => _onSubmit(),
        deliveryAddresses: widget.deliveryAddresses,
        onPackageType: () {},
        rideMapNextAction: widget.rideMapNextAction,
      ),
    );
  }

  void _onSubmit() {
    _unFocusAllNode();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryRecipientOverview(
          rideMapNextAction: widget.rideMapNextAction,
          servicePurpose: widget.servicePurpose,
          deliveryAddresses: widget.deliveryAddresses,
        ),
      ),
    );
  }
}
