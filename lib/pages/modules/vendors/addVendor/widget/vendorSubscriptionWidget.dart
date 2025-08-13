import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/emptyBox.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/components/passwordField.dart';
import 'package:pickme_mobile/models/subscriptionsModel.dart';
import 'package:pickme_mobile/providers/subscriptionsProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget vendorSubscriptionWidget({
  required BuildContext context,
  required ScrollController? scrollController,
  required void Function(SubscriptionData data) onSubscriptionInfo,
  required void Function(SubscriptionData data) onSubscription,
  required SubscriptionData? selectedSubscription,
  required String paymentType,
  required void Function(String type) onPaymentType,
  required TextEditingController codeController,
  required FocusNode codeFocusNode,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Subscriptions", style: Styles.h3BlackBold),
          const SizedBox(height: 20),
          StreamBuilder(
            stream: subscriptionsStream,
            initialData: subscriptionsModel,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.ok! && snapshot.data!.data != null) {
                  return Column(
                    children: [
                      for (SubscriptionData data in snapshot.data!.data!)
                        GestureDetector(
                          onTap: () => onSubscription(data),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: selectedSubscription?.id == data.id
                                  ? BColors.primaryColor.withOpacity(.2)
                                  : BColors.assDeep1,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 5),
                              title: Text(data.name ?? "N/A", style: Styles.h5BlackBold),
                              subtitle: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.description ?? "N/A",
                                    style: Styles.h6Black,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${Properties.curreny} ${data.price ?? "N/A"}",
                                        style: Styles.h5BlackBold,
                                      ),
                                      Text(
                                        "${data.durationDays ?? "N/A"} days",
                                        style: Styles.h6BlackBold,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.info_outline,
                                  color: BColors.primaryColor1,
                                ),
                                onPressed: () => onSubscriptionInfo(data),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }
              } else if (snapshot.hasError) {
                return emptyBox(context, msg: "No data available");
              }
              return Center(
                child: loadingDoubleBounce(BColors.primaryColor),
              );
            },
          ),
          const SizedBox(height: 10),
          Text("Payment Type", style: Styles.h6BlackBold),
          const SizedBox(height: 10),
          ListTile(
            onTap: () => onPaymentType("momo"),
            tileColor: BColors.assDeep1,
            title: Text("MOMO", style: Styles.h4BlackBold),
            trailing: paymentType == "momo"
                ? const Icon(Icons.check_box, color: BColors.primaryColor1)
                : const Icon(Icons.check_box_outline_blank_sharp, color: BColors.black),
          ),
          const SizedBox(height: 5),
          ListTile(
            onTap: () => onPaymentType("wallet"),
            tileColor: BColors.assDeep1,
            title: Text("WALLET", style: Styles.h4BlackBold),
            trailing: paymentType == "wallet"
                ? const Icon(Icons.check_box, color: BColors.primaryColor1)
                : const Icon(Icons.check_box_outline_blank_sharp, color: BColors.black),
          ),
          if (paymentType == "wallet") ...[
            const SizedBox(height: 20),
            Text("Payment Pincode", style: Styles.h6Black),
            const SizedBox(height: 10),
            PasswordField(
              hintText: "Enter your code",
              controller: codeController,
              focusNode: codeFocusNode,
              validateMsg: Strings.requestField,
              inputType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    ),
  );
}
