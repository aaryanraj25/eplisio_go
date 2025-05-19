import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/features/clinic/data/model/clinic_model.dart';
import 'package:get_storage/get_storage.dart';

class HospitalsRepository {
  final ApiClient apiClient;
  final _storage = GetStorage();

  HospitalsRepository({required this.apiClient});

  Map<String, String> get _headers {
    final token = _storage.read('token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<ClinicsResponses> getHospitals() async {
    try {
      final response = await apiClient.get(
        '/orders/employee/employee/clinics',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return ClinicsResponses.fromJson(response.data);
      }
      throw 'Failed to fetch hospitals';
    } catch (e) {
      throw 'Failed to fetch hospitals: $e';
    }
  }

  Future<List<ClinicSearchResult>> searchHospitals(String query) async {
    try {
      final response = await apiClient.get(
        '/hospital/search',
        queryParameters: {'name': query},
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => ClinicSearchResult.fromJson(json))
            .toList();
      }
      throw 'Failed to search hospitals';
    } catch (e) {
      throw 'Failed to search hospitals: $e';
    }
  }

  Future<void> addHospitalFromGoogle(String placeId) async {
    try {
      final response = await apiClient.post(
        '/hospital/employee/clinics/google-place',
        queryParameters: {'place_id': placeId},
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw 'Failed to add hospital';
      }
    } catch (e) {
      throw 'Failed to add hospital: $e';
    }
  }

  Future<void> addClinicManually(ClinicManualCreate clinic) async {
    try {
      final response = await apiClient.post(
        '/hospital/employee/clinics/manual',
        data: clinic.toJson(),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw 'Failed to add clinic';
      }
    } catch (e) {
      throw 'Failed to add clinic: $e';
    }
  }
}
