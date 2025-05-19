import 'package:eplisio_go/features/clinic/data/model/clinic_model.dart';
import 'package:eplisio_go/features/clinic/data/repo/clinic_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

class HospitalsController extends GetxController {
  final HospitalsRepository _repository;

  HospitalsController(this._repository);

  final RxList<ClinicModel> hospitals = <ClinicModel>[].obs;
  final RxList<ClinicSearchResult> searchResults = <ClinicSearchResult>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isAdding = false.obs;
  final RxString error = ''.obs;
  final RxInt totalHospitals = 0.obs;
  final RxBool coordinatesProvided = false.obs;
  final RxString workMode = ''.obs;

  final searchController = TextEditingController();
  final debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  @override
  void onInit() {
    super.onInit();
    fetchHospitals();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchHospitals() async {
    try {
      isLoading.value = true;
      error.value = '';

      final result = await _repository.getHospitals();
      hospitals.value = result.clinics;
      totalHospitals.value = result.total;
    } catch (e) {
      error.value = e.toString();
      showErrorSnackbar('Failed to fetch hospitals');
    } finally {
      isLoading.value = false;
    }
  }

  void searchHospitals(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    debouncer(() async {
      try {
        isSearching.value = true;
        final results = await _repository.searchHospitals(query);
        searchResults.value = results;
      } catch (e) {
        showErrorSnackbar('Failed to search hospitals');
      } finally {
        isSearching.value = false;
      }
    });
  }

  Future<void> addHospitalFromGoogle(ClinicSearchResult searchResult) async {
    try {
      isAdding.value = true;
      await _repository.addHospitalFromGoogle(searchResult.placeId);

      Get.back(); // Close search dialog
      await fetchHospitals(); // Refresh list

      showSuccessSnackbar('Hospital added successfully');
    } catch (e) {
      showErrorSnackbar(e.toString());
    } finally {
      isAdding.value = false;
    }
  }

  Future<void> addClinicManually(ClinicManualCreate clinic) async {
    try {
      isAdding.value = true;
      await _repository.addClinicManually(clinic);

      Get.back(); // Close dialog
      await fetchHospitals(); // Refresh list

      showSuccessSnackbar('Facility added successfully');
    } catch (e) {
      showErrorSnackbar(e.toString());
    } finally {
      isAdding.value = false;
    }
  }

  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(8),
      duration: const Duration(seconds: 3),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
    );
  }

  void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(8),
      duration: const Duration(seconds: 3),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }

  // Helper method to refresh data
  Future<void> refreshHospitals() async {
    await fetchHospitals();
  }

  // Method to clear search
  void clearSearch() {
    searchController.clear();
    searchResults.clear();
  }

  // Method to check if search is active
  bool get isSearchActive => searchController.text.isNotEmpty;

  // Method to get hospital by id
  ClinicModel? getHospitalById(String id) {
    try {
      return hospitals.firstWhere((hospital) => hospital.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method to check if a hospital exists
  bool hospitalExists(String id) {
    return hospitals.any((hospital) => hospital.id == id);
  }

  // Method to get total active hospitals
  int get activeHospitalsCount {
    return hospitals.where((hospital) => hospital.status == 'active').length;
  }

  // Method to get hospitals by type
  List<ClinicModel> getHospitalsByType(String type) {
    return hospitals.where((hospital) => hospital.type == type).toList();
  }

  // Method to get hospitals by city
  List<ClinicModel> getHospitalsByCity(String city) {
    return hospitals.where((hospital) => hospital.city == city).toList();
  }

  // Method to get unique cities
  List<String> get uniqueCities {
    return hospitals.map((hospital) => hospital.city).toSet().toList();
  }

  // Method to get unique types
  List<String> get uniqueTypes {
    return hospitals.map((hospital) => hospital.type).toSet().toList();
  }

  // Method to sort hospitals by rating
  void sortByRating({bool ascending = false}) {
    hospitals.sort((a, b) => ascending
        ? a.rating!.compareTo(b.rating!)
        : b.rating!.compareTo(a.rating!));
    hospitals.refresh();
  }

  // Method to sort hospitals by name
  void sortByName({bool ascending = true}) {
    hospitals.sort((a, b) =>
        ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
    hospitals.refresh();
  }

  // Method to sort hospitals by distance
  void sortByDistance({bool ascending = true}) {
    hospitals.sort((a, b) => ascending
        ? a.distance!.compareTo(b.distance!)
        : b.distance!.compareTo(a.distance!));
    hospitals.refresh();
  }

  // Method to filter hospitals by rating threshold
  List<ClinicModel> getHospitalsByMinRating(double minRating) {
    return hospitals.where((hospital) => hospital.rating! >= minRating).toList();
  }

  // Method to get hospitals within distance
  List<ClinicModel> getHospitalsWithinDistance(double maxDistance) {
    return hospitals
        .where((hospital) =>
            hospital.distance! <= maxDistance && hospital.withinRange!)
        .toList();
  }

  // Method to get hospitals with specific specialties
  List<ClinicModel> getHospitalsBySpecialty(String specialty) {
    return hospitals
        .where((hospital) => hospital.specialties!.contains(specialty))
        .toList();
  }

  // Method to get all unique specialties
}
