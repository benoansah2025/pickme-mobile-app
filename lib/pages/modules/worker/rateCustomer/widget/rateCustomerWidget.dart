import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/components/ratingStar.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';
import 'package:pickme_mobile/models/driverRequestModel.dart';
import 'package:pickme_mobile/models/feeModel.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget rateCustomerWidget({
  required BuildContext context,
  required double rate,
  required void Function(double rate) onRate,
  required void Function() onSubmit,
  required TextEditingController commentController,
  required FocusNode commentFocusNode,
  required ServicePurpose servicePurpose,
  required FeeModel feeModel,
  required DriverRequestModel? requestModel,
}) {
  return Center(
    child: SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 10),
            Text(
              "${Properties.curreny} ${feeModel.data!.grandTotal}",
              style: Styles.h1BlackBold,
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              color: BColors.background,
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .6,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: circular(
                    child: cachedImage(
                      context: context,
                      image: requestModel?.currentRideDetails?.riderPicture,
                      height: 50,
                      width: 50,
                      placeholder: Images.defaultProfilePicOffline,
                    ),
                    size: 50,
                  ),
                  title: Text(requestModel?.currentRideDetails?.riderName ?? "N/A", style: Styles.h4BlackBold),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: BColors.primaryColor1),
                      const SizedBox(width: 10),
                      FutureBuilder(
                        future: getHive("riderRating"),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(snapshot.data, style: Styles.h6BlackBold);
                          } else if (snapshot.hasError) {
                            return Text("N/A", style: Styles.h6BlackBold);
                          }

                          return loadingDoubleBounce(BColors.primaryColor, size: 20);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              servicePurpose == ServicePurpose.ride ? "Rate Passenger" : "Rate Customer",
              style: Styles.h3BlackBold,
            ),
            const SizedBox(height: 10),
            Text(
              servicePurpose == ServicePurpose.ride
                  ? "Your feedback will help improve drivers experience"
                  : "Your feedback will help improve customer's performance",
              style: Styles.h5Black,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ratingStar(
              rate: rate,
              function: (double rate) => onRate(rate),
              size: 50,
            ),
            const SizedBox(height: 30),
            // textFormField(
            //   hintText: "Additional comments...",
            //   controller: commentController,
            //   focusNode: commentFocusNode,
            //   maxLine: null,
            //   minLine: 4,
            // ),
            // const SizedBox(height: 20),
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
