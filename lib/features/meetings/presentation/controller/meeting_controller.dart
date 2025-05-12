import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/core/utils/location_services.dart';
import 'package:eplisio_go/features/clinic/data/model/clinic_model.dart';
import 'package:eplisio_go/features/meetings/data/model/meeting_model.dart';
import 'package:eplisio_go/features/meetings/data/repo/meeting_repo.dart';
import 'package:eplisio_go/features/product/data/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeetingsController extends GetxController {
  final MeetingsRepository _repository;

  final isLoading = false.obs;
  final error = Rxn<String>();

  final activeMeeting = Rxn<MeetingModel>();
  final completedMeetings = <MeetingModel>[].obs;

  // Filters
  final filterStartDate = Rxn<DateTime>();
  final filterEndDate = Rxn<DateTime>();
  final filterMeetingType = Rxn<String>();
  final filterClinicId = Rxn<String>();
  final filterClientId = Rxn<String>();
  final searchQuery = ''.obs;
  final RxList<ClinicModel> nearbyClinics = <ClinicModel>[].obs;
  final LocationService _locationService = Get.find();
  final RxList<ClientModel> clients = <ClientModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final isProductsLoading = false.obs;

  final skip = 0.obs;
  final limit = 10.obs;

  MeetingsController(this._repository);

  @override
  void onInit() {
    super.onInit();
    checkActiveMeeting();
    fetchCompletedMeetings();
  }

  Future<void> fetchNearbyClinics() async {
    try {
      isLoading.value = true;
      final location = await LocationService.getCurrentLocation();

      final clinics = await _repository.getNearbyClinics(
        latitude: location['latitude']!,
        longitude: location['longitude']!,
      );
      nearbyClinics.value = clinics;
    } catch (e) {
      debugPrint('Error fetching nearby clinics: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProducts() async {
    try {
      isProductsLoading.value = true;
      final response = await Get.find<ApiClient>().get(
        '/product/employee/list',
        queryParameters: {'limit': 100, 'skip': 0},
      );
      products.value = (response.data['products'] as List)
          .map((product) => ProductModel.fromJson(product))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch products: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isProductsLoading.value = false;
    }
  }

  Future<void> checkOut({
    required String meetingId,
    required String meetingType,
    List<ProductCheckout>? products,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      
      final request = CheckoutRequest(
        meetingType: meetingType,
        products: products,
        notes: notes,
      );

      await _repository.checkOut(
        meetingId: meetingId,
        request: request,
      );

      Get.back(); // Close dialog
      await checkActiveMeeting(); // Refresh active meeting
      await fetchCompletedMeetings(); // Refresh completed meetings

      Get.snackbar(
        'Success',
        'Meeting checked out successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to check out: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchClients({
    required String clinicId,
    String? search,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      isLoading.value = true;
      final response = await _repository.getClients(
        clinicId: clinicId,
        search: search,
        skip: skip,
        limit: limit,
      );
      clients.value = response;
    } catch (e) {
      debugPrint('Error fetching clients: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkIn({
    required String clinicId,
    required String clientId, // Add clientId parameter
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      final location = await LocationService.getCurrentLocation();

      await _repository.checkIn(
        clinicId: clinicId,
        clientId: clientId, // Pass clientId to repository
        latitude: location['latitude']!,
        longitude: location['longitude']!,
        notes: notes,
      );
    } catch (e) {
      debugPrint('Error checking in: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkActiveMeeting() async {
    try {
      isLoading.value = true;
      error.value = null;
      activeMeeting.value = await _repository.getActiveMeeting();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCompletedMeetings() async {
    try {
      isLoading.value = true;
      error.value = null;

      final meetings = await _repository.getCompletedMeetings(
        skip: skip.value,
        limit: limit.value,
        startDate: filterStartDate.value,
        endDate: filterEndDate.value,
        meetingType: filterMeetingType.value,
        clinicId: filterClinicId.value,
        clientId: filterClientId.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      completedMeetings.value = meetings;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    filterStartDate.value = null;
    filterEndDate.value = null;
    filterMeetingType.value = null;
    filterClinicId.value = null;
    filterClientId.value = null;
    searchQuery.value = '';
    fetchCompletedMeetings();
  }
}
