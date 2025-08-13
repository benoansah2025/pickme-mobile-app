import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget promotionWidget({
  required BuildContext context,
  required void Function() onMarkAsRead,
}) {
  return SingleChildScrollView(
    child: Column(
      children: [
        ListTile(
          title: Text("Today's Promotion ", style: Styles.h5Black),
        ),
        for (int x = 0; x < 2; ++x)
          _layout(
            title: "FunRider",
            subtitle: "Get 20 rides or more today and get 20% discount on your sales",
            isToday: true,
            currentNumber: 3,
            totalNumber: 20,
          ),
        const SizedBox(height: 20),
        ListTile(
          title: Text("All Time Promotions ", style: Styles.h5Black),
        ),
        for (int x = 0; x < 5; ++x)
          _layout(
            title: "Findme Rider",
            subtitle: "Get 5 search request at a particular location and gain 100% discount on your sales",
            currentNumber: 1,
            totalNumber: 5,
          ),
        const SizedBox(height: 20),
      ],
    ),
  );
}

Widget _layout({
  required String title,
  required String subtitle,
  required int currentNumber,
  required int totalNumber,
  bool isToday = false,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    color: isToday ? BColors.primaryColor.withOpacity(.04) : BColors.primaryColor1.withOpacity(.04),
    child: ListTile(
      leading: Image.asset(Images.promotion),
      title: Text(title, style: Styles.h4BlackBold),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: Styles.h6Black,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              LinearProgressIndicator(
                value: currentNumber / totalNumber,
                minHeight: 20,
                color: isToday ? BColors.primaryColor : BColors.primaryColor1,
                borderRadius: BorderRadius.circular(10),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    "$currentNumber/$totalNumber",
                    style: Styles.h6Black,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    ),
  );
}
