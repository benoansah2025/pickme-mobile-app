import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/models/tripDetailsModel.dart';
import 'package:pickme_mobile/pages/homepage/wallet/widget/walletAppBar.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

Widget walletPayRideWidget({
  required BuildContext context,
  required TextEditingController codeController,
  required FocusNode codeFocusNode,
  required void Function() onPay,
  required TripDetailsModel? tripDetailsModel,
}) {
  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      return <Widget>[const WalletAppBar(showWallet: true)];
    },
    body: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              width: 50,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BColors.primaryColor1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: BColors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 40),
            Text("New Billed Amount", style: Styles.h6Black),
            const SizedBox(height: 20),
            Text(
              "${Properties.curreny} ${tripDetailsModel!.grandTotal}",
              style: Styles.h2Black,
            ),
            const SizedBox(height: 40),
            button(
              onPressed: onPay,
              text: "Pay",
              color: BColors.primaryColor,
              context: context,
            ),
            const SizedBox(height: 20),
          ],
        ),

        // Column(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [

        //     Container(
        //       padding: const EdgeInsets.all(10),
        //       decoration: BoxDecoration(
        //         color: BColors.background,
        //         borderRadius: BorderRadius.circular(10),
        //         border: Border.all(color: BColors.assDeep),
        //       ),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           SizedBox(
        //             width: MediaQuery.of(context).size.width * .41,
        //             child: ListTile(
        //               contentPadding: EdgeInsets.zero,
        //               horizontalTitleGap: 5,
        //               leading: Container(
        //                 height: 50,
        //                 width: 50,
        //                 padding: const EdgeInsets.all(10),
        //                 decoration: BoxDecoration(
        //                   color: BColors.primaryColor,
        //                   borderRadius: BorderRadius.circular(10),
        //                 ),
        //                 child: const Icon(
        //                   Icons.receipt_long,
        //                   color: BColors.white,
        //                   size: 30,
        //                 ),
        //               ),
        //               title: Text("Billed Amount", style: Styles.h7Black),
        //               subtitle: Text(
        //                 "${Properties.curreny} 45.00",
        //                 style: Styles.h4BlackBoldStrikeThough,
        //               ),
        //             ),
        //           ),
        //           SizedBox(
        //             width: MediaQuery.of(context).size.width * .47,
        //             child: ListTile(
        //               contentPadding: EdgeInsets.zero,
        //               horizontalTitleGap: 5,
        //               leading: Container(
        //                 height: 50,
        //                 width: 50,
        //                 padding: const EdgeInsets.all(10),
        //                 decoration: BoxDecoration(
        //                   color: BColors.primaryColor1,
        //                   borderRadius: BorderRadius.circular(10),
        //                 ),
        //                 child: const Icon(
        //                   Icons.receipt_long,
        //                   color: BColors.white,
        //                   size: 30,
        //                 ),
        //               ),
        //               title: Text("New Billed Amount", style: Styles.h7Black),
        //               subtitle: Text(
        //                 "${Properties.curreny} 25.00",
        //                 style: Styles.h4BlackBold,
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),

        //     Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Text("Payment Pincode", style: Styles.h5Black),
        //         const SizedBox(height: 10),
        //         textFormField(
        //           hintText: "Enter your code",
        //           controller: codeController,
        //           focusNode: codeFocusNode,
        //         ),
        //         const SizedBox(height: 30),
        //         button(
        //           onPressed: onPay,
        //           text: "Pay",
        //           color: BColors.primaryColor,
        //           context: context,
        //         ),
        //         const SizedBox(height: 20),
        //       ],
        //     ),
        //   ],
        // ),
      ),
    ),
  );
}
