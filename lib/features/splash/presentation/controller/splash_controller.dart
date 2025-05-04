import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController {
  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  // In your SplashController, modify _checkAuthStatus to allow for external delay control:
  Future<void> checkAuthStatus({Duration? delay}) async {
    try {
      // Add your authentication check logic here
      final isLoggedIn = await _checkIfUserIsLoggedIn();

      // Use the provided delay or default to 3 seconds
      await Future.delayed(delay ?? Duration(seconds: 3));

      if (isLoggedIn) {
        Get.offAllNamed('/dashboard');
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print("Navigation error: $e");
      Get.offAllNamed('/login');
    }
  }

// Make this method public so it can be called from outside
  Future<bool> checkIfUserIsLoggedIn() async {
    return _checkIfUserIsLoggedIn();
  }

  Future<bool> _checkIfUserIsLoggedIn() async {
    try {
      final token = _storage.read('token');

      // Check if token exists and user is an employee
      if (token != null) {
        // Optional: You could also validate the token with the backend
        // or check if it's expired
        return true;
      }

      return false;
    } catch (e) {
      // Handle any errors that might occur when reading from storage
      print('Error checking login status: $e');
      return false;
    }
  }
}
