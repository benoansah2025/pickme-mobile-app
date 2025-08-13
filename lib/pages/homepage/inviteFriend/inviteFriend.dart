import 'package:flutter/material.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/pages/homepage/inviteFriend/widget/inviteFriendWidget.dart';

class InviteFriends extends StatefulWidget {
  const InviteFriends({super.key});

  @override
  State<InviteFriends> createState() => _InviteFriendsState();
}

class _InviteFriendsState extends State<InviteFriends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: inviteFriendWidget(
        context: context,
        onInviteFriend: () => inviteFrinds(),
      ),
    );
  }
}
