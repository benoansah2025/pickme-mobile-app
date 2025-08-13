import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/emptyBox.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: BColors.white),
        backgroundColor: BColors.primaryColor,
        title: Text("Favorite", style: Styles.h4WhiteBold),
      ),
      body: emptyBox(context),
    );
  }
}
