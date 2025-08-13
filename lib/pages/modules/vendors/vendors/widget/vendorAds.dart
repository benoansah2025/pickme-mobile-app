import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';
import 'package:pickme_mobile/models/vendorsModel.dart';

Widget vendorAds({
  required BuildContext context,
  required List<Data> vendors,
  required void Function(Data data) onVendor,
}) {
  // Shuffle and pick 5 random vendors (or fewer if not enough)
  // final randomVendors = List<Data>.from(vendors)..shuffle();
  final selectedVendors = vendors.take(15).toList();
  selectedVendors.sort((a, b) => (b.subscriptionVisibilityFrequency ?? 0).compareTo(a.subscriptionVisibilityFrequency ?? 0));

  return ExpandableCarousel(
    options: ExpandableCarouselOptions(
      autoPlay: true,
      autoPlayInterval: const Duration(seconds: 3),
      showIndicator: false,
      enableInfiniteScroll: true,
    ),
    items: selectedVendors.map((Data data) {
      return Builder(
        builder: (BuildContext context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: BColors.assDeep1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () => onVendor(data),
              child: _layout(
                context: context,
                title: data.vendorName,
                subtitle: data.serviceName,
                address: data.streetname,
                image: data.picture,
              ),
            ),
          );
        },
      );
    }).toList(),
  );
}

Widget _layout({
  required BuildContext context,
  @required String? title,
  @required String? subtitle,
  @required String? address,
  @required String? image,
}) {
  return Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: cachedImage(
            context: context,
            image: "$image",
            height: 50,
            width: 50,
            placeholder: Images.imageLoadingError,
          ),
        ),
        title: Text(
          sentenceCase(title!),
          style: Styles.h4BlackBold,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(
          "${subtitle ?? ""}, ${address ?? "N/A"}",
          style: Styles.h6Black,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    ],
  );
}
