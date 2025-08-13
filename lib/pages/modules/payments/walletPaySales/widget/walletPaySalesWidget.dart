import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/components/passwordField.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/salesSummaryModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'walletPaySalesWidgetAppBar.dart';

Widget walletPaySalesWidget({
  @required BuildContext? context,
  @required void Function()? onPayment,
  required TextEditingController codeController,
  required FocusNode codeFocusNode,
  required SalesSummaryData? data,
  required String paymentType,
  required void Function(String type) onPaymentType,
  required void Function() onPaymentForOthers,
  required TextEditingController benController,
  required FocusNode benFocusNode,
  required bool isPayForOthers,
  required void Function() onBeneficialInfo,
  required void Function() onChangeBeneficial,
  required WorkersInfoModel? beneficialInfo,
}) {
  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      return <Widget>[const WalletPaySalesWidget()];
    },
    body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            if (beneficialInfo != null || (data != null && !isPayForOthers)) ...[
              Container(
                decoration: BoxDecoration(
                  color: BColors.assDeep1,
                  border: Border.all(color: BColors.assDeep),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: BColors.primaryColor1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_outlined, color: BColors.white),
                  ),
                  title: Text("Sales Amount", style: Styles.h6Black),
                  subtitle: Text(
                    beneficialInfo?.data?.amountToPayDaily ?? data?.amountToPayDaily ?? "N/A",
                    style: Styles.h3BlackBold,
                  ),
                  // trailing: Container(
                  //   color: BColors.primaryColor1,
                  //   padding: const EdgeInsets.all(5),
                  //   child: Text("Penalty", style: Styles.h6WhiteBold),
                  // ),
                ),
              ),
              const SizedBox(height: 30),
            ],
            // only show if user is only to pay for others
            if (data == null && isPayForOthers && beneficialInfo == null) ...[
              Text("Beneficiary Phone number", style: Styles.h6Black),
              const SizedBox(height: 10),
              textFormField(
                hintText: "Enter your number",
                controller: benController,
                focusNode: benFocusNode,
                validateMsg: Strings.requestField,
                inputType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
            ],
            Text("Payment Type", style: Styles.h6Black),
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
            if (beneficialInfo != null) ...[
              const SizedBox(height: 20),
              Text("Beneficiary Info", style: Styles.h6Black),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: beneficialInfo.data!.picture != null
                    ? circular(
                        child: cachedImage(
                          context: context,
                          image: "${beneficialInfo.data!.picture}",
                          height: 60,
                          width: 60,
                          placeholder: Images.defaultProfilePicOffline,
                        ),
                        size: 60,
                      )
                    : CircleAvatar(
                        backgroundColor: BColors.white,
                        radius: 30,
                        child: Text(
                          getDisplayName(username: beneficialInfo.data!.name),
                          style: Styles.h3BlackBold,
                        ),
                      ),
                title: Text(
                  "${beneficialInfo.data!.name}",
                  style: Styles.h4BlackBold,
                ),
                subtitle: Text(benController.text, style: Styles.h6Black),
                trailing: CircleAvatar(
                  backgroundColor: BColors.primaryColor,
                  child: IconButton(
                    onPressed: onChangeBeneficial,
                    icon: const Icon(Icons.edit),
                    color: BColors.white,
                  ),
                ),
              ),
            ],
            // only show if user is only to pay for both him and others
            if (data != null && isPayForOthers && beneficialInfo == null) ...[
              const SizedBox(height: 20),
              Text("Beneficiary Phone number", style: Styles.h6Black),
              const SizedBox(height: 10),
              textFormField(
                hintText: "Enter your number",
                controller: benController,
                focusNode: benFocusNode,
                validateMsg: Strings.requestField,
                inputType: TextInputType.phone,
              ),
            ],
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
            const SizedBox(height: 20),
            if (data != null)
              button(
                onPressed: onPaymentForOthers,
                text: isPayForOthers ? "Pay for myself" : "Pay for others",
                color: BColors.white,
                context: context,
                textColor: BColors.primaryColor1,
              ),
            const SizedBox(height: 10),
            button(
              onPressed: isPayForOthers && beneficialInfo == null ? onBeneficialInfo : onPayment,
              text: isPayForOthers && beneficialInfo == null ? "Search" : "Pay",
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
