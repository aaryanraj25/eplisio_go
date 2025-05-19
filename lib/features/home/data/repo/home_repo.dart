import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/core/utils/time_utils.dart';
import 'package:eplisio_go/features/auth/data/model/auth_model.dart';
import 'package:eplisio_go/features/home/data/model/home_model.dart';
import 'package:get_storage/get_storage.dart';

class HomeRepository {
  final ApiClient _apiClient;
  final GetStorage _storage;

  HomeRepository({
    required ApiClient apiClient,
    required GetStorage storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  // Get User Data
  Future getUserData() async {
    try {
      // First try to get from local storage
      final userData = _storage.read('user');
      if (userData != null) {
        return EmployeeModel.fromJson(userData);
      }

      // If not in storage, fetch from API
      final response = await _apiClient.get('/employee/profile');
      final user = EmployeeModel.fromJson(response.data['employee_profile']);

      // Save to storage
      await _storage.write('user', response.data['employee_profile']);

      // Also save admin profile if needed
      if (response.data['admin_profile'] != null) {
        await _storage.write('admin', response.data['admin_profile']);
      }

      return user;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<ClockResponseModel> clockOut(
      {double? latitude, double? longitude}) async {
    try {
      Map<String, dynamic> queryParams = {};

      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude;
        queryParams['longitude'] = longitude;
      }

      final istTime = TimeUtils.nowIST();
      final utcTime = TimeUtils.fromIST(istTime);
      queryParams['clock_out_time'] = utcTime.toIso8601String();

      final response = await _apiClient.post(
        '/employee/clock-out',
        queryParameters: queryParams,
      );

      return ClockResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to clock out: $e');
    }
  }

  Future<ClockResponseModel> clockIn({
    required bool workFromHome,
    required double latitude,
    required double longitude,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'work_from_home': workFromHome,
        'latitude': latitude,
        'longitude': longitude,
      };

      final istTime = TimeUtils.nowIST();
      final utcTime = TimeUtils.fromIST(istTime);
      queryParams['clock_in_time'] = utcTime.toIso8601String();

      final response = await _apiClient.post(
        '/employee/clock-in',
        queryParameters: queryParams,
      );

      return ClockResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to clock in: $e');
    }
  }

  Future<ClockInfoModel> getClockInTime() async {
    try {
      final response = await _apiClient.get('/employee/clock-in-time');
      return ClockInfoModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get clock-in time: $e');
    }
  }

  // Update Employee Location
  Future updateLocation(double latitude, double longitude) async {
    try {
      final response = await _apiClient.post(
        '/employee/location',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  // Get Statistics
  Future getStatistics() async {
    try {
      final response = await _apiClient.get('/employee/stats');
      return StatisticsModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}
