import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget accountSettingsWidget({
  required BuildContext context,
  required void Function() onEdit,
  required void Function() onResetPassword,
  required void Function() onSetPaymentPincode,
  required void Function() onRate,
  required void Function() onFeedback,
  required void Function() onTerms,
  required void Function() onLogout,
  required void Function() onDeleteAccount,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Account Settings", style: Styles.h5BlackBold),
          const SizedBox(height: 20),
          ListTile(
            leading: userModel?.data!.user!.picture != null
                ? circular(
                    child: cachedImage(
                      context: context,
                      image: "${userModel!.data!.user!.picture}",
                      height: 60,
                      width: 60,
                      placeholder: Images.defaultProfilePicOffline,
                    ),
                    size: 60,
                  )
                : CircleAvatar(
                    backgroundColor: BColors.primaryColor,
                    radius: 30,
                    child: Text(
                      getDisplayName(),
                      style: Styles.h3WhiteBold,
                    ),
                  ),
            title: Text(
              "${userModel!.data!.user!.name}",
              style: Styles.h4BlackBold,
            ),
            subtitle: Text(
              "${userModel!.data!.user!.phone}",
              style: Styles.h6Black,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: onEdit,
              color: BColors.primaryColor,
            ),
          ),
          const Divider(),
          if (userModel!.data!.user!.email != null) ...[
            const SizedBox(height: 10),
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              onTap: onResetPassword,
              leading: Image.asset(Images.reset),
              title: Text("Reset Password", style: Styles.h4BlackBold),
              subtitle: Text("Change your password", style: Styles.h6Black),
            ),
          ],
          const SizedBox(height: 30),
          Text("General", style: Styles.h5BlackBold),
          const SizedBox(height: 20),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            onTap: onSetPaymentPincode,
            leading: Image.asset(Images.rate),
            title: Text(
              "${userModel!.data!.user!.paymentPin == Properties.defaultPaymentPin ? 'Set' : 'Reset'}  Payment Pincode",
              style: Styles.h4BlackBold,
            ),
            subtitle: Text(
              "Pin required to approve wallet transactions",
              style: Styles.h6Black,
            ),
          ),
          const Divider(),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            onTap: onRate,
            leading: Image.asset(Images.rate),
            title: Text("Rate our app", style: Styles.h4BlackBold),
            subtitle: Text(
              "Let us know how you feel about the app ",
              style: Styles.h6Black,
            ),
          ),
          const Divider(),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            onTap: onFeedback,
            leading: Image.asset(Images.feedback),
            title: Text("Leave Feedback ", style: Styles.h4BlackBold),
            subtitle: Text(
              "Let us know how you feel about the app ",
              style: Styles.h6Black,
            ),
          ),
          const Divider(),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            onTap: onTerms,
            leading: Image.asset(Images.tnc),
            title: Text("Terms and conditions ", style: Styles.h4BlackBold),
            subtitle: Text(
              "Let us know how you feel about the app ",
              style: Styles.h6Black,
            ),
          ),
          const Divider(),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            onTap: onDeleteAccount,
            leading: const Icon(
              FeatherIcons.trash2,
              color: BColors.primaryColor,
            ),
            title: Text("Delete Account", style: Styles.h4BlackBold),
            subtitle: Text(
              "Delete your account from ${Properties.titleFull}",
              style: Styles.h6Black,
            ),
          ),
          const SizedBox(height: 20),
          button(
            onPressed: onLogout,
            text: "Logout",
            color: BColors.primaryColor,
            context: context,
            buttonRadius: 20,
            colorFill: false,
            textColor: BColors.primaryColor,
          ),
          const SizedBox(height: 30),
        ],
      ),
    ),
  );
}
