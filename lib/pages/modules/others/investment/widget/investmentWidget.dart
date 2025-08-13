import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/emptyBox.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/models/investmentModel.dart';
import 'package:pickme_mobile/providers/investmentProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget investmentWidget({
  required BuildContext context,
  required void Function(InvestmentData data) onDetials,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: ListView(
      children: [
        SizedBox(height: 10),
        StreamBuilder(
          stream: investmentStream,
          initialData: investmentModel,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.ok! && snapshot.data!.data != null) {
                return Column(
                  children: [
                    for (InvestmentData data in snapshot.data!.data!)
                      GestureDetector(
                        onTap: () => onDetials(data),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          height: 250,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: BColors.assDeep1,
                              child: Stack(
                                children: [
                                  cachedImage(
                                    context: context,
                                    image: data.flyer,
                                    height: 250,
                                    width: MediaQuery.of(context).size.width,
                                    placeholder: Images.imageLoadingError,
                                    fit: BoxFit.contain,
                                  ),
                                  if (data.title != null)
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        color: BColors.white.withOpacity(.5),
                                        padding: const EdgeInsets.all(10),
                                        width: MediaQuery.of(context).size.width,
                                        child: Text(data.title!, style: Styles.h5BlackBold),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }
            } else if (snapshot.hasError) {
              return emptyBox(context, msg: "No data available");
            }
            return Center(
              child: loadingDoubleBounce(BColors.primaryColor),
            );
          },
        ),
      ],
    ),
  );
}
