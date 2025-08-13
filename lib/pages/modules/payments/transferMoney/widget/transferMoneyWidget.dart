import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'transferMoneyAppBar.dart';

Widget transferMoneyWidget({
  required BuildContext context,
  required TextEditingController amountController,
  required TextEditingController recieverIdController,
  required FocusNode amountFocusNode,
  required FocusNode recieverIdFocusNode,
  required void Function() onTransferMoney,
  required void Function() onLoadReceiverInfo,
  required void Function() onChangeReceiver,
  required UserModel? receiverInfo,
}) {
  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      return <Widget>[const TranserMoneyAppBar()];
    },
    body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            if (receiverInfo == null) ...[
              Text("Reciever ID / Phone Number", style: Styles.h4BlackBold),
              const SizedBox(height: 10),
              textFormField(
                hintText: "Enter ID or Phone",
                controller: recieverIdController,
                focusNode: recieverIdFocusNode,
              ),
              const SizedBox(height: 10),
              button(
                onPressed: onLoadReceiverInfo,
                text: "Continue",
                color: BColors.primaryColor,
                context: context,
              ),
            ],
            if (receiverInfo != null) ...[
              Text("Receiver Info", style: Styles.h5Black),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: receiverInfo.data!.user!.picture != null
                    ? circular(
                        child: cachedImage(
                          context: context,
                          image: "${receiverInfo.data!.user!.picture}",
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
                          getDisplayName(username: receiverInfo.data!.user!.name),
                          style: Styles.h3BlackBold,
                        ),
                      ),
                title: Text(
                  "${receiverInfo.data!.user!.name}",
                  style: Styles.h4BlackBold,
                ),
                subtitle: Text(
                  "${receiverInfo.data!.user!.phone}",
                  style: Styles.h6Black,
                ),
                trailing: CircleAvatar(
                  backgroundColor: BColors.primaryColor,
                  child: IconButton(
                    onPressed: onChangeReceiver,
                    icon: const Icon(Icons.edit),
                    color: BColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(child: Text("Enter Amount", style: Styles.h4BlackBold)),
              const SizedBox(height: 20),
              Center(child: Text(Properties.curreny, style: Styles.h3BlackBold)),
              const SizedBox(height: 10),
              textFormField(
                hintText: "0.00",
                hintTextStyle: Styles.h1XBlack,
                controller: amountController,
                focusNode: amountFocusNode,
                textStyle: Styles.h1XBlack,
                textAlign: TextAlign.center,
                borderColor: BColors.background,
                inputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              ),
              const SizedBox(height: 30),
              button(
                onPressed: onTransferMoney,
                text: "SEND",
                color: BColors.primaryColor,
                context: context,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
