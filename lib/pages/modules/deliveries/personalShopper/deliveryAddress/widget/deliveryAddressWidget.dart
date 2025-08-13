import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget deliveryAddressWidget({
  required void Function() onDelete,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("Delivery Addresses", style: Styles.h5BlackBold),
          const SizedBox(height: 20),
          for (int x = 0; x < 4; ++x) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: BColors.background,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: BColors.primaryColor),
                    ),
                    child: const Icon(
                      Icons.circle,
                      color: BColors.primaryColor,
                      size: 15,
                    ),
                  ),
                  title: Text(
                    "Nii Haruna Quaye Street 33",
                    style: Styles.h5BlackBold,
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      FeatherIcons.trash2,
                      color: BColors.black,
                    ),
                    onPressed: () => onDelete(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    ),
  );
}
