import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'widget/promotionWidget.dart';

class Promotions extends StatefulWidget {
  const Promotions({super.key});

  @override
  State<Promotions> createState() => _PromotionsState();
}

class _PromotionsState extends State<Promotions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: BColors.white),
        backgroundColor: BColors.primaryColor,
        title: Text("Promotions", style: Styles.h4WhiteBold),
      ),
      body: promotionWidget(
        context: context,
        onMarkAsRead: () {},
      ),
    );
  }
}
