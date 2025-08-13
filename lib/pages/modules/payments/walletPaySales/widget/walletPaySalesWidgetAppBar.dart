import 'package:flutter/material.dart';
import 'package:pickme_mobile/components/loadingView.dart';
import 'package:pickme_mobile/models/walletBalanceModel.dart';
import 'package:pickme_mobile/providers/walletBalanceProvider.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:pickme_mobile/spec/properties.dart';
import 'package:pickme_mobile/spec/styles.dart';

class WalletPaySalesWidget extends StatelessWidget {

  const WalletPaySalesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: BColors.primaryColor,
      pinned: true,
      expandedHeight: 180,
      iconTheme: const IconThemeData(color: BColors.white),
      title: Text(
        "${Properties.titleShort.toUpperCase()} Cash",
        style: Styles.h5WhiteBold,
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        background: Container(
          margin: const EdgeInsets.only(top: 80),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder(
                stream: walletBalanceStream,
                initialData: walletBalanceModel,
                builder: (context, AsyncSnapshot<WalletBalanceModel> snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      "${Properties.curreny} ${snapshot.data!.data != null ? snapshot.data!.data!.balance : '0.00'}",
                      style: Styles.h1WhiteBold,
                    );
                  } else if (snapshot.hasError) {
                    return Text("${Properties.curreny} 0.00", style: Styles.h1WhiteBold);
                  }
                  return loadingDoubleBounce(BColors.white);
                },
              ),
              const SizedBox(height: 10),
              Text("Balance", style: Styles.h5White),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(
          height: 15,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: BColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
