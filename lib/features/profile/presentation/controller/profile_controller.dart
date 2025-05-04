import 'package:eplisio_go/features/profile/data/model/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfileController extends GetxController {
  final _profile = Rx<ProfileModel>(ProfileModel.empty());
  final _isLoading = false.obs;
  final GetStorage _storage = GetStorage();

  ProfileModel get profile => _profile.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      _isLoading.value = true;
      // Implement your API call here
      // Example:
      // final response = await _repository.getProfile();
      // _profile.value = response;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProfileImage() async {
    // Implement image picker logic
  }

  void navigateToEditProfile() {
    Get.toNamed('/profile/edit');
  }

  void navigateToAttendance() {
    Get.toNamed('/attendance');
  }

  Future<void> logout() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _storage.erase();
      Get.offAllNamed('/login');
    }
  }
}
