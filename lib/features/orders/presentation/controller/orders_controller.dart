import 'package:eplisio_go/features/orders/data/model/orders_model.dart';
import 'package:eplisio_go/features/orders/data/repo/orders_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController with GetTickerProviderStateMixin {
  final OrdersRepository _repository;
  late TabController tabController;

  final _isLoading = false.obs;
  final _pendingOrders = <OrderModel>[].obs;
  final _completedOrders = <OrderModel>[].obs;
  final _prospectiveOrders = <OrderModel>[].obs;
  final _currentTab = 0.obs;

  OrdersController({required OrdersRepository repository}) 
      : _repository = repository;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(_onTabChanged);
    loadAllOrders();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void _onTabChanged() {
    if (tabController.indexIsChanging) {
      _currentTab.value = tabController.index;
    }
  }

  // Getters
  bool get isLoading => _isLoading.value;
  List<OrderModel> get pendingOrders => _pendingOrders;
  List<OrderModel> get completedOrders => _completedOrders;
  List<OrderModel> get prospectiveOrders => _prospectiveOrders;
  int get currentTab => _currentTab.value;

  // Get orders by status
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return _pendingOrders;
      case OrderStatus.completed:
        return _completedOrders;
      case OrderStatus.prospective:
        return _prospectiveOrders;
      default:
        return [];
    }
  }

  // Load orders based on status
  Future<void> loadAllOrders() async {
    try {
      _isLoading.value = true;
      
      // Load all types of orders simultaneously
      final results = await Future.wait([
        _repository.getPendingOrders(),
        _repository.getCompletedOrders(),
        _repository.getProspectiveOrders(),
      ]);

      _pendingOrders.value = results[0];
      _completedOrders.value = results[1];
      _prospectiveOrders.value = results[2];

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load orders',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadAllOrders();
  }

  // Mark order as completed
  Future<void> markAsCompleted(OrderModel order) async {
    try {
      await _repository.updateOrderStatus(order.id, OrderStatus.completed);
      await refreshOrders();
      
      Get.snackbar(
        'Success',
        'Order marked as completed',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update order status',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Convert prospective to regular order
  Future<void> convertToRegularOrder(OrderModel prospectiveOrder) async {
    try {
      await _repository.convertToRegularOrder(prospectiveOrder.id);
      await refreshOrders();
      
      Get.snackbar(
        'Success',
        'Successfully converted to regular order',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to convert order',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Update probability of prospective order
  Future<void> updateProbability(String orderId, double probability) async {
    try {
      await _repository.updateProbability(orderId, probability);
      await refreshOrders();
      
      Get.snackbar(
        'Success',
        'Probability updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update probability',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Navigate to add new order
  void addNewOrder() {
    // Pass current tab index to determine which type of order to create
    Get.toNamed('/orders/add', arguments: currentTab);
  }

  // Navigate to order details
  void viewOrderDetails(OrderModel order) {
    Get.toNamed('/orders/details', arguments: order);
  }

  // Delete order
  Future<void> deleteOrder(OrderModel order) async {
    try {
      await _repository.deleteOrder(order.id);
      await refreshOrders();
      
      Get.snackbar(
        'Success',
        'Order deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete order',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}