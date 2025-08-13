import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

class WorkerDeliveryRunnerSingleRequestDialog extends StatefulWidget {
  final VoidCallback onReject;
  final VoidCallback onAccept;
  final int remainTimeInSec;

  const WorkerDeliveryRunnerSingleRequestDialog({
    required this.onReject,
    required this.onAccept,
    required this.remainTimeInSec,
    super.key,
  });

  @override
  State<WorkerDeliveryRunnerSingleRequestDialog> createState() => _WorkerDeliveryRunnerSingleRequestDialogState();
}

class _WorkerDeliveryRunnerSingleRequestDialogState extends State<WorkerDeliveryRunnerSingleRequestDialog> {
  int remainTime = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    remainTime = widget.remainTimeInSec;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainTime == 0) {
          timer.cancel();
          widget.onReject();
        } else {
          remainTime--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: double.maxFinite,
        decoration: const BoxDecoration(
          color: BColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 20),
            ListTile(
              title: Text("Incoming Request", style: Styles.h6BlackBold),
              trailing: Text(
                "${Properties.curreny} 45.00",
                style: Styles.h3BlackBold,
              ),
            ),
            const SizedBox(height: 10),
            Text("sender’s details".toUpperCase(), style: Styles.h6Black),
            const SizedBox(height: 10),
            Container(
              color: BColors.background,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: circular(
                  child: cachedImage(
                    context: context,
                    image: "",
                    height: 50,
                    width: 50,
                    placeholder: Images.defaultProfilePicOffline,
                  ),
                  size: 50,
                ),
                title: Text("Gregory Smith", style: Styles.h4BlackBold),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: BColors.yellow1),
                    const SizedBox(width: 10),
                    Text("4.9", style: Styles.h6Black),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: const EdgeInsets.only(left: 40),
              title: Text("package type".toUpperCase(), style: Styles.h6Black),
              subtitle: Text("Parcel", style: Styles.h4BlackBold),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: BColors.primaryColor),
                ),
                child: const Icon(
                  Icons.circle,
                  color: BColors.primaryColor,
                  size: 15,
                ),
              ),
              title: Text(
                "Sender's location".toUpperCase(),
                style: Styles.h6Black,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text("4 min (1 mile) away", style: Styles.h6BlackBold),
                  Text(
                    "Melcom chambers street",
                    style: Styles.h4Black,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.location_on,
                color: BColors.primaryColor1,
              ),
              title: Text(
                "receiver Location".toUpperCase(),
                style: Styles.h6Black,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text("30 min (8 miles) trip", style: Styles.h6BlackBold),
                  Text(
                    "West Hills Mall, Kasoa, Eden Height ST",
                    style: Styles.h4Black,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: circular(
                child: cachedImage(
                  context: context,
                  image: "",
                  height: 50,
                  width: 50,
                  placeholder: Images.defaultProfilePicOffline,
                ),
                size: 50,
              ),
              title: Text("Gregory Smith", style: Styles.h4BlackBold),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: BColors.yellow1),
                  const SizedBox(width: 10),
                  Text("4.9", style: Styles.h6Black),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                button(
                  onPressed: widget.onReject,
                  text: "Reject $remainTime",
                  color: BColors.primaryColor1,
                  context: context,
                  divideWidth: .45,
                  colorFill: false,
                  backgroundcolor: BColors.white,
                  textColor: BColors.primaryColor1,
                  borderWidth: 2,
                ),
                button(
                  onPressed: widget.onAccept,
                  text: "Accept",
                  color: BColors.primaryColor,
                  context: context,
                  divideWidth: .45,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
