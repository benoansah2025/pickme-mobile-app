import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/businessListingsModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget vendorDetailsWidget({
  required BuildContext context,
  required ListingDetails data,
  required void Function() onSubscriptionInfo,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Service Details", style: Styles.h3BlackBold),
            trailing: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: getStatusColor(data.status ?? "PENDING"),
              ),
              child: Text(data.status ?? "PENDING", style: Styles.h6White),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: BColors.assDeep1,
              border: Border.all(color: BColors.assDeep),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              title: Text("Subscription", style: Styles.h5Black),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.subscriptionName ?? "N/A", style: Styles.h5BlackBold),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${Properties.curreny} ${data.subscriptionPrice ?? "N/A"}",
                        style: Styles.h5BlackBold,
                      ),
                      Text(
                        "${data.subscriptionDurationDays ?? "N/A"} days",
                        style: Styles.h6BlackBold,
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: BColors.primaryColor1,
                ),
                onPressed: () => onSubscriptionInfo(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: BColors.assDeep),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                width: 300,
                height: 150,
                child: cachedImage(
                  width: 300,
                  height: 150,
                  fit: BoxFit.fitWidth,
                  context: context,
                  image: data.picture ?? "",
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text("Service name", style: Styles.h6Black),
          Text(data.serviceName ?? "N/A", style: Styles.h6BlackBold),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email", style: Styles.h6Black),
                    Text(data.email ?? "N/A", style: Styles.h6BlackBold),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Phone Number", style: Styles.h6Black),
                    Text(data.phone ?? "N/A", style: Styles.h6BlackBold),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text("Vendor Details", style: Styles.h3BlackBold),
          const SizedBox(height: 10),
          Text("Vendor Name", style: Styles.h6Black),
          Text(data.businessName ?? "N/A", style: Styles.h6BlackBold),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .33,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Region", style: Styles.h6Black),
                    Text(data.region ?? "N/A", style: Styles.h6BlackBold),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("District", style: Styles.h6Black),
                    Text(data.district ?? "N/A", style: Styles.h6BlackBold),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .33,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Streetname", style: Styles.h6Black),
                    Text(data.streetname ?? "N/A", style: Styles.h6BlackBold),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text("GPS Details", style: Styles.h3BlackBold),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Latitude, Longitude", style: Styles.h6Black),
                    Text("${data.latitude ?? 'N/A'}, ${data.longitude ?? 'N/A'}", style: Styles.h6BlackBold),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Address", style: Styles.h6Black),
                    Text(data.gpsaddress ?? "N/A", style: Styles.h6BlackBold),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}
