import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/components/ratingStar.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget rateRideWidget({
  required BuildContext context,
  required double rate,
  required void Function(double rate) onRate,
  required void Function() onSubmit,
  required TextEditingController commentController,
  required FocusNode commentFocusNode,
  required ServicePurpose servicePurpose,
  required TripDetailsModel tripDetailsModel,
  required WorkersInfoModel? workerDetailsInfoModel,
}) {
  return Center(
    child: SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: circular(
                child: cachedImage(
                  context: context,
                  image: "${tripDetailsModel.driverPhoto}",
                  height: 50,
                  width: 50,
                  placeholder: Images.defaultProfilePicOffline,
                ),
                size: 50,
              ),
              title: Text(tripDetailsModel.driverName!, style: Styles.h4BlackBold),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: BColors.primaryColor1),
                  const SizedBox(width: 10),
                  workerDetailsInfoModel == null
                      ? loadingDoubleBounce(BColors.primaryColor, size: 20)
                      : Text(
                          "${workerDetailsInfoModel.data != null ? workerDetailsInfoModel.data!.rating : 'N/A'}",
                          style: Styles.h6BlackBold,
                        ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              servicePurpose == ServicePurpose.ride
                  ? "How was your trip?"
                  : servicePurpose == ServicePurpose.personalShopper
                      ? "Rate Shopper"
                      : "Rate Delivery Guy",
              style: Styles.h3BlackBold,
            ),
            const SizedBox(height: 20),
            Text(
              "Your feedback will help improve ${servicePurpose == ServicePurpose.ride ? 'driving experience' : servicePurpose == ServicePurpose.personalShopper ? 'shopper\'s performance' : 'Delivery guy\'s performance'}",
              style: Styles.h5Black,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ratingStar(
              rate: rate,
              function: (double rate) => onRate(rate),
              size: 50,
            ),
            const SizedBox(height: 40),
            textFormField(
              hintText: "Additional comments...",
              controller: commentController,
              focusNode: commentFocusNode,
              maxLine: null,
              minLine: 6,
            ),
            const SizedBox(height: 30),
            button(
              onPressed: onSubmit,
              text: "Submit Review",
              color: BColors.primaryColor,
              context: context,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
