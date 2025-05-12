import 'package:eplisio_go/features/client/data/repo/client_repo.dart';
import 'package:eplisio_go/features/clinic/data/model/clinic_model.dart';
import 'package:eplisio_go/features/meetings/data/model/meeting_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientsController extends GetxController {
  final ClientsRepository _repository;
  
  ClientsController(this._repository);

  final RxList<ClientModel> clients = <ClientModel>[].obs;
  final RxList<ClinicModel> clinics = <ClinicModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClients();
    fetchClinics();
  }

  Future<void> fetchClients() async {
    try {
      isLoading.value = true;
      final result = await _repository.getClients();
      clients.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch clients',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchClinics() async {
    try {
      final result = await _repository.getClinics();
      clinics.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch clinics',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> createClient(Map<String, dynamic> clientData) async {
    try {
      isCreating.value = true;
      await _repository.createClient(clientData);
      await fetchClients();
      Get.back(); // Close dialog
      Get.snackbar(
        'Success',
        'Client created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create client',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCreating.value = false;
    }
  }
}