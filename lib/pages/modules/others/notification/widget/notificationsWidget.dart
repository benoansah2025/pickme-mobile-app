import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/models/notificationsModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget notificationsWidget({
  required BuildContext context,
  required void Function() onMarkAsRead,
  required NotificationsModel notificationsModel,
  required void Function(NotificationData data) onNotification,
}) {
  List<NotificationData> notificationData = [];
  for (var data in notificationsModel.notificationData!) {
    notificationData.add(data);
    for (var todayData in notificationsModel.todayNotifiactionData!) {
      if (data.key == todayData.key) {
        notificationData.remove(data);
      }
    }
  }

  return ListView(
    children: [
      if (notificationsModel.todayNotifiactionData!.isNotEmpty) ...[
        ListTile(
          title: Text("New", style: Styles.h5Black),
          trailing: button(
            onPressed: onMarkAsRead,
            text: "Mark all as read",
            color: BColors.white,
            context: context,
            height: 30,
            padding: EdgeInsets.zero,
            useWidth: false,
            textColor: BColors.primaryColor,
            textStyle: Styles.h6BlackBold,
          ),
        ),
        for (var data in notificationsModel.todayNotifiactionData!)
          GestureDetector(
            onTap: () => onNotification(data),
            child: _layout(
              title: data.title ?? "N/A",
              subtitle: data.body ?? "N/A",
              time: data.timeAgo ?? "N/A",
              isRead: data.read ?? false,
            ),
          ),
        const SizedBox(height: 20),
      ],
      if (notificationData.isNotEmpty) ...[
        ListTile(title: Text("Older Messages", style: Styles.h5Black)),
        for (var data in notificationData)
          GestureDetector(
             onTap: () => onNotification(data),
            child: _layout(
              title: data.title ?? "N/A",
              subtitle: data.body ?? "N/A",
              time: data.timeAgo ?? "N/A",
              isRead: data.read ?? false,
            ),
          ),
        const SizedBox(height: 20),
      ],
    ],
  );
}

Widget _layout({
  required String title,
  required String subtitle,
  required String time,
  bool isRead = true,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 3),
    color: isRead ? BColors.white : BColors.primaryColor.withOpacity(.07),
    child: ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: BColors.assDeep.withOpacity(.4),
        child: SvgPicture.asset(
          Images.wallet,
          // ignore: deprecated_member_use
          color: isRead ? BColors.black : BColors.primaryColor,
        ),
      ),
      title: Text(
        title,
        style: Styles.h4BlackBold,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: Styles.h6Black,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        children: [
          Text(time, style: Styles.h6BlackBold),
        ],
      ),
    ),
  );
}
