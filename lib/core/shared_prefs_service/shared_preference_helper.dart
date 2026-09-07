import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  // ================= KEYS =================
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'userId';
  static const String _raiderIdKey = 'raiderId';
  static const String _selectedRoleKey = 'selectedRole';
  static const String _categoriesKey = 'categories';
  static const String _isLoginKey = 'isLogin';
  static const String _welcomeDialogKey = 'isDriverVerificationDialogShown';
  static const String _showOnboardKey = 'showOnboard';
  static const String _emailKey = 'email';
  static const String _firstRunKey = 'is_first_run_of_app';

  // ================= TOKEN =================

  /// Save access token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setBool(_isLoginKey, true);
  }

  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Save refresh token (optional)
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  /// Get access token (primary)
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  ///  Alias (for safety – used in HomeController)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // ================= LOGIN STATE =================

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogin = prefs.getBool(_isLoginKey) ?? false;
    final token = prefs.getString(_accessTokenKey);
    return isLogin && token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.setBool(_isLoginKey, false);
  }

  // ================= USER =================

  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> saveRaiderId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_raiderIdKey, id);
  }

  static Future<String?> getRaiderId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_raiderIdKey);
  }

  // ================= ROLE =================

  static Future<void> saveSelectedRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedRoleKey, role);
  }

  static Future<String?> getSelectedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedRoleKey);
  }

  // ================= CATEGORIES =================

  /// Save categories (id + name)
  static Future<void> saveCategories(
    List<Map<String, String>> categories,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoriesKey, jsonEncode(categories));
  }

  /// Get categories
  static Future<List<Map<String, String>>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_categoriesKey);
    if (json == null) return [];
    return List<Map<String, String>>.from(jsonDecode(json));
  }

  // ================= ONBOARD / DIALOG =================

  static Future<void> setWelcomeDialogShown(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeDialogKey, value);
  }

  static Future<bool> isWelcomeDialogShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeDialogKey) ?? false;
  }

  static Future<void> setShowOnboard(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showOnboardKey, value);
  }

  static Future<bool> getShowOnboard() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showOnboardKey) ?? false;
  }

  static Future<void> checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_firstRunKey) == null) {
      await prefs.clear();
      await prefs.setBool(_firstRunKey, false);
    }
  }

  static const String _feedRefreshRateKey = 'feedRefreshRate';

  static Future<void> saveFeedRefreshRate(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_feedRefreshRateKey, seconds);
  }

  static Future<int?> getFeedRefreshRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_feedRefreshRateKey);
  }

  // ================= CLEAR ALL =================

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool(_firstRunKey, false);
  }
}
