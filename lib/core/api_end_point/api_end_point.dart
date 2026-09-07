import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndPoint {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://api.zipbee.sg/api/v1';
  static String get socketUrl =>
      dotenv.env['SOCKET_URL'] ?? 'https://api.zipbee.sg';

  static String get login => '$baseUrl/auth/login';
  static String get loginVerify => '$baseUrl/auth/login/verify-otp';
  static String get signUp => '$baseUrl/auth/signup';
  static String get verify => '$baseUrl/auth/verify';
  static String get forgetPass => '$baseUrl/auth/forgot-password';
  static String get forgetVerify => '$baseUrl/auth/forgetpass/verify-otp';
  static String get resetPass => '$baseUrl/auth/forgot/reset-password';
  static String get getProfile => '$baseUrl/users/me';
  static String get getUserById => '$baseUrl/users';
  static String get softDelete => '$baseUrl/users/soft/{id}';
  static String get logOut => '$baseUrl/auth/logout';
  static String get changePassword => '$baseUrl/auth/reset-password';
  static String get refreshToken => '$baseUrl/auth/refresh';
  static String get faq => '$baseUrl/faq';
  static String get faqRole => '$baseUrl/faq/faqs-by-role';
  static String get updateRiderProfile =>
      '$baseUrl/raider-profile/update-rider-profile';
  static String get autoPopupSettings =>
      '$baseUrl/raider-profile/settings/auto-popup';
  static String get feedRefreshRateSettings =>
      '$baseUrl/raider-profile/settings/feed-refresh-rate';

  static String get riderRegistration =>
      '$baseUrl/raider-profile/raider-registration';

  static String get fileUpload => '$baseUrl/auth/upload';

  static String get orderFeed => '$baseUrl/order/feed';
  static String get orderDeclineReset => '$baseUrl/order/decline/reset';
  static String get orderOnGoing => '$baseUrl/order/raider/mine';
  static String orderRaiderConfirmation(int orderId) =>
      '$baseUrl/order/raider-confirmation/$orderId';
  static String reorderOrderStops(int orderId) =>
      '$baseUrl/order/$orderId/reorder-stops';

  static String get addMoney => '$baseUrl/wallet/add-money/mobile';

  // Wallet History endpoint (userId will be added dynamically)
  static String getWalletHistory(String userId) =>
      '$baseUrl/wallet/user/walletHistory/$userId';
  static String get walletCheckoutSession =>
      '$baseUrl/wallet/checkout-session';

  // Stripe Express Account
  static String get createExpressAccount =>
      '$baseUrl/stripe/create-express-account';
  static String get resetExpressAccount =>
      '$baseUrl/stripe/reset-express-account';

  // Withdraw
  static String get withdraw => '$baseUrl/wallet/withdraw';
  static String get chatHistory => '$baseUrl/chat/messages';
  static String chatMarkAsRead(String conversationId) =>
      '$baseUrl/chat/read/$conversationId';
  static String get supportChat => '$baseUrl/users/admin';
  static String get serviceZone => '$baseUrl/service-zone';

  // Earning Summary
  static String get earnMoney => '$baseUrl/wallet/earn-money';

  // Help Center endpoints
  static String get aboutUs => '$baseUrl/aboutus';
  static String get helpArticles => '$baseUrl/article';
  static String get contentManagement => '$baseUrl/content-management';
  static String get disputes => '$baseUrl/disputes';
  static String get disputeAppeals => '$baseUrl/dispute-appeals';
  static String getDisputes({required int page, required int limit}) =>
      '$baseUrl/disputes?page=$page&limit=$limit&participantType=rider';
  static String get upload => '$baseUrl/auth/upload';

  // Notifications
  static String get notification => '$baseUrl/notifications';
  static String get notificationFcmToken => '$baseUrl/notifications/fcm-token';
  static String get notificationUnreadCount =>
      '$baseUrl/notifications/unread-count';
  static String notificationMarkAsRead(String id) =>
      '$baseUrl/notifications/$id/mark-read';
  static String get notificationID => '$baseUrl/notifications/admin/{id}';

  static String get supportContact =>
      '$baseUrl/additional-services/service-email-number';
}
