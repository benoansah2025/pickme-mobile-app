import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';

import 'button.dart';

class CongratPage extends StatelessWidget {
  final Widget? widget;
  final void Function(BuildContext context)? onHome;
  final String? homeButtonText;
  final bool fillBottomButton;

  const CongratPage({
    super.key,
    @required this.widget,
    @required this.onHome,
    this.homeButtonText = "Go back to homepage",
    this.fillBottomButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool invoke) {
        if (invoke) {
          return;
        }
      },
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Images.correct, width: 300),
              const SizedBox(height: 20),
              if (widget != null) widget!,
              const SizedBox(height: 15),
              button(
                onPressed: () => onHome!(context),
                text: homeButtonText,
                color: BColors.primaryColor,
                colorFill: fillBottomButton,
                context: context,
                textColor: fillBottomButton ? BColors.white : BColors.primaryColor,
                showBorder: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
