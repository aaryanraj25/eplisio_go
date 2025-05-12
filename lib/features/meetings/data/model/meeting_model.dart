enum MeetingType { firstMeeting, followUp, other }

class MeetingModel {
  final String id;
  final String organizationId;
  final String clinicId;
  final String clinicName;
  final String? clientId;
  final ClientModel? client;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final MeetingType meetingType;
  final List<MeetingProductModel>? products;
  final String? disbursementId;
  final double? totalAmount;
  final int? totalQuantity;
  final String? orderId;
  final String? notes;
  final double latitude;
  final double longitude;
  final String employeeId;
  final DateTime createdAt;
  final Map<String, dynamic>? disbursement;

  MeetingModel({
    required this.id,
    required this.organizationId,
    required this.clinicId,
    required this.clinicName,
    this.clientId,
    this.client,
    required this.checkInTime,
    this.checkOutTime,
    required this.meetingType,
    this.products,
    this.disbursementId,
    this.totalAmount,
    this.totalQuantity,
    this.orderId,
    this.notes,
    required this.latitude,
    required this.longitude,
    required this.employeeId,
    required this.createdAt,
    this.disbursement,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['_id'] ?? '',
      organizationId: json['organization_id'] ?? '',
      clinicId: json['clinic_id'] ?? '',
      clinicName: json['clinic_name'] ?? '',
      clientId: json['client_id'],
      client:
          json['client'] != null ? ClientModel.fromJson(json['client']) : null,
      checkInTime: DateTime.parse(json['check_in_time']),
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'])
          : null,
      meetingType: _parseMeetingType(json['meeting_type']),
      products: (json['products'] as List?)
          ?.map((p) => MeetingProductModel.fromJson(p))
          .toList(),
      disbursementId: json['disbursement_id'],
      totalAmount: json['total_amount']?.toDouble(),
      totalQuantity: json['total_quantity'],
      orderId: json['order_id'],
      notes: json['notes'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      employeeId: json['employee_id'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      disbursement: json['disbursement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'organization_id': organizationId,
      'clinic_id': clinicId,
      'clinic_name': clinicName,
      'client_id': clientId,
      'client': client?.toJson(),
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'meeting_type': _meetingTypeToString(meetingType),
      'products': products?.map((p) => p.toJson()).toList(),
      'disbursement_id': disbursementId,
      'total_amount': totalAmount,
      'total_quantity': totalQuantity,
      'order_id': orderId,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
      'employee_id': employeeId,
      'created_at': createdAt.toIso8601String(),
      'disbursement': disbursement,
    };
  }

  static MeetingType _parseMeetingType(String? type) {
    if (type == null) return MeetingType.other;
    switch (type.toLowerCase()) {
      case 'first_meeting':
        return MeetingType.firstMeeting;
      case 'follow_up':
        return MeetingType.followUp;
      default:
        return MeetingType.other;
    }
  }

  String _meetingTypeToString(MeetingType type) {
    switch (type) {
      case MeetingType.firstMeeting:
        return 'first_meeting';
      case MeetingType.followUp:
        return 'follow_up';
      case MeetingType.other:
        return 'other';
    }
  }

  MeetingModel copyWith({
    String? id,
    String? organizationId,
    String? clinicId,
    String? clinicName,
    String? clientId,
    ClientModel? client,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    MeetingType? meetingType,
    List<MeetingProductModel>? products,
    String? disbursementId,
    double? totalAmount,
    int? totalQuantity,
    String? orderId,
    String? notes,
    double? latitude,
    double? longitude,
    String? employeeId,
    DateTime? createdAt,
    Map<String, dynamic>? disbursement,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      clientId: clientId ?? this.clientId,
      client: client ?? this.client,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      meetingType: meetingType ?? this.meetingType,
      products: products ?? this.products,
      disbursementId: disbursementId ?? this.disbursementId,
      totalAmount: totalAmount ?? this.totalAmount,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      orderId: orderId ?? this.orderId,
      notes: notes ?? this.notes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      employeeId: employeeId ?? this.employeeId,
      createdAt: createdAt ?? this.createdAt,
      disbursement: disbursement ?? this.disbursement,
    );
  }
}

class ClientModel {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String name;
  final String designation;
  final String department;
  final String clinicId;
  final String mobile;
  final String email;
  final String capacity;
  final String clinicName;
  final String organizationId;
  final String createdBy;

  ClientModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.name,
    required this.designation,
    required this.department,
    required this.clinicId,
    required this.mobile,
    required this.email,
    required this.capacity,
    required this.clinicName,
    required this.organizationId,
    required this.createdBy,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['_id'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      clinicId: json['clinic_id'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      capacity: json['capacity'] ?? 'end_user',
      clinicName: json['clinic_name'] ?? '',
      organizationId: json['organization_id'] ?? '',
      createdBy: json['created_by'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'name': name,
      'designation': designation,
      'department': department,
      'clinic_id': clinicId,
      'mobile': mobile,
      'email': email,
      'capacity': capacity,
      'clinic_name': clinicName,
      'organization_id': organizationId,
      'created_by': createdBy,
    };
  }

  ClientModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? designation,
    String? department,
    String? clinicId,
    String? mobile,
    String? email,
    String? capacity,
    String? clinicName,
    String? organizationId,
    String? createdBy,
  }) {
    return ClientModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      clinicId: clinicId ?? this.clinicId,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      capacity: capacity ?? this.capacity,
      clinicName: clinicName ?? this.clinicName,
      organizationId: organizationId ?? this.organizationId,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

class MeetingProductModel {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final double total;

  MeetingProductModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory MeetingProductModel.fromJson(Map<String, dynamic> json) {
    return MeetingProductModel(
      productId: json['product_id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }

  MeetingProductModel copyWith({
    String? productId,
    String? name,
    int? quantity,
    double? price,
    double? total,
  }) {
    return MeetingProductModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      total: total ?? this.total,
    );
  }
}

class CheckoutRequest {
  final String meetingType;
  final List<ProductCheckout>? products;
  final String? notes;

  CheckoutRequest({
    required this.meetingType,
    this.products,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'meeting_type': meetingType,
      'notes': notes,
    };

    if (products != null && products!.isNotEmpty) {
      data['products'] = products!.map((product) => product.toJson()).toList();
    }

    return data;
  }
}

class ProductCheckout {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final double total;

  ProductCheckout({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  }) : total = price * quantity;

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'name': name,
        'quantity': quantity,
        'price': price,
        'total': total,
      };
}

class SelectedProduct {
  final String productId;
  final String name;
  double price;
  int quantity;
  double get total => price * quantity;

  SelectedProduct({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  ProductCheckout toCheckoutProduct() {
    return ProductCheckout(
      productId: productId,
      name: name,
      quantity: quantity,
      price: price,
    );
  }
}
