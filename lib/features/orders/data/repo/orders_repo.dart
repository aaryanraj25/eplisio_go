import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/features/orders/data/model/orders_model.dart';

class OrdersRepository {
  final ApiClient _apiClient;

  OrdersRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<OrderModel>> getOrders({
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        if (status != null) 'status': status.toString().split('.').last,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiClient.get(
        '/orders/employee/employee/orders',
        queryParameters: queryParams,
      );

      // Print response for debugging
      print('API Response: ${response.data}');

      // Extract orders array from the response
      final responseData = response.data as Map<String, dynamic>;
      final ordersList = responseData['orders'] as List;

      return ordersList.map((order) => OrderModel.fromJson(order)).toList();
    } catch (e, stackTrace) {
      print('Error fetching orders: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Create order
  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _apiClient.post(
        '/orders/employee/employee/orders',
        data: orderData,
      );

      final responseData = response.data is Map
          ? response.data['data'] ?? response.data
          : response.data;

      return OrderModel.fromJson(responseData);
    } catch (e) {
      print('Error creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  // Update order
  Future<OrderModel> updateOrder(
      String orderId, Map<String, dynamic> orderData) async {
    try {
      final response = await _apiClient.put(
        '/orders/employee/employee/orders/$orderId',
        data: orderData,
      );

      final responseData = response.data is Map
          ? response.data['data'] ?? response.data
          : response.data;

      return OrderModel.fromJson(responseData);
    } catch (e) {
      print('Error updating order: $e');
      throw Exception('Failed to update order: $e');
    }
  }

  Future<void> convertToRegularOrder(
      OrderModel order, double totalAmount) async {
    try {
      await _apiClient.put(
        '/orders/employee/employee/orders/${order.id}',
        data: {
          'clinic_id': order.clinicId,
          'items': order.items
              .map((item) => {
                    'product_id': item.productId,
                    'name': item.name,
                    'quantity': item.quantity,
                    'price': item.price,
                    'total': item.totalAmount,
                  })
              .toList(),
          'total_amount': totalAmount,
          'status': 'pending',
        },
      );
    } catch (e) {
      print('Error converting order: $e');
      throw Exception('Failed to convert order: $e');
    }
  }
}
