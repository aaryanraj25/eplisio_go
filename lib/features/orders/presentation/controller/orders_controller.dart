import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/features/clinic/data/model/clinic_model.dart';
import 'package:eplisio_go/features/orders/data/model/orders_model.dart';
import 'package:eplisio_go/features/orders/data/repo/orders_repo.dart';
import 'package:eplisio_go/features/product/data/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  final OrdersRepository _repository;
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final isActionLoading = false.obs; // New loading state for actions
  final error = Rx<String?>(null);
  final selectedStatus = Rx<OrderStatus?>(null);

  // Cache for clinics and products
  final clinics = <ClinicModel>[].obs;
  final products = <ProductModel>[].obs;
  final isClinicsLoading = false.obs;
  final isProductsLoading = false.obs;

  OrdersController({required OrdersRepository repository})
      : _repository = repository;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    fetchClinicsAndProducts(); // Pre-fetch data
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      error.value = null;

      final fetchedOrders = await _repository.getOrders(
        status: selectedStatus.value,
      );
      orders.value = fetchedOrders;
    } catch (e) {
      error.value = 'Failed to fetch orders: $e';
      print('Error in fetchOrders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setStatus(OrderStatus? status) {
    selectedStatus.value = status;
    fetchOrders();
  }

  Future<void> fetchClinicsAndProducts() async {
    try {
      isClinicsLoading.value = true;
      isProductsLoading.value = true;

      // Fetch clinics
      final clinicsResponse = await Get.find<ApiClient>().get(
        '/orders/employee/employee/clinics',
        queryParameters: {'limit': 100, 'skip': 0},
      );
      clinics.value = (clinicsResponse.data['clinics'] as List)
          .map((clinic) => ClinicModel.fromJson(clinic))
          .toList();

      // Fetch products
      final productsResponse = await Get.find<ApiClient>().get(
        '/product/employee/list',
        queryParameters: {'limit': 100, 'skip': 0},
      );
      products.value = (productsResponse.data['products'] as List)
          .map((product) => ProductModel.fromJson(product))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch data: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isClinicsLoading.value = false;
      isProductsLoading.value = false;
    }
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      isActionLoading.value = true;
      await _repository.createOrder(orderData);
      await fetchOrders();
      Get.snackbar(
        'Success',
        'Order created successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      throw e;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> convertToRegularOrder(
      OrderModel order, double totalAmount) async {
    try {
      isActionLoading.value = true;
      await _repository.convertToRegularOrder(order, totalAmount);
      await fetchOrders();
      Get.back(); // Close the dialog
      Get.snackbar(
        'Success',
        'Order converted to pending successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to convert order: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isActionLoading.value = false;
    }
  }
}
