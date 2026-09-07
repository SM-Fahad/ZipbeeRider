import 'dart:convert';
import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AuthService {
  static final Logger logger = Logger();

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
  };

  // ============================================================
  //                           SIGN UP
  // ============================================================
  static Future<Map<String, dynamic>> signUp({
    required String phone,
    required String username,
    required String email,
    required String password,
    String referralCode = "",
  }) async {
    try {
      final url = Uri.parse(ApiEndPoint.signUp);

      final body = {
        "phone": phone,
        "username": username,
        "email": email,
        "password": password,
        "referral_code": referralCode,
        "role_name": "RAIDER",
      };

      await SharedPreferencesHelper.saveEmail(email);

      logger.i("SIGNUP URL => $url");
      logger.i("SIGNUP BODY => $body");

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(response.body);
      logger.i("SIGNUP RESPONSE => $decoded");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "message": decoded["message"]};
      }

      return {
        "success": false,
        "message": decoded["message"] ?? "Signup failed",
      };
    } catch (e) {
      logger.e("SIGNUP ERROR => $e");
      return {"success": false, "message": "Signup failed"};
    }
  }

  // ============================================================
  //                           LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> login(
    Map<String, dynamic> loginData,
  ) async {
    try {
      final url = Uri.parse(ApiEndPoint.login);

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(loginData),
      );

      final decoded = jsonDecode(response.body);
      logger.i("LOGIN RESPONSE => $decoded");

      String? errorMessage;
      if (decoded is Map && decoded.containsKey("message")) {
        final msg = decoded["message"];
        if (msg is String) {
          errorMessage = msg;
        } else if (msg is List) {
          errorMessage = msg.join(", ");
        } else if (msg != null) {
          errorMessage = msg.toString();
        }
      }

      if ((response.statusCode >= 200 && response.statusCode < 300) ||
          (decoded is Map && decoded["access_token"] != null)) {
        return {
          "success": true,
          "access_token": decoded["access_token"],
          "refresh_token": decoded["refresh_token"],
        };
      }
      return {
        "success": false,
        "message": errorMessage ?? "Login failed",
      };
    } catch (e) {
      logger.e("LOGIN ERROR => $e");
      return {"success": false, "message": "Login failed: ${e.toString()}"};
    }
  }
  // static Future<Map<String, dynamic>> login({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     final url = Uri.parse(ApiEndPoint.login);

  //     final response = await http.post(
  //       url,
  //       headers: _headers,
  //       body: jsonEncode({"email": email, "password": password}),
  //     );

  //     final decoded = jsonDecode(response.body);
  //     logger.i("LOGIN RESPONSE => $decoded");

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return {
  //         "success": true,
  //         "access_token": decoded["access_token"],
  //         "refresh_token": decoded["refresh_token"],
  //       };
  //     }

  //     return {
  //       "success": false,
  //       "message": decoded["message"] ?? "Login failed",
  //     };
  //   } catch (e) {
  //     logger.e("LOGIN ERROR => $e");
  //     return {"success": false, "message": "Login failed"};
  //   }
  // }

  // ============================================================
  //                         SEND OTP
  // ============================================================
  static Future<Map<String, dynamic>> sendOtp({required String email}) async {
    try {
      final url = Uri.parse(ApiEndPoint.forgetPass);

      logger.i("SEND OTP URL => $url");
      logger.i("SEND OTP BODY => {email: $email}");

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({"email": email}),
      );

      final decoded = jsonDecode(response.body);
      logger.i("SEND OTP RESPONSE => $decoded");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      }

      return {
        "success": false,
        "message": decoded["message"] ?? "OTP send failed",
      };
    } catch (e) {
      logger.e("SEND OTP ERROR => $e");
      return {"success": false, "message": "OTP send failed"};
    }
  }

  // ============================================================
  //                        VERIFY OTP
  // ============================================================
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
    required String endpoint,
  }) async {
    try {
      final url = Uri.parse(endpoint);

      logger.i("VERIFY OTP URL => $url");

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({"email": email, "otp": otp}),
      );

      logger.i("VERIFY OTP BODY => {email: $email, otp: $otp}");
      logger.i("VERIFY OTP RESPONSE => ${response.body}");

      final decoded = jsonDecode(response.body);
      logger.i("VERIFY OTP RESPONSE => $decoded");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "access_token": decoded["access_token"]};
      }

      return {
        "success": false,
        "message": decoded["message"] ?? "OTP verification failed",
      };
    } catch (e) {
      logger.e("VERIFY OTP ERROR => $e");
      return {"success": false, "message": "OTP verification failed"};
    }
  }
}
