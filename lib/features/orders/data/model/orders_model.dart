enum OrderStatus {
  pending,
  completed,
  prospective // instead of soft commitment
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final double amount;
  final DateTime orderDate;
  final OrderStatus status;
  final String? notes;
  final List<OrderItemModel> items;
  final DateTime? expectedDeliveryDate;
  final double? probability; // For prospective orders

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.amount,
    required this.orderDate,
    required this.status,
    this.notes,
    required this.items,
    this.expectedDeliveryDate,
    this.probability,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['_id'],
        orderNumber: json['order_number'],
        customerName: json['customer_name'],
        customerPhone: json['customer_phone'],
        amount: (json['amount'] ?? 0.0).toDouble(),
        orderDate: DateTime.parse(json['order_date']),
        status: OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
          orElse: () => OrderStatus.pending,
        ),
        notes: json['notes'],
        items: (json['items'] as List?)
                ?.map((item) => OrderItemModel.fromJson(item))
                .toList() ??
            [],
        expectedDeliveryDate: json['expected_delivery_date'] != null
            ? DateTime.parse(json['expected_delivery_date'])
            : null,
        probability: json['probability']?.toDouble(),
      );
}

class OrderItemModel {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String? description;

  OrderItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.description,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['_id'],
      name: json['name'],
      quantity: json['quantity'],
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'description': description,
    };
  }
}