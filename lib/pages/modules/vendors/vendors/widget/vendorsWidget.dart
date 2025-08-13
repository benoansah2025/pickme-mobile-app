import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/cachedImage.dart';
import 'package:pickme_mobile/components/emptyBox.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/components/ratingStar.dart';
import 'package:pickme_mobile/components/textField.dart';
import 'package:pickme_mobile/config/globalFunction.dart';
import 'package:pickme_mobile/models/vendorsModel.dart';
import 'package:pickme_mobile/pages/modules/vendors/vendors/widget/vendorsAppBar.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget vendorsWidget({
  @required BuildContext? context,
  @required FocusNode? searchFocusNode,
  @required void Function(String text)? onSearchChange,
  @required void Function()? onVentorFilter,
  required String searchText,
  required List<Data> vendors,
  required ScrollController scrollController,
  required bool isLoading,
  required bool isContainItems,
  required void Function(Data data) onVendor,
}) {
  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      return <Widget>[const VendorAppBar()];
    },
    body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          const SizedBox(height: 10),
          textFormField(
            hintText: "Search shoes, groceries, etc...",
            controller: null,
            focusNode: searchFocusNode,
            onTextChange: (String text) => onSearchChange!(text),
            backgroundColor: BColors.assDeep1,
            borderColor: BColors.assDeep1,
            // icon: FeatherIcons.sliders,
            // onIconTap: onVentorFilter,
          ),
          const SizedBox(height: 20),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            bottom: 0,
            child: !isContainItems
                ? emptyBox(context!)
                : ListView.builder(
                    shrinkWrap: true,
                    controller: scrollController,
                    itemCount: vendors.length + 1, // Add 1 for loading indicator
                    itemBuilder: (context, index) {
                      if (index == vendors.length) {
                        return isLoading ? loadingDoubleBounce(BColors.primaryColor) : const SizedBox.shrink();
                      }

                      final data = vendors[index];

                      return GestureDetector(
                        onTap: () => onVendor(data),
                        child: _layout(
                          context: context,
                          title: data.vendorName,
                          subtitle: data.serviceName,
                          address: data.streetname,
                          location: data.district,
                          rating: data.rating!.toDouble(),
                          onCall: () => callLauncher("tel: ${data.phone}"),
                          image: data.picture,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

Widget _layout({
  required BuildContext context,
  @required String? title,
  @required String? subtitle,
  @required String? address,
  @required String? location,
  @required String? image,
  @required double? rating,
  @required void Function()? onCall,
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
            height: 60,
            width: 60,
            placeholder: Images.imageLoadingError,
          ),
        ),
        title: Text(sentenceCase(title!), style: Styles.h4BlackBold),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle!, style: Styles.h6Black),
            const SizedBox(height: 5),
            Text(address!, style: Styles.h6Black),
          ],
        ),
        trailing: Column(
          children: [
            CircleAvatar(
              backgroundColor: BColors.primaryColor1,
              radius: 20,
              child: IconButton(
                onPressed: onCall,
                icon: const Icon(Icons.call),
                color: BColors.white,
                iconSize: 20,
              ),
            ),
          ],
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(width: 77),
          Expanded(child: Text(location!, style: Styles.h6Black)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ratingStar(
                rate: rating,
                function: null,
                size: 17,
                itemCount: 5,
                itemPadding: 1,
                unratedColor: BColors.assDeep,
              ),
              const SizedBox(width: 5),
              Text("$rating", style: Styles.h6BlackBold),
            ],
          ),
        ],
      ),
      const Divider(),
      const SizedBox(height: 20),
    ],
  );
}
