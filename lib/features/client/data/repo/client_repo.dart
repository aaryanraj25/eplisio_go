import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/features/clinic/data/model/clinic_model.dart';
import 'package:eplisio_go/features/meetings/data/model/meeting_model.dart';
import 'package:get_storage/get_storage.dart';

class ClientsRepository {
  final ApiClient apiClient;
  final _storage = GetStorage();

  ClientsRepository({required this.apiClient});

  Map<String, String> get _headers {
    final token = _storage.read('token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<ClientModel>> getClients() async {
    try {
      final response = await apiClient.get(
        '/clients',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data; // Direct array, no 'data' key
        return data.map((json) => ClientModel.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch clients');
    } catch (e) {
      throw Exception('Failed to fetch clients: $e');
    }
  }

  Future<List<ClinicModel>> getClinics() async {
    try {
      final response = await apiClient.get(
        '/orders/employee/employee/clinics',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final clinicsResponse = ClinicsResponses.fromJson(response.data);
        return clinicsResponse.clinics;
      }
      throw Exception('Failed to fetch clinics');
    } catch (e) {
      throw Exception('Failed to fetch clinics: $e');
    }
  }

  Future<void> createClient(Map<String, dynamic> clientData) async {
    try {
      final response = await apiClient.post(
        '/clients',
        data: clientData,
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create client');
      }
    } catch (e) {
      throw Exception('Failed to create client: $e');
    }
  }
}
