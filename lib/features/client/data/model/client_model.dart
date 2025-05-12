class ClientModel {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String name;
  final String designation;
  final String department;
  final String clinicId;
  final String? mobile;
  final String? email;
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
    this.mobile,
    this.email,
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
      capacity: json['capacity'] ?? '',
      clinicName: json['clinic_name'] ?? '',
      organizationId: json['organization_id'] ?? '',
      createdBy: json['created_by'] ?? '',
    );
  }
}

