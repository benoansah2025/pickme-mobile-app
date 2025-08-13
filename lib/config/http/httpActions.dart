class HttpActions {
  HttpActions._();

  // auth
  static const register = "REGISTER";
  static const phoneLogin = "PHONE-LOGIN";
  static const emailLogin = "EMAIL-LOGIN";
  static const verifyEmail = "VERIFY-EMAIL";
  static const verifyPin = "VERIFY-PIN";
  static const resendEmailVerification = "RESEND-EMAIL-VERIFICATION";
  static const forgotPassword = "FORGOT-PASSWORD";
  static const resetPassword = "RESET-PASSWORD";
  static const passwordReset = "PASSWORD-RESET";
  static const logout = "LOGOUT";
  static const deleteAccount = "DELETE";
  static const updateProfile = "UPDATE-PROFILE";
  static const profile = "PROFILE";

  // workers
  static const checkEntryCode = "CHECK-ENTRY-CODE";
  static const registerWorker = "REGISTER-WORKER";
  static const updateWorker = "UPDATE-WORKER";
  static const workersInfo = "WORKER-INFO";
  static const goOnline = "GO-ONLINE";
  static const goOffline = "GO-OFFLINE";
  static const workerAppreciation = "WORKER-APPRECIATIONS";
  static const vehicleTypes = "VEHICLE-TYPES";

  //ride request
  static const searchRide = "SEARCH-RIDE";
  static const bookRide = "BOOK-RIDE";
  static const tripCancelled = "TRIP-CANCELLED";
  static const acceptRide = "ACCEPT-RIDE";
  static const arrivedPickup = "ARRIVED-PICKUP";
  static const tripAccepted = "TRIP-ACCEPTED";
  static const tripStarted = "TRIP-STARTED";
  static const tripEnded = "TRIP-ENDED";
  static const tripCompleted = "TRIP-COMPLETED";
  static const tripRating = "TRIP-RATING";
  static const applyDiscount = "APPLY-DISCOUNT";
  static const tripEstimate = "TRIP-ESTIMATE";
  static const trips = "TRIPS";
  static const cancelReasons = "CANCEL-REASONS";
  static const cancelRequest = "CANCEL-REQUEST";
  static const geofences = "GEOFENCES";

  //wallet
  static const setPincode = "SET-PINCODE";
  static const walletBalance = "WALLET-BALANCE";
  static const loadWallet = "LOAD-WALLET";
  static const walletTransaction = "WALLET-TRANSACTIONS";
  static const transferWalletMoney = "TRANSFER-WALLET-MONEY";

  //sales
  static const salesSummary = "SALES-SUMMARY";
  static const paySales = "PAY-SALES";

  //vendors
  static const vendors = "VENDORS";
  static const subscriptionPlans = "SUBSCRIPTION-PLANS";
  static const listBusiness = "LIST-BUSINESS";
  static const myBusinessListings = "MY-BUSINESS-LISTINGS";
  static const renewBusinessListings = "RENEW-BUSINESS-LISTING";
  static const updateBusinessListings = "UPDATE-BUSINESS-LISTING";

  // others
  static const investment = "INVESTMENT-OPPORTUNITIES";
}
