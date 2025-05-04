import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/features/orders/data/model/orders_model.dart';


class OrdersRepository {
  final ApiClient _apiClient;

  OrdersRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // Get all orders
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _apiClient.get('/orders');
      return (response.data['orders'] as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Get pending orders
  Future<List<OrderModel>> getPendingOrders() async {
    try {
      final response = await _apiClient.get('/orders/pending');
      return (response.data['orders'] as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch pending orders: $e');
    }
  }

  // Get completed orders
  Future<List<OrderModel>> getCompletedOrders() async {
    try {
      final response = await _apiClient.get('/orders/completed');
      return (response.data['orders'] as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch completed orders: $e');
    }
  }

  // Get prospective orders (soft commitment)
  Future<List<OrderModel>> getProspectiveOrders() async {
    try {
      final response = await _apiClient.get('/orders/prospective');
      return (response.data['orders'] as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch prospective orders: $e');
    }
  }

  // Create new order
  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _apiClient.post('/orders', data: orderData);
      return OrderModel.fromJson(response.data['order']);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Create prospective order
  Future<OrderModel> createProspectiveOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _apiClient.post('/orders/prospective', data: orderData);
      return OrderModel.fromJson(response.data['order']);
    } catch (e) {
      throw Exception('Failed to create prospective order: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _apiClient.patch(
        '/orders/$orderId/status',
        data: {'status': status.toString().split('.').last},
      );
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Convert prospective to regular order
  Future<void> convertToRegularOrder(String prospectiveOrderId) async {
    try {
      await _apiClient.post('/orders/$prospectiveOrderId/convert');
    } catch (e) {
      throw Exception('Failed to convert prospective order: $e');
    }
  }

  // Get order details
  Future<OrderModel> getOrderDetails(String orderId) async {
    try {
      final response = await _apiClient.get('/orders/$orderId');
      return OrderModel.fromJson(response.data['order']);
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  // Update order
  Future<OrderModel> updateOrder(String orderId, Map<String, dynamic> updateData) async {
    try {
      final response = await _apiClient.put(
        '/orders/$orderId',
        data: updateData,
      );
      return OrderModel.fromJson(response.data['order']);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  // Delete order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _apiClient.delete('/orders/$orderId');
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  // Update prospective order probability
  Future<void> updateProbability(String orderId, double probability) async {
    try {
      await _apiClient.patch(
        '/orders/$orderId/probability',
        data: {'probability': probability},
      );
    } catch (e) {
      throw Exception('Failed to update probability: $e');
    }
  }
}