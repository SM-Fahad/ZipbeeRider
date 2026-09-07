import 'dart:convert';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class ServiceZoneService {
  static Future<Map<String, dynamic>> fetchServiceZones() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      final response = await http.get(
        Uri.parse(ApiEndPoint.serviceZone),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return {
        'statusCode': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      debugPrint('ServiceZoneService error: $e');
      return {'statusCode': 500, 'body': {}};
    }
  }

  static Future<LatLng?> getFirstZoneCenter() async {
    final res = await fetchServiceZones();
    final status = res['statusCode'] as int? ?? 500;
    if (status != 200) return null;

    try {
      final body = res['body'] as Map<String, dynamic>;
      final data = body['data']?['data'] ?? [];
      if (data is List && data.isNotEmpty) {
        final firstZone = data[0] as Map<String, dynamic>;
        final coords = firstZone['coordinates'] as List<dynamic>?;
        if (coords != null && coords.isNotEmpty) {
          double sumLat = 0.0;
          double sumLng = 0.0;
          int count = 0;

          for (final c in coords) {
            final lat = (c['lat'] as num).toDouble();
            final lng = (c['lng'] as num).toDouble();
            sumLat += lat;
            sumLng += lng;
            count++;
          }

          if (count > 0) {
            return LatLng(sumLat / count, sumLng / count);
          }
        }
      }
    } catch (e) {
      debugPrint('ServiceZoneService parse error: $e');
    }

    return null;
  }
}
