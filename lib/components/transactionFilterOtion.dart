import 'package:flutter/material.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget transactionFilterOption({
  required String label,
  required bool isSelected,
  required VoidCallback? onTap,
  Widget? icon,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minWidth: 30),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: isSelected
            ? const Border(
                bottom: BorderSide(
                  color: BColors.primaryColor,
                  width: 2,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: isSelected ? Styles.h5PrimaryBold : Styles.h5BlackBold,
          ),
          if (icon != null) ...[
            const SizedBox(width: 10),
            icon,
          ],
        ],
      ),
    ),
  );
}
