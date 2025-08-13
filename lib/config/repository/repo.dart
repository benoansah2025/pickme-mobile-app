import 'package:pickme_mobile/models/userModel.dart';
import 'package:pickme_mobile/providers/allTripsProvider.dart';
import 'package:pickme_mobile/providers/businessListingsProvider.dart';
import 'package:pickme_mobile/providers/cancelReasonsProvider.dart';
import 'package:pickme_mobile/providers/geofencesProvider.dart';
import 'package:pickme_mobile/providers/investmentProvider.dart';
import 'package:pickme_mobile/providers/profileProvider.dart';
import 'package:pickme_mobile/providers/salesSummaryProvider.dart';
import 'package:pickme_mobile/providers/subscriptionsProvider.dart';
import 'package:pickme_mobile/providers/vehicleTypesProvider.dart';
import 'package:pickme_mobile/providers/vendorsProvider.dart';
import 'package:pickme_mobile/providers/walletBalanceProvider.dart';
import 'package:pickme_mobile/providers/walletTransactionsProvider.dart';
import 'package:pickme_mobile/providers/workersAppreciationProvider.dart';
import 'package:pickme_mobile/providers/workersInfoProvider.dart';

class Repository {
  final WorkersInfoProvider _workersInfoProvider = new WorkersInfoProvider();
  Future<void> fetchWorkerInfo(bool isLoad) => _workersInfoProvider.get(isLoad: isLoad);

  final AllTripsProvider _allTripsProvider = new AllTripsProvider();
  Future<void> fetchAllTrips(bool isLoad) => _allTripsProvider.get(isLoad: isLoad);

  final ProfileProvider _profileProvider = new ProfileProvider();
  Future<UserModel?> fetchProfile({String? userId}) => _profileProvider.get(userId: userId);

  final WalletBalanceProvider _walletBalanceProvider = new WalletBalanceProvider();
  Future<void> fetchWalletBalance(bool isLoad) => _walletBalanceProvider.get(isLoad: isLoad);

  final WalletTransationsProvider _walletTransationsProvider = new WalletTransationsProvider();
  Future<void> fetchWalletTransaction(bool isLoad) => _walletTransationsProvider.get(isLoad: isLoad);

  final VendorsProvider _vendorsProvider = new VendorsProvider();
  Future<void> fetchVendors(bool isLoad) => _vendorsProvider.get(isLoad: isLoad);

  final WorkersAppreciationProvider _appreciationProvider = new WorkersAppreciationProvider();
  Future<void> fetchWorkersAppreciation(bool isLoad) => _appreciationProvider.get(isLoad: isLoad);

  final VehicleTypesProvider _vehicleTypesProvider = new VehicleTypesProvider();
  Future<void> fetchVehicleTypes(bool isLoad) => _vehicleTypesProvider.get(isLoad: isLoad);

  final CancelReasonsProvider _cancelReasonsProvider = new CancelReasonsProvider();
  Future<void> fetchCancelReasons(bool isLoad) => _cancelReasonsProvider.get(isLoad: isLoad);

  final GeofencesProvider _geofencesProvider = new GeofencesProvider();
  Future<void> fetchGeofences(bool isLoad) => _geofencesProvider.get(isLoad: isLoad);

  final SalesSummaryProvider _salesSummaryProvider = new SalesSummaryProvider();
  Future<void> fetchSalesSummary(bool isLoad) => _salesSummaryProvider.get(isLoad: isLoad);

  final SubscriptionsProvider _subscriptionsProvider = new SubscriptionsProvider();
  Future<void> fetchSubscriptions(bool isLoad) => _subscriptionsProvider.get(isLoad: isLoad);

  final BusinesslistingsProvider _businesslistingsProvider = new BusinesslistingsProvider();
  Future<void> fetchBusinessListings(bool isLoad) => _businesslistingsProvider.get(isLoad: isLoad);

  final InvestmentProvider _investmentProvider = new InvestmentProvider();
  Future<void> fetchInvestment(bool isLoad) => _investmentProvider.get(isLoad: isLoad);
}
