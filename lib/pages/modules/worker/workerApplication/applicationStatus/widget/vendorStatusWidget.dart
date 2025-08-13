import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/components/emptyBox.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/businessListingsModel.dart';
import 'package:pickme_mobile/providers/businessListingsProvider.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget vendorStatusWidget({
  required BuildContext context,
  required void Function(ApplicationStatusEnum status) onVendorFilter,
  required ApplicationStatusEnum applicationStatus,
  required void Function(ListingDetails data) onListingsDetails,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10),
    margin: const EdgeInsets.only(top: 20),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              button(
                onPressed: () => onVendorFilter(ApplicationStatusEnum.active),
                text: "Active",
                color: applicationStatus == ApplicationStatusEnum.active ? BColors.primaryColor1 : BColors.white,
                textColor: applicationStatus == ApplicationStatusEnum.active ? BColors.white : BColors.primaryColor1,
                context: context,
                useWidth: false,
                height: 40,
              ),
              SizedBox(width: 10),
              button(
                onPressed: () => onVendorFilter(ApplicationStatusEnum.pending),
                text: "Pending",
                color: applicationStatus == ApplicationStatusEnum.pending ? BColors.primaryColor1 : BColors.white,
                textColor: applicationStatus == ApplicationStatusEnum.pending ? BColors.white : BColors.primaryColor1,
                context: context,
                useWidth: false,
                height: 40,
              ),
              SizedBox(width: 10),
              button(
                onPressed: () => onVendorFilter(ApplicationStatusEnum.expired),
                text: "Expired",
                color: applicationStatus == ApplicationStatusEnum.expired ? BColors.primaryColor1 : BColors.white,
                textColor: applicationStatus == ApplicationStatusEnum.expired ? BColors.white : BColors.primaryColor1,
                context: context,
                useWidth: false,
                height: 40,
              ),
            ],
          ),
          StreamBuilder(
            stream: businessListingsStream,
            initialData: busniessListingsModel,
            builder: (BuildContext context, AsyncSnapshot<BusinessListingsModel> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.ok! && snapshot.data!.data != null) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        for (ListingDetails data in (applicationStatus == ApplicationStatusEnum.active
                            ? snapshot.data!.data!.active!
                            : applicationStatus == ApplicationStatusEnum.pending
                                ? snapshot.data!.data!.pending!
                                : snapshot.data!.data!.expired!)) ...[
                          GestureDetector(
                            onTap: () => onListingsDetails(data),
                            child: Card(
                              elevation: 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: BColors.assDeep1,
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: circular(
                                          child: cachedImage(
                                            context: context,
                                            image: "${data.picture}",
                                            height: 60,
                                            width: 60,
                                            placeholder: Images.defaultProfilePicOffline,
                                          ),
                                          size: 60,
                                        ),
                                        title: Text(
                                          "${data.businessName}",
                                          style: Styles.h4BlackBold,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        trailing: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: getStatusColor(data.status ?? "PENDING"),
                                          ),
                                          child: Text(data.status ?? "PENDING", style: Styles.h6White),
                                        ),
                                      ),
                                      const Divider(),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Subscriptions", style: Styles.h6Black),
                                          Text(
                                            "${Properties.curreny} ${data.subscriptionPrice ?? "N/A"}",
                                            style: Styles.h6BlackBold,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            data.subscriptionName ?? "N/A",
                                            style: Styles.h6BlackBold,
                                          ),
                                          Text(
                                            "${data.subscriptionDurationDays ?? "N/A"} days",
                                            style: Styles.h6BlackBold,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if ((applicationStatus == ApplicationStatusEnum.active
                                ? (snapshot.data?.data?.active ?? [])
                                : applicationStatus == ApplicationStatusEnum.pending
                                    ? (snapshot.data?.data?.pending ?? [])
                                    : (snapshot.data?.data?.expired ?? []))
                            .isEmpty) ...[
                          emptyBox(context, msg: "No data available", subHeight: 250),
                        ]
                      ],
                    ),
                  );
                }
              } else if (snapshot.hasError) {
                return emptyBox(context, msg: "No data available");
              }
              return Center(
                child: loadingDoubleBounce(BColors.primaryColor),
              );
            },
          )
        ],
      ),
    ),
  );
}
