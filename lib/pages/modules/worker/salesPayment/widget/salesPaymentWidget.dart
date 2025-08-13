import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/emptyBox.dart';
import 'package:pickme_mobile/components/shimmerItem.dart';
import 'package:pickme_mobile/components/transactionFilterOtion.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/salesSummaryModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'salesPaymentAppBar.dart';

Widget salesPaymentWidget({
  @required BuildContext? context,
  required void Function(SalesSummaryData data) onPayment,
  required void Function(SalesSummaryData data) onOthersPayment,
  required SalesSummaryModel? model,
  required void Function(String filter)? onSalesFilter,
  required String? filterType,
}) {
  bool show = false;
  for (var _
      in filterType == "My Sales" ? model?.data?.salesPayments!.self ?? [] : model?.data?.salesPayments!.others ?? []) {
    show = true;
    break;
  }

  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      return <Widget>[const SalesPaymentAppBar()];
    },
    body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView(
        children: [
          if (!(model?.paymentDoneToday ?? false) && (model?.data?.allowPayment ?? false)) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: BColors.assDeep1,
                border: Border.all(color: BColors.assDeep),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BColors.primaryColor1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: BColors.white,
                  ),
                ),
                title: Text("Sales Amount", style: Styles.h6Black),
                subtitle: Text(
                  model != null && model.data != null
                      ? "${Properties.curreny} ${model.data!.amountToPayDaily ?? "N/A"}"
                      : "Loading...",
                  style: Styles.h3BlackBold,
                ),
                trailing: model != null && model.data != null && !model.data!.allowPayment!
                    ? Container(
                        color: BColors.primaryColor1,
                        padding: const EdgeInsets.all(5),
                        child: Text("Penalty", style: Styles.h6WhiteBold),
                      )
                    : const SizedBox(),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (model!.data != null && model.data!.salesPaymentHistory != null) ...[
            if (!(model.paymentDoneToday ?? false) && (model.data?.allowPayment ?? false)) ...[
              Text(
                "Driver is supposed to pay this amount to ${Properties.titleShort.toUpperCase()} Company from ${getReaderTime(model.data!.paymentStartTime ?? "")} to ${getReaderTime(model.data!.paymentEndTime ?? "")} to avoid Penalties",
                style: Styles.h6Black,
              ),
              const SizedBox(height: 20),
            ],
            model.data?.salesPaymentStatus == "ON" && (model.data?.allowPayment ?? false) && !model.paymentDoneToday!
                ? button(
                    onPressed: () => onPayment(model.data!),
                    text: "Proceed to payment",
                    color: BColors.primaryColor,
                    context: context,
                  )
                : model.data?.salesPaymentStatus == "ON" && model.paymentDoneToday!
                    ? Column(
                        children: [
                          Center(
                            child: Text(
                              "You have completed today's payment 🎉",
                              style: Styles.h3Green,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          button(
                            onPressed: () => onOthersPayment(model.data!),
                            text: "Pay for others",
                            color: BColors.primaryColor,
                            context: context,
                          )
                        ],
                      )
                    : Center(
                        child: Text(
                          "The sales payment period has ended! If you have not made your payment, you can ONLY do so at the ${Properties.titleShort} office. ❗Note: A penalty will be applied",
                          style: Styles.h4RedBold,
                          textAlign: TextAlign.center,
                        ),
                      ),
            const SizedBox(height: 20),
            Row(
              children: [
                transactionFilterOption(
                  label: 'My Sales',
                  isSelected: filterType == 'My Sales',
                  onTap: () => onSalesFilter?.call('My Sales'),
                ),
                const SizedBox(width: 10),
                transactionFilterOption(
                  label: 'Others',
                  isSelected: filterType == 'Others',
                  onTap: () => onSalesFilter?.call('Others'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!show)
              emptyBox(context!, subHeight: 500)
            else
              for (var data in filterType == "My Sales"
                  ? model.data!.salesPayments!.self ?? []
                  : model.data!.salesPayments!.others ?? []) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -3),
                  leading: const CircleAvatar(
                    radius: 10,
                    backgroundColor: BColors.primaryColor,
                    child: Icon(
                      Icons.arrow_downward,
                      size: 13,
                      color: BColors.white,
                    ),
                  ),
                  title: Text(
                    "${Properties.curreny} ${data.amount ?? "N/A"} to ${Properties.titleShort.toUpperCase()}",
                    style: Styles.h4BlackBold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    data.description ?? "N/A",
                    style: Styles.h6Black,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    "${data.datePaid!.split(" ")[0]} ${data.datePaid!.split(" ")[1]}\n${data.datePaid!.split(" ").last}",
                    style: Styles.h6Black,
                  ),
                ),
                const Divider(),
              ],
          ] else
            shimmerItem(),
        ],
      ),
    ),
  );
}
