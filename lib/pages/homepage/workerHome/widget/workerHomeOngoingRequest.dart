import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget workerHomeOngoingRequest({
  @required OngoingRequestLayoutIconEnum? icon,
  @required String? title,
  @required String? from,
  @required String? to,
  required BuildContext context,
  required void Function() onOpen,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    color: BColors.primaryColor1,
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: const VisualDensity(vertical: -3),
      leading: CircleAvatar(
        radius: 15,
        backgroundColor: BColors.assDeep1,
        child: Image.asset(
          icon == OngoingRequestLayoutIconEnum.bIcon1 ? Images.bookingIcon1 : Images.bookingIcon2,
        ),
      ),
      title: Text(title!, style: Styles.h6WhiteBold),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("From: $from", style: Styles.h6White, overflow: TextOverflow.ellipsis),
          Text("To: $to", style: Styles.h6White, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: button(
        onPressed: onOpen,
        text: "Open",
        textColor: BColors.black,
        color: BColors.white,
        context: context,
        useWidth: false,
      ),
    ),
  );
}
