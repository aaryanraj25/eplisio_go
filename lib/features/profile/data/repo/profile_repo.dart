import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/features/profile/data/model/profile_model.dart';
import 'package:get_storage/get_storage.dart';

class ProfileRepository {
  final ApiClient apiClient;
  final _storage = GetStorage();

  ProfileRepository({required this.apiClient});

  Map<String, String> get _headers {
    final token = _storage.read('token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<ProfileResponse> getProfile() async {
    try {
      final response = await apiClient.get(
        '/employee/profile',
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return ProfileResponse.fromJson(response.data);
      }
      throw 'Failed to fetch profile';
    } catch (e) {
      throw 'Failed to fetch profile: $e';
    }
  }
}