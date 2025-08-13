enum RidePlaceFields { pickUp, whereTo, stopOvers }

enum RideMapNextAction {
  selectRide,
  addAddress,
  deliverySendItem,
  deliveryReceiveItem,
  //////starting on going ride//////
  yourTripSummary,
  searchingDriver,
  driverFound,
  bookingSuccess,
  driverArrived,
  drivingToDestination,
  arrivedDestination,
  trackDriver,
}

enum ServicePurpose {
  ride,
  personalShopper,
  deliveryRunnerSingle,
  deliveryRunnerMultiple,
}

enum DeliveryType { send, receive }

enum DeliveryAccessLocation { pickUpLocation, whereToLocation }

enum WorkerMapNextAction {
  accept,
  arrived,
  startTrip,
  endTrip,
}

enum LoginType { email, phone }

enum AuthNextAction {
  loginEmailVerify,
  loginPhoneVerifyUserExit,
  loginPhoneVerifyUserNotExit,
  forgotPasswordVerify,
  signUpPhoneVerify,
}

enum StartStop { start, stop }

class Arrays {
  Arrays._();

  // static const List<String> vehicleType = [
  //   "CAR",
  //   "TRUCK",
  //   "VAN",
  //   "BIKE",
  // ];

  static const List<String> regions = [
    "Ahafo Region",
    "Ashanti Region",
    "Bono East Region",
    "Bono Region",
    "Central Region",
    "Eastern Region",
    "Greater Accra Region",
    "North East Region",
    "Northern Region",
    "Oti Region",
    "Savannah Region",
    "Upper East Region",
    "Upper West Region",
    "Volta Region",
    "Western North Region",
    "Western Region",
  ];
}

enum OngoingRequestLayoutIconEnum { bIcon1, bIcon2 }

enum ApplicationStatusEnum { pending, active, expired }
