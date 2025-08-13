import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/passwordField.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/strings.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget deleteAccountWidget({
  @required BuildContext? context,
  @required void Function(int index)? onSelectReason,
  @required void Function()? onDelete,
  @required TextEditingController? reasonController,
  @required TextEditingController? passwordController,
  @required FocusNode? reasonFocusNode,
  @required FocusNode? passwordFocusNode,
  @required List<Map<String, dynamic>>? reasonList,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          for (int x = 0; x < reasonList!.length; ++x) ...[
            ListTile(
              onTap: () => onSelectReason!(x),
              title: Text(
                reasonList[x]["reason"],
                style: Styles.h5BlackBold,
              ),
              leading: Checkbox(
                value: reasonList[x]["selected"],
                onChanged: (value) => onSelectReason!(x),
                activeColor: BColors.primaryColor,
              ),
            ),
          ],
          if (reasonList.last["selected"]) ...[
            const SizedBox(height: 10),
            textFormField(
              hintText: "Type reason here",
              controller: reasonController,
              focusNode: reasonFocusNode,
              minLine: 4,
              maxLine: null,
            ),
          ],
          const SizedBox(height: 20),
          Text("Password", style: Styles.h5BlackBold),
          const SizedBox(height: 10),
          PasswordField(
            hintText: "Enter your password",
            controller: passwordController,
            validateMsg: Strings.requestField,
            focusNode: passwordFocusNode,
          ),
          const SizedBox(height: 20),
          button(
            onPressed: onDelete,
            text: "Delete",
            color: BColors.red,
            context: context,
            textColor: BColors.white,
          ),
        ],
      ),
    ),
  );
}
