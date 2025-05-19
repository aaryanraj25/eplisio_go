import 'dart:async';
import 'package:eplisio_go/features/auth/data/model/auth_model.dart';
import 'package:eplisio_go/features/auth/data/repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eplisio_go/core/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;

  final Rx<EmployeeModel> currentEmployee = EmployeeModel.empty().obs;
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isOTPSent = false.obs;
  final RxBool isResendingOTP = false.obs;
  final RxInt resendTimer = 0.obs;
  Timer? _resendTimer;

  AuthController({required AuthRepository repository})
      : _repository = repository;

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void checkAuthStatus() {
    isAuthenticated.value = _repository.isLoggedIn();

    if (isAuthenticated.value) {
      final employee = _repository.getCurrentEmployee();
      if (employee != null) {
        currentEmployee.value = employee;
      }
    }
  }

  Future<void> login({required String email, required String password}) async {
    if (isLoading.value) return; // Prevent multiple requests

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.login(
        email: email,
        password: password,
      );

      currentEmployee.value = response.employee;
      isAuthenticated.value = true;

      // Navigate to dashboard
      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      _handleError('Failed to login: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestOTP(String email) async {
    if (isLoading.value || isResendingOTP.value) return;

    try {
      isResendingOTP.value = true;
      errorMessage.value = '';

      await _repository.requestPasswordResetOTP(email);

      isOTPSent.value = true;
      _startResendTimer();

      Get.snackbar(
        'Success',
        'OTP has been sent to your email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      _handleError('Failed to send OTP: ${e.toString()}');
    } finally {
      isResendingOTP.value = false;
    }
  }

  void _startResendTimer() {
    resendTimer.value = 120; // 2 minutes
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> setPassword({
    required String email,
    required String password,
    required String otp,
  }) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.setPassword(
        email: email,
        password: password,
        otp: otp,
      );

      currentEmployee.value = response.employee;

      // Show success dialog
      await Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Password Set Successfully',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your password has been set successfully. You can now login to your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.offAllNamed(Routes.LOGIN);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Go to Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      _handleError('Failed to set password. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _repository.logout();

      // Reset states
      currentEmployee.value = EmployeeModel.empty();
      isAuthenticated.value = false;

      // Navigate to login screen
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      _handleError('Failed to logout. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleError(String message) {
    errorMessage.value = message;
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      duration: const Duration(seconds: 3),
    );
  }
}
