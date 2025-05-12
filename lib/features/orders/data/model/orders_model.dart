enum OrderStatus {
  pending,
  completed,
  prospective,
  rejected
}

class OrderModel {
  final String id;
  final String orderId;
  final String clinicId; // Added clinic_id
  final List<OrderItemModel> items;
  final double totalAmount;
  final DateTime createdAt;
  final OrderStatus status;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.clinicId, // Added to constructor
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      return OrderModel(
        id: json['_id']?.toString() ?? '',
        orderId: json['order_id']?.toString() ?? '',
        clinicId: json['clinic_id']?.toString() ?? '', // Parse clinic_id from JSON
        items: (json['items'] as List?)
            ?.map((item) => OrderItemModel.fromJson(item))
            .toList() ?? [],
        totalAmount: (json['total_amount'] ?? 0).toDouble(),
        createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
        status: _parseStatus(json['status']),
      );
    } catch (e) {
      print('Error parsing OrderModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static OrderStatus _parseStatus(dynamic status) {
    if (status == null) return OrderStatus.pending;
    
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'completed':
        return OrderStatus.completed;
      case 'pending':
        return OrderStatus.pending;
      case 'prospective':
        return OrderStatus.prospective;
      case 'rejected':
        return OrderStatus.rejected;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderItemModel {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final double totalAmount;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.totalAmount,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    try {
      return OrderItemModel(
        productId: json['product_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        quantity: int.tryParse(json['quantity'].toString()) ?? 0,
        price: double.tryParse(json['price'].toString()) ?? 0.0,
        totalAmount: double.tryParse(json['total'].toString()) ?? 0.0,
      );
    } catch (e) {
      print('Error parsing OrderItemModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}