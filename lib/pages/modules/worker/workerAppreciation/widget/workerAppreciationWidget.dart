import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/circular.dart';
import 'package:pickme_mobile/components/emptyBox.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/models/workersAppreciationModel.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget workerAppreciationWidget({
  required BuildContext context,
  required List<Data> appreciation,
  required ScrollController scrollController,
  required bool isLoading,
  required bool isContainItems,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 20),
            Text("Worker Appreciation", style: Styles.h3BlackBold),
            const SizedBox(height: 20),
            Text(
              "These are company selected individual reward scheme to appreciate excellent performance ",
              style: Styles.h6Black,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 120),
          child: !isContainItems
              ? emptyBox(context)
              : Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: scrollController,
                    itemCount: appreciation.length + 1, // Add 1 for loading indicator
                    itemBuilder: (context, index) {
                      if (index == appreciation.length) {
                        return isLoading ? loadingDoubleBounce(BColors.primaryColor) : const SizedBox.shrink();
                      }

                      final data = appreciation[index];

                      return Column(
                        children: [
                          Card(
                            elevation: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                color: BColors.assDeep.withOpacity(.06),
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: circular(
                                        child: cachedImage(
                                          context: context,
                                          image: data.workerImage,
                                          height: 60,
                                          width: 60,
                                          placeholder: Images.defaultProfilePicOffline,
                                        ),
                                        size: 60,
                                      ),
                                      title: Text(data.workerName, style: Styles.h4BlackBold),
                                      subtitle: Text(data.serviceName!, style: Styles.h5Primary1),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, color: BColors.yellow1),
                                          const SizedBox(width: 5),
                                          Text(data.rating, style: Styles.h6BlackBold)
                                        ],
                                      ),
                                    ),
                                    const Divider(),
                                    const SizedBox(height: 10),
                                    Text("Rewarded", style: Styles.h6Black),
                                    const SizedBox(height: 10),
                                    Text(data.description!, style: Styles.h6BlackBold),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),
        ),
      ],
    ),
  );
}
