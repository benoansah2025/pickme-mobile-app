import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/models/cancelReasonsModel.dart';
import 'package:pickme_mobile/providers/cancelReasonsProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/styles.dart';

AlertDialog cancelRequestDialog({
  required BuildContext context,
  required void Function() onCancelRequest,
  required void Function(CancelReasonData data) onSelectReason,
  required CancelReasonData? reason,
}) {
  return AlertDialog(
    title: Text("You are about to cancel request, select Reason", style: Styles.h6BlackBold),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var data in cancelReasonsModel!.data!) ...[
          ListTile(
            tileColor: BColors.background,
            onTap: () => onSelectReason(data),
            title: Text(
              data.title!,
              style: Styles.h5BlackBold,
            ),
            leading: Checkbox(
              value: reason?.id == data.id,
              onChanged: (value) => onSelectReason(data),
              activeColor: BColors.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 20),
        button(
          onPressed: onCancelRequest,
          text: "Cancel Request",
          color: BColors.primaryColor,
          context: context,
          height: 40,
        )
      ],
    ),
  );
}
