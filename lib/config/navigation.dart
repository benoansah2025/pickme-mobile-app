import 'package:flutter/material.dart';
import 'package:pickme_mobile/pages/authentication/deleteAccount/deleteAccount.dart';
import 'package:pickme_mobile/pages/authentication/editProfile/editProfile.dart';
import 'package:pickme_mobile/pages/authentication/forgetPassword/forgetPassword.dart';
import 'package:pickme_mobile/pages/authentication/login/login.dart';
import 'package:pickme_mobile/pages/authentication/resetPasswordLoggedIn/resetPasswordLoggedIn.dart';
import 'package:pickme_mobile/pages/authentication/signUp/signUp.dart';
import 'package:pickme_mobile/pages/homepage/mainHomepage.dart';
import 'package:pickme_mobile/pages/modules/deliveries/personalShopper/personalShopping/personalShopping.dart';
import 'package:pickme_mobile/pages/modules/others/emergency/emergency.dart';
import 'package:pickme_mobile/pages/modules/others/favorite/favorite.dart';
import 'package:pickme_mobile/pages/modules/others/myServices/myServices.dart';
import 'package:pickme_mobile/pages/modules/others/notification/notifications.dart';
import 'package:pickme_mobile/pages/modules/others/promotions/promotions.dart';
import 'package:pickme_mobile/pages/modules/others/accountSettings/accountSettings.dart';
import 'package:pickme_mobile/pages/modules/others/support/support.dart';
import 'package:pickme_mobile/pages/modules/payments/addMoney/addMoney.dart';
import 'package:pickme_mobile/pages/modules/payments/transferMoney/transferMoney.dart';
import 'package:pickme_mobile/pages/modules/vendors/addVendor/addVendor.dart';
import 'package:pickme_mobile/pages/modules/worker/workerApplication/applicationStatus/applicationStatus.dart';
import 'package:pickme_mobile/pages/modules/worker/salesPayment/salesPayment.dart';
import 'package:pickme_mobile/pages/modules/worker/workerAppreciation/workerAppreciation.dart';
import 'package:pickme_mobile/pages/modules/worker/workerApplication/registrationSelectService/registrationSelectService.dart';
import 'package:pickme_mobile/pages/modules/vendors/vendors/vendors.dart';
import 'package:pickme_mobile/pages/onboarding/onboarding/onboarding.dart';
import 'package:pickme_mobile/spec/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/toast.dart';
import '../pages/modules/others/investment/investment.dart';

Future<void> navigation({
  required BuildContext context,
  required String pageName,
}) async {
  switch (pageName.toLowerCase()) {
    case "back":
      Navigator.of(context).pop();
      break;

    case "onboarding":
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const OnBoarding(),
          ),
          (Route<dynamic> route) => false);
      break;

    case "login":
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (Route<dynamic> route) => false);
      break;
    case "signup":
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (context) => const SignUpPage()), (Route<dynamic> route) => false);
      break;
    case "forgetpassword":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ForgetPasswordPage()),
      );
      break;
    case "editprofile":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditProfile()),
      );
      break;
    case "homepage":
      bool isWorkerMode = false;
      SharedPreferences? prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey("isWorker")) {
        isWorkerMode = prefs.getBool("isWorker")!;
      }
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MainHomepage(isWorkerDashboard: isWorkerMode),
          ),
          (Route<dynamic> route) => false);
      break;
    case "wallet":
      bool isWorkerMode = false;
      SharedPreferences? prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey("isWorker")) {
        isWorkerMode = prefs.getBool("isWorker")!;
      }
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MainHomepage(
              isWorkerDashboard: isWorkerMode,
              selectedPage: 2,
            ),
          ),
          (Route<dynamic> route) => false);
      break;
    case "vendors":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Vendors()),
      );
      break;
    case "registrationselectservice":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegistrationSelectService()),
      );
      break;
    case "applicationstatus":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ApplicationStatus()),
      );
      break;
    case "personalshopping":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PersonalShopping()),
      );
      break;
    case "salespayment":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SalesPayment()),
      );
      break;
    case "accountsettings":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AccountSettings()),
      );
      break;
    case "deleteaccount":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DeleteAccount()),
      );
      break;
    case "resetpasswordloggedin":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResetPasswordLoggedIn()),
      );
      break;
    case "support":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Support()),
      );
      break;
    case "notifications":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Notifications()),
      );
      break;
    case "myservices":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyServices()),
      );
      break;
    case "promotions":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Promotions()),
      );
      break;
    case "workerappreciation":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WorkerAppreciation()),
      );
      break;
    case "addmoney":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddMoney()),
      );
      break;
    case "transfermoney":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TransferMoney()),
      );
      break;
    case "emergency":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Emergency()),
      );
      break;
    case "addvendor":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddVendor()),
      );
      break;
    case "investment":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Investment()),
      );
      break;
    case "favorite":
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Favorite()),
      );
      break;
    default:
      toastContainer(text: "page does not exit", backgroundColor: BColors.red);
      break;
  }
}
