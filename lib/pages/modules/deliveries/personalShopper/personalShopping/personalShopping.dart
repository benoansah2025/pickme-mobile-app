import 'package:flutter/material.dart';
import 'package:pickme_mobile/pages/modules/deliveries/personalShopper/personalAddItem/personalAddItem.dart';

import 'widget/personalShoppingWidget.dart';

class PersonalShopping extends StatefulWidget {
  const PersonalShopping({super.key});

  @override
  State<PersonalShopping> createState() => _PersonalShoppingState();
}

class _PersonalShoppingState extends State<PersonalShopping> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: personalShoppingWidget(
        context: context,
        onProceed: () => _onProceed(),
      ),
    );
  }

  void _onProceed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PersonalAdditem(),
      ),
    );
  }
}
