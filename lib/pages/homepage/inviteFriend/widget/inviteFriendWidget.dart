import 'package:flutter/material.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/pages/homepage/inviteFriend/widget/inviteFriendAppBar.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget inviteFriendWidget({
  required BuildContext context,
  required void Function() onInviteFriend,
}) {
  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      return <Widget>[const InviteFriendAppBar()];
    },
    body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Image.asset(Images.inviteFriends, width: 250),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  border: DashedBorder.fromBorderSide(
                    dashLength: 10,
                    side: BorderSide(
                      color: BColors.primaryColor1,
                      width: 1,
                    ),
                  ),
                ),
                child: Text("${userModel!.data!.user!.userid}", style: Styles.h2Black),
              ),
              const SizedBox(height: 30),
              Text(
                "Get your friends on board and get credited with a referral amount on your wallet after their first successful ride/delivery ",
                style: Styles.h5Black,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              button(
                onPressed: onInviteFriend,
                text: "Invite Friends",
                color: BColors.primaryColor,
                context: context,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
