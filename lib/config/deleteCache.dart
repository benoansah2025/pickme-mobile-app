import 'package:flutter/material.dart';
import 'package:pickme_mobile/config/hiveStorage.dart';
import 'package:pickme_mobile/config/sharePreference.dart';
import 'package:pickme_mobile/providers/allTripsProvider.dart';
import 'package:pickme_mobile/providers/businessListingsProvider.dart';
import 'package:pickme_mobile/providers/cancelReasonsProvider.dart';
import 'package:pickme_mobile/providers/homepageListenerProvider.dart';
import 'package:pickme_mobile/providers/investmentProvider.dart';
import 'package:pickme_mobile/providers/salesSummaryProvider.dart';
import 'package:pickme_mobile/providers/subscriptionsProvider.dart';
import 'package:pickme_mobile/providers/vehicleTypesProvider.dart';
import 'package:pickme_mobile/providers/vendorsProvider.dart';
import 'package:pickme_mobile/providers/walletBalanceProvider.dart';
import 'package:pickme_mobile/providers/walletTransactionsProvider.dart';
import 'package:pickme_mobile/providers/workersAppreciationProvider.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';

Future<void> deleteCache() async {
  imageCache.clear();

  List<String> cacheList = [
    "userDetails",
    "workersInfo",
    "walletBalance",
    "walletTransactions",
    "vendors",
    "workerAppreciation",
    "trips",
    "currentLocation",
    "vehicleTypes",
    "vendors",
    "timeOnline",
    "riderRating",
    "ridePlaces",
    "showHomeDetails",
    "cancelReasons",
    "isWorker",
    "salesSummary",
    "subscriptionPlans",
    "myBusinessListings",
    "investment",
  ];

  for (String key in cacheList) {
    await deleteShareUserData(key);
    await deleteHive(key);
  }

  AllTripsProvider().clear();
  CancelReasonsProvider().clear();
  pauseMainTripDetailsStreaming = false;
  VehicleTypesProvider().clear();
  VendorsProvider().clear();
  WalletBalanceProvider().clear();
  WalletTransationsProvider().clear();
  WorkersAppreciationProvider().clear();
  WorkersInfoProvider().clear();
  SalesSummaryProvider().clear();
  SubscriptionsProvider().clear(); 
  BusinesslistingsProvider().clear(); 
  InvestmentProvider().clear();
}
