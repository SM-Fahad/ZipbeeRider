import 'dart:convert';

import 'package:ZipBee_Driver/core/api_end_point/api_end_point.dart';
import 'package:ZipBee_Driver/core/shared_prefs_service/shared_preference_helper.dart';
import 'package:ZipBee_Driver/features/auth/vehicle_details/model/vehicle_type_option_model.dart';
import 'package:http/http.dart' as http;

class VehicleTypeService {
  Future<List<VehicleTypeOptionModel>> fetchVehicleTypes() async {
    final token = await SharedPreferencesHelper.getAccessToken();

    final response = await http.get(
      Uri.parse('${ApiEndPoint.baseUrl}/admin/vehicle-types?isActive=true'),
      headers: {
        'accept': '*/*',
        'Authorization': token != null && token.isNotEmpty
            ? 'Bearer $token'
            : '',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch vehicle types');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final dataWrapper = json['data'] as Map<String, dynamic>? ?? {};
    final rawList = dataWrapper['data'] as List? ?? [];

    return rawList
        .whereType<Map>()
        .map(
          (item) =>
              VehicleTypeOptionModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
