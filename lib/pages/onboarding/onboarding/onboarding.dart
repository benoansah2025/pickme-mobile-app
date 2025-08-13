import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/customLoading.dart';
import 'package:pickme_mobile/components/toast.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/config/navigation.dart';
import 'package:pickme_mobile/providers/locationProdiver.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';

import 'widget/onboardingBottomWidget.dart';
import 'widget/onboardingWidget.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  // final _kDuration = const Duration(milliseconds: 300);
  // final _kCurve = Curves.ease;
  final _controller = new PageController();

  int _pageNum = 0;
  // double _currentPageValue = 0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        // _currentPageValue = _controller.page!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> onboardPage = [
      onboardingWidget(
        context: context,
        image: Images.onboarding1,
        title: 'Request Ride',
        subtitle: 'Request a ride and get picked up by a nearby  driver',
      ),
      onboardingWidget(
        context: context,
        image: Images.onboarding2,
        title: 'Make Deliveries ',
        subtitle: 'Get your parcel delivered safely \nand fast',
      ),
      onboardingWidget(
        context: context,
        image: Images.onboarding3,
        title: 'Heya Welcome',
        subtitle: 'Choose your location to let riders \nfind you easily',
        isLastPage: true,
        onCurrentLocation: () => _onCurrentLocation(),
        onSelectManually: () => _onCurrentLocation(),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: onboardPage.length,
              itemBuilder: (BuildContext context, int index) {
                // return Transform(
                //   transform: Matrix4.identity()
                //     ..rotateX(_currentPageValue - index),
                //   child: onboardPage[index % onboardPage.length],
                // );
                return onboardPage[index % onboardPage.length];
              },
              onPageChanged: (index) {
                setState(() {
                  _pageNum = index;
                });
              },
            ),
            onboardingBottomWidget(
              context: context,
              pageNum: _pageNum,
              onSkip: () => _controller.jumpToPage(3),
            ),
            if (_isLoading) customLoadingPage(),
          ],
        ),
      ),
    );
  }

  Future<void> _onCurrentLocation() async {
    bool permissionGranted = await handleLocationPermission();
    if (permissionGranted) {
      setState(() => _isLoading = true);
      await LocationProvider().getCurrentLocation();
      setState(() => _isLoading = false);
      if (!mounted) return;
      navigation(context: context, pageName: "login");
    } else {
      toastContainer(
        text: "Allow location permission to help us get available cars near you",
        backgroundColor: BColors.red,
      );
    }
  }
}
