import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/components/emptyBox.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/components/toggleBar.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/businessListingsModel.dart';
import 'package:pickme_mobile/models/workersInfoModel.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';
import 'package:pickme_mobile/spec/arrays.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'applicationStatusAppBar.dart';
import 'vendorStatusWidget.dart';

Widget applicationStatusWidget({
  required BuildContext context,
  required void Function(WorkersInfoData data) onApplication,
  required void Function(int index) onToggle,
  required int currentToggle,
  required void Function(ApplicationStatusEnum status) onVendorFilter,
  required ApplicationStatusEnum applicationStatus,
  required void Function(ListingDetails data) onListingsDetails,
}) {
  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      return <Widget>[const ApplicationStatusAppBar()];
    },
    body: Stack(
      children: [
        ToggleBar(
          labels: const ['Worker', 'Vendor'],
          selectedTabColor: BColors.white,
          selectedTextColor: BColors.primaryColor,
          labelTextStyle: Styles.h5BlackBold,
          backgroundColor: BColors.primaryColor,
          onSelectionUpdated: (index) => onToggle(index),
          selectedIndex: currentToggle,
        ),
        Container(
          margin: const EdgeInsets.only(top: 50),
          child: currentToggle == 0
              ? StreamBuilder(
                  stream: workersInfoStream,
                  initialData: workersInfoModel,
                  builder: (BuildContext context, AsyncSnapshot<WorkersInfoModel> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.ok! && snapshot.data!.data != null) {
                        WorkersInfoData? data = snapshot.data!.data;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                // for (int x = 0; x < 4; ++x) ...[
                                GestureDetector(
                                  onTap: () => onApplication(data),
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
                                                  image: "${data?.picture}",
                                                  height: 60,
                                                  width: 60,
                                                  placeholder: Images.defaultProfilePicOffline,
                                                ),
                                                size: 60,
                                              ),
                                              title: Text(
                                                "${data?.name}",
                                                style: Styles.h4BlackBold,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                              trailing: Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  color: getStatusColor("${data?.status}"),
                                                ),
                                                child: Text(
                                                  "${data?.status}",
                                                  style: Styles.h6White,
                                                ),
                                              ),
                                            ),
                                            const Divider(),
                                            const SizedBox(height: 10),
                                            Text("Choosen Services", style: Styles.h6Black),
                                            const SizedBox(height: 10),
                                            for (String service in data!.services!) ...[
                                              Text(
                                                service,
                                                style: Styles.h6BlackBold,
                                              ),
                                              const SizedBox(height: 5),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                              // ],
                            ),
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
              : vendorStatusWidget(
                  context: context,
                  onVendorFilter: (ApplicationStatusEnum status) => onVendorFilter(status),
                  applicationStatus: applicationStatus,
                  onListingsDetails: (ListingDetails data) => onListingsDetails(data),
                ),
        ),
      ],
    ),
  );
}
