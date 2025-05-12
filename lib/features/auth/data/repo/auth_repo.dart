import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/features/auth/data/model/auth_model.dart';
import 'package:get_storage/get_storage.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final GetStorage _storage;

  AuthRepository({
    required ApiClient apiClient,
    required GetStorage storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  Future<EmployeeAuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/employee/employee-login',
        queryParameters: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = EmployeeAuthResponse.fromJson(response.data);
      await _storage.write('token', authResponse.token);
      print("1");
      await _storage.write('employee', authResponse.employee.toJson());
      print("1");
      await _storage.write('user_type', 'employee');
      print("1");

      return authResponse;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<EmployeeAuthResponse> setPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/employee/Set-employee-password',
        queryParameters: {
          'email': email,
          'password': password,
        },
      );
      final authResponse = EmployeeAuthResponse.fromJson(response.data);
      return authResponse;
    } catch (e) {
      throw Exception('Failed to set password: $e');
    }
  }

  Future<void> logout() async {
    try {
    } catch (e) {
    } finally {
      await _storage.erase();
    }
  }

  bool isLoggedIn() {
    final token = _storage.read('token');
    final userType = _storage.read('user_type');
    return token != null && userType == 'employee';
  }

  EmployeeModel? getCurrentEmployee() {
    final employeeData = _storage.read('employee');
    if (employeeData != null) {
      return EmployeeModel.fromJson(employeeData);
    }
    return null;
  }
}
