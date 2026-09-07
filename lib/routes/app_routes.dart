import 'package:ZipBee_Driver/features/account/screen/account_screen.dart';
import 'package:ZipBee_Driver/features/account_vehicle/screen/view_vehicle_screen.dart';
import 'package:ZipBee_Driver/features/account_vehicle/screen/screen.dart';
import 'package:ZipBee_Driver/features/app_coures/quiz_congratulation/screen/quiz_congratulation_screen.dart';
import 'package:ZipBee_Driver/features/app_coures/screen/app_coures_screen.dart';
import 'package:ZipBee_Driver/features/app_coures/try_agin/screen/try-agin_screen.dart';
import 'package:ZipBee_Driver/features/app_quzi/screen/app_quiz_screen.dart';
import 'package:ZipBee_Driver/features/auth/forgot_password/screen/forgot_password_screen.dart';
import 'package:ZipBee_Driver/features/auth/login/screen/login_screen.dart';
import 'package:ZipBee_Driver/features/auth/login/screen/profile_check_screen.dart';
import 'package:ZipBee_Driver/features/auth/rider_details/screen/rider_details_screen.dart';
import 'package:ZipBee_Driver/features/auth/verification/screen/verification_screen.dart';
import 'package:ZipBee_Driver/features/auth/wallet/screen/wallet_screen.dart';
import 'package:ZipBee_Driver/features/bottom_navbar/screen/bottom_navbar_screen.dart';
import 'package:ZipBee_Driver/features/chat/screen/raider_chat_screen.dart';
import 'package:ZipBee_Driver/features/driver_preference/distance_radius/screen/distance_radius_screen.dart';
import 'package:ZipBee_Driver/features/driver_preference/screen/driver_preference_screen.dart';
import 'package:ZipBee_Driver/features/google_map/screen/google_map_screen.dart';
import 'package:ZipBee_Driver/features/home/screen/home_screen.dart';
import 'package:ZipBee_Driver/features/incentives/screen/incentives_screen.dart';
import 'package:ZipBee_Driver/features/notifications/screen/notifications_screen.dart';
import 'package:ZipBee_Driver/features/notifications/screen/promotion_details_screen.dart';
import 'package:ZipBee_Driver/features/notifications/model/notification_model.dart';
import 'package:ZipBee_Driver/features/onboarding/screen/onboarding_screen.dart';
import 'package:ZipBee_Driver/features/records/screen/records_screen.dart';
import 'package:ZipBee_Driver/features/splash/screen/splash_screen.dart';
import 'package:get/get.dart';

import '../features/delivery_success/screen/screen.dart';

class AppRoutes {
  static String splashScreen = '/splashScreen';
  static String onboardingScreen = '/onboardingScreen';
  static String homeScreen = '/homeScreen';
  static String accountScreen = '/accountScreen';
  static String incentiveScreen = '/incentiveScreen';
  static String recordsScreen = '/recordsScreen';
  static String loginSignupScreen = '/loginSignupScreen';
  static String forgotPasswordScreen = '/forgotPasswordScreen';
  static String profileCheckScreen = '/profileCheckScreen';
  static String verificationScreen = '/verificationScreen';
  static String appQuizScreen = '/appQuizScreen';
  static String appCouresScreen = '/appCouresScreen';
  static String quizCongratulationScreen = '/quizCongratulationScreen';
  static String tryAginScreen = '/tryAginScreen';
  static String distanceRadiusScreen = '/distanceRadiusScreen';
  static String bottomNavbarScreen = '/BottomNavbarScreen';
  static String driverPreferenceScreen = '/driverPreferenceScreen';
  static String riderDetailsScreen = '/riderDetailsScreen';
  static String walletScreen = '/walletScreen';
  static String deliverySuccessScreen = '/deliverySuccessScreen';
  static String viewVehicleScreen = '/viewVehicleScreen';
  static String updateVehicleScreen = '/updateVehicleScreen';

  static String riderChatScreen = '/riderChatScreen';

  static String notificationsScreen = '/notifications';
  static String notificationPromotionDetails = '/notificationPromotionDetails';
  static String googleMapScreen = '/googleMapScreen';

  static String getSplashScreen() => splashScreen;
  static String getOnboardingScreen() => onboardingScreen;
  static String getHomeScreen() => homeScreen;
  static String getAccountScreen() => accountScreen;
  static String getIncentiveScreen() => incentiveScreen;
  static String getRecordsScreen() => recordsScreen;
  static String getLoginSignupScreen() => loginSignupScreen;
  static String getForgotPasswordScreen() => forgotPasswordScreen;
  static String getProfileCheckScreen() => profileCheckScreen;
  static String getVerificationScreen() => verificationScreen;
  static String getAppQuizScreen() => appQuizScreen;
  static String getAppCouresScreen() => appCouresScreen;
  static String getquizCongratulationScreen() => quizCongratulationScreen;
  static String gettryAginScreen() => tryAginScreen;
  static String getDistanceRadiusScreen() => distanceRadiusScreen;
  static String getBottomNavbarScreen() => bottomNavbarScreen;
  static String getDriverPreferenceScreen() => driverPreferenceScreen;
  static String getRiderDetailsScreen() => riderDetailsScreen;
  static String getWalletScreen() => walletScreen;
  static String getdeliverySuccessScreen() => deliverySuccessScreen;
  static String getRiderChatScreen() => riderChatScreen;

  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: onboardingScreen, page: () => OnboardingScreen()),
    GetPage(name: homeScreen, page: () => HomeScreen()),
    GetPage(name: accountScreen, page: () => AccountScreen()),
    GetPage(name: incentiveScreen, page: () => IncentiveScreen()),
    GetPage(name: recordsScreen, page: () => RecordsScreen()),
    GetPage(name: loginSignupScreen, page: () => LoginSignupScreen()),
    GetPage(name: forgotPasswordScreen, page: () => ForgotPasswordScreen()),
    GetPage(name: profileCheckScreen, page: () => ProfileCheckScreen()),
    GetPage(name: verificationScreen, page: () => VerificationScreen()),
    GetPage(name: appQuizScreen, page: () => AppQuizScreen()),
    GetPage(name: appCouresScreen, page: () => AppCouresScreen()),
    GetPage(
      name: quizCongratulationScreen,
      page: () => QuizCongratulationScreen(),
    ),
    GetPage(name: tryAginScreen, page: () => TryAginScreen()),
    GetPage(name: distanceRadiusScreen, page: () => DistanceRadiusScreen()),
    GetPage(name: bottomNavbarScreen, page: () => BottomNavbarScreen()),
    GetPage(name: driverPreferenceScreen, page: () => DriverPreferenceScreen()),
    GetPage(name: riderDetailsScreen, page: () => RiderDetailsScreen()),
    GetPage(name: walletScreen, page: () => WalletScreen()),
    GetPage(name: deliverySuccessScreen, page: () => DeliverySuccessScreen()),
    GetPage(name: viewVehicleScreen, page: () => ViewVehicleScreen()),
    GetPage(name: updateVehicleScreen, page: () => UpdateVehicleScreen()),

    GetPage(name: riderChatScreen, page: () => RiderChatScreen()),

    GetPage(name: notificationsScreen, page: () => NotificationsScreen()),
    GetPage(
      name: notificationPromotionDetails,
      page: () => PromotionDetailsScreen(item: Get.arguments as NotificationModel),
    ),
    GetPage(name: googleMapScreen, page: () => GoogleMapScreen()),
  ];
}
