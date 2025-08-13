import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

class ApplicationStatusAppBar extends StatelessWidget {
  const ApplicationStatusAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: BColors.primaryColor,
      pinned: true,
      expandedHeight: 100,
      iconTheme: const IconThemeData(color: BColors.white),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text("Business Profile", style: Styles.h4WhiteBold),
        titlePadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
