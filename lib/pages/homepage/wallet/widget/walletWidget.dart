import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/button.dart';
import 'package:pickme_mobile/components/emptyBox.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/components/transactionFilterOtion.dart';
import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/models/walletTransactionsModel.dart';
import 'package:pickme_mobile/providers/walletTransactionsProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/images.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

import 'walletAppBar.dart';

Widget walletWidget({
  @required BuildContext? context,
  @required void Function()? onAddMoney,
  @required void Function()? onTransfer,
  @required void Function()? onWithdraw,
  @required void Function()? onContactUs,
  @required void Function()? onCopyID,
  @required void Function(String filter)? onTransactionFilter,
  @required String? filterType,
  required bool isWorker,
  required bool showWallet,
}) {
  bool show = false;

  if (showWallet) {
    if (walletTransactionsModel != null && walletTransactionsModel!.data != null) {
      for (var data in walletTransactionsModel!.data!) {
        if (filterType == "all" || (filterType!.toLowerCase() == data.transType!.toLowerCase())) {
          show = true;
        }
      }
    }
  }

  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
      return <Widget>[WalletAppBar(showWallet: showWallet)];
    },
    body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView(
        children: [
          ListTile(
            tileColor: BColors.background,
            title: Text("Wallet ID", style: Styles.h6Black),
            subtitle: Text(userModel!.data!.user!.userid!, style: Styles.h4BlackBold),
            trailing: button(
              onPressed: onCopyID,
              text: "Copy",
              color: BColors.primaryColor,
              textColor: BColors.primaryColor,
              colorFill: false,
              context: context,
              useWidth: false,
              height: 30,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _layout1(
                context: context,
                image: Images.addMoney,
                name: 'Add Money',
                onTap: !showWallet ? null : onAddMoney,
                isWorker: isWorker,
              ),
              _layout1(
                context: context,
                image: Images.transfer,
                name: 'Transfer',
                onTap: !showWallet ? null : onTransfer,
                isWorker: isWorker,
              ),
              if (isWorker)
                _layout1(
                  context: context,
                  image: Images.transactions,
                  name: 'Withdraw',
                  onTap: !showWallet ? null : onWithdraw,
                  isWorker: isWorker,
                ),
              _layout1(
                context: context,
                image: Images.contactUs,
                name: 'Contact Us',
                onTap: !showWallet ? null : onContactUs,
                isWorker: isWorker,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Transactions", style: Styles.h4BlackBold),
          const SizedBox(height: 20),
          Row(
            children: [
              transactionFilterOption(
                label: 'All',
                isSelected: filterType == 'all',
                onTap: !showWallet ? null : () => onTransactionFilter?.call('all'),
              ),
              const SizedBox(width: 20),
              transactionFilterOption(
                label: 'Credit',
                isSelected: filterType == 'credit',
                onTap: !showWallet ? null : () => onTransactionFilter?.call('credit'),
                icon: const CircleAvatar(
                  radius: 10,
                  backgroundColor: BColors.primaryColor,
                  child: Icon(
                    Icons.arrow_downward,
                    size: 13,
                    color: BColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              transactionFilterOption(
                label: 'Debit',
                isSelected: filterType == 'debit',
                onTap: !showWallet ? null : () => onTransactionFilter?.call('debit'),
                icon: const CircleAvatar(
                  radius: 10,
                  backgroundColor: BColors.primaryColor1,
                  child: Icon(
                    Icons.arrow_upward,
                    size: 13,
                    color: BColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder(
              stream: walletTransactionsStream,
              initialData: walletTransactionsModel,
              builder: (context, AsyncSnapshot<WalletTransactionsModel> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.data != null && snapshot.data!.data!.isNotEmpty) {
                    return show
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var data in snapshot.data!.data!)
                                if (filterType == "all" ||
                                    (filterType!.toLowerCase() == data.transType!.toLowerCase())) ...[
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    visualDensity: const VisualDensity(vertical: -3),
                                    leading: data.transType!.toUpperCase() == "CREDIT"
                                        ? const CircleAvatar(
                                            radius: 10,
                                            backgroundColor: BColors.primaryColor,
                                            child: Icon(
                                              Icons.arrow_downward,
                                              size: 13,
                                              color: BColors.white,
                                            ),
                                          )
                                        : const CircleAvatar(
                                            radius: 10,
                                            backgroundColor: BColors.primaryColor1,
                                            child: Icon(
                                              Icons.arrow_upward,
                                              size: 13,
                                              color: BColors.white,
                                            ),
                                          ),
                                    title: Text(
                                      "${Properties.curreny} ${data.amount} from ${data.channel}.",
                                      style: Styles.h4BlackBold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      "Amount ${data.transType!.toUpperCase() == "CREDIT" ? 'credited to' : 'debited from'}  your account",
                                      style: Styles.h6Black,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Text(
                                      "${data.dateCreated!.split(" ")[0]} ${data.dateCreated!.split(" ")[1]}\n${data.dateCreated!.split(" ").last}",
                                      style: Styles.h6Black,
                                    ),
                                  ),
                                  const Divider(),
                                ],
                            ],
                          )
                        : emptyBox(context, subHeight: 600);
                  } else {
                    return emptyBox(context, subHeight: 600);
                  }
                } else if (snapshot.hasError) {
                  return emptyBox(context, subHeight: 600);
                }
                return loadingDoubleBounce(BColors.primaryColor);
              }),
        ],
      ),
    ),
  );
}

Widget _layout1({
  @required BuildContext? context,
  @required String? image,
  @required String? name,
  @required void Function()? onTap,
  required bool isWorker,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: MediaQuery.of(context!).size.width * (isWorker ? .22 : .3),
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: BColors.assDeep1,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: BColors.black.withOpacity(.05),
            spreadRadius: .1,
            blurRadius: 20,
            // offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(image!),
            const SizedBox(height: 10),
            Text(name!, style: Styles.h7Black, textAlign: TextAlign.center)
          ],
        ),
      ),
    ),
  );
}
