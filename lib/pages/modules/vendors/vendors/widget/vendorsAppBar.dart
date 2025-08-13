import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

class VendorAppBar extends StatelessWidget {
  const VendorAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      iconTheme: const IconThemeData(color: BColors.white),
      backgroundColor: BColors.primaryColor,
      pinned: true,
      expandedHeight: 150,
      centerTitle: false,
      title: Text("Accredited Vendors", style: Styles.h4WhiteBold),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          margin: const EdgeInsets.only(top: 80),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Search for pickme Accredited Vendors and get their contact details to place your orders with them",
            style: Styles.h6White,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(
          height: 15,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: BColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
