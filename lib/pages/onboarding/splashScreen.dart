import 'package:flutter/foundation.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:flutter/material.dart';
import 'package:pickme_mobile/config/checkSession.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkSession().then((status) async {
      if (kDebugMode) {
        print(status);
      }
      if (status == "auth") {
        navigation(context: context, pageName: "homepage");
      } else {
        //check if user is authenticated
        navigation(context: context, pageName: "onboarding");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.white,
      body: Stack(
        children: [
          Image.asset(
            Images.splash,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(Images.logo, scale: 1.2),
                const SizedBox(height: 20),
                Text(Properties.titleFull.toUpperCase(), style: Styles.h4BlackBold),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Not just a",
                  style: Styles.h6Black,
                  children: [
                    TextSpan(
                      text: " Business",
                      style: Styles.h6BlackBold,
                    ),
                    TextSpan(
                      text: ", but a",
                      style: Styles.h6Black,
                    ),
                    TextSpan(
                      text: " DIFFERENCE\n\n",
                      style: Styles.h6BlackBold,
                    ),
                    TextSpan(
                      text: "Powered by: 2.H.R.S",
                      style: Styles.h6BlackBold,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
