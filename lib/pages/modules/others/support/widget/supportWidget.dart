import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget supportWidget({
  required void Function() onSendMessage,
  required void Function() onCall,
  required void Function() onWhatsapp,
  required void Function() onEmail,
  required void Function(String text) onSearch,
  required TextEditingController messageController,
  required FocusNode messageFocusNode,
  required FocusNode searchFocusNode,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text("How do we help you ?", style: Styles.h3BlackBold),
          const SizedBox(height: 20),
          Text(
            "Tell us how we can help you, our experts are standing by to assist you with anything ",
            style: Styles.h6Black,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Text("Start a conversation with us", style: Styles.h4BlackBold),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Reply Time |  ", style: Styles.h6Black),
              const Icon(Icons.watch_later_outlined),
              Text("  A few minutes", style: Styles.h6BlackBold),
            ],
          ),
          const SizedBox(height: 30),
          textFormField(
            hintText: "Send us a message",
            hintTextStyle: Styles.h5Black,
            controller: messageController,
            focusNode: messageFocusNode,
            borderRadius: 30,
            icon: Icons.arrow_circle_right_rounded,
            iconColor: BColors.primaryColor,
            onIconTap: onSendMessage,
            iconSize: 40,
            borderWidth: 1,
            borderColor: BColors.black,
          ),
          const SizedBox(height: 40),
          Text("FAQs", style: Styles.h3BlackBold),
          const SizedBox(height: 20),
          textFormField(
            hintText: "Search",
            controller: null,
            focusNode: searchFocusNode,
            prefixIcon: Icons.search,
            onTextChange: (String text) => onSearch(text),
          ),
          const SizedBox(height: 20),
          for (int x = 0; x < 3; ++x) ...[
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Understanding the delivery concepts",
                style: Styles.h5Black,
              ),
              trailing: const Icon(Icons.arrow_drop_down),
            ),
            const Divider(),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: BColors.primaryColor1.withOpacity(.4),
                child: IconButton(
                  icon: const Icon(Icons.call),
                  color: BColors.primaryColor1,
                  iconSize: 30,
                  onPressed: onCall,
                ),
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor: BColors.primaryColor1.withOpacity(.4),
                child: IconButton(
                  icon: const Icon(Icons.email),
                  color: BColors.primaryColor1,
                  iconSize: 30,
                  onPressed: onEmail,
                ),
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor: BColors.primaryColor1.withOpacity(.4),
                child: IconButton(
                  icon: SvgPicture.asset(Images.whatsapp),
                  color: BColors.primaryColor1,
                  iconSize: 30,
                  onPressed: onWhatsapp,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}
