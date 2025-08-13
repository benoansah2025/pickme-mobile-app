import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget registrationSelectServiceWidget({
  required BuildContext context,
  required List<Map<String, dynamic>> serviceList,
  required void Function(int index) onInfo,
  required void Function(int index) onService,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text("Rendering Services", style: Styles.h3BlackBold),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: "Choose from the services below  what you’ll be rendering. ",
              style: Styles.h5Black,
              children: [
                TextSpan(
                  text: "Note: You can select more than one, but your first choice will be your main Job.",
                  style: Styles.h5BlackBold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (int x = 0; x < serviceList.length; ++x)
            _layout(
              onInfo: () => onInfo(x),
              title: serviceList[x]['title'],
              image: serviceList[x]['image'],
              isCheck: serviceList[x]['check'],
              onTap: () => onService(x),
            ),
        ],
      ),
    ),
  );
}

Widget _layout({
  required void Function() onInfo,
  required void Function() onTap,
  required String title,
  required String image,
  required bool isCheck,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Card(
        elevation: 5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: double.infinity,
            height: 170,
            child: Stack(
              children: [
                Image.asset(
                  image,
                  width: double.infinity,
                  height: 170,
                  fit: BoxFit.fitHeight,
                ),
                // Container(
                //   width: double.infinity,
                //   height: 170,
                //   color: BColors.black.withOpacity(.3),
                // ),
                Container(
                  width: double.infinity,
                  height: 170,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: Styles.h3BlackBold,
                          ),
                          Icon(
                            isCheck ? Icons.check_circle : Icons.circle_outlined,
                            color: isCheck ? BColors.primaryColor : BColors.black,
                            size: 35,
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: onInfo,
                          icon: const Icon(Icons.info, size: 30),
                          color: BColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
