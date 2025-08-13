import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/investmentModel.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget investmentDetailsDialog({
  required InvestmentData data,
  required BuildContext context,
}) {
  return ClipRRect(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: cachedImage(
                  context: context,
                  image: data.flyer,
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  placeholder: Images.imageLoadingError,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(child: Text(sentenceCase(data.title!), style: Styles.h4BlackBold)),
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(data.description ?? "N/A", style: Styles.h6BlackBold),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}
