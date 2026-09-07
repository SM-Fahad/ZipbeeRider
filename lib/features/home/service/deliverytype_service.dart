import 'dart:convert';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/home/model/delivery_type_model.dart';
import 'package:http/http.dart' as http;

class DeliveryTypeService {
  static List<DeliveryTypeModel>? _cachedDeliveryTypes;

  static List<DeliveryTypeModel>? get cachedDeliveryTypes => _cachedDeliveryTypes;

  Future<List<DeliveryTypeModel>> fetchDeliveryTypes({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedDeliveryTypes != null && _cachedDeliveryTypes!.isNotEmpty) {
      return _cachedDeliveryTypes!;
    }

    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      final response = await http.get(
        Uri.parse('${ApiEndPoint.baseUrl}/delivery-types'),
        headers: {
          'accept': '*/*',
          'Authorization': token != null && token.isNotEmpty
              ? 'Bearer $token'
              : '',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final dataWrapper = json['data'] as Map<String, dynamic>? ?? {};
        final rawList = dataWrapper['data'] as List? ?? [];

        final list = rawList
            .whereType<Map>()
            .map(
              (item) =>
                  DeliveryTypeModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();

        if (list.isNotEmpty) {
          _cachedDeliveryTypes = list;
        }
        return list;
      }
    } catch (_) {
      if (_cachedDeliveryTypes != null) {
        return _cachedDeliveryTypes!;
      }
    }

    return _cachedDeliveryTypes ?? [];
  }
}
