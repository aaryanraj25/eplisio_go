class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String organization;
  final String? profileImage;
  final String? phone;
  final String? role;
  final String? department;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.organization,
    this.profileImage,
    this.phone,
    this.role,
    this.department,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      organization: json['organization'] ?? '',
      profileImage: json['profile_image'],
      phone: json['phone'],
      role: json['role'],
      department: json['department'],
    );
  }

  factory ProfileModel.empty() {
    return ProfileModel(
      id: '',
      name: '',
      email: '',
      organization: '',
    );
  }
}

class ProfileResponse {
  final EmployeeProfile employeeProfile;
  final AdminProfile adminProfile;

  ProfileResponse({
    required this.employeeProfile,
    required this.adminProfile,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      employeeProfile: EmployeeProfile.fromJson(json['employee_profile']),
      adminProfile: AdminProfile.fromJson(json['admin_profile']),
    );
  }
}

class EmployeeProfile {
  final String id;
  final String email;
  final String name;
  final String organizationId;
  final String organization;
  final String adminId;
  final DateTime createdAt;
  final String role;
  final bool isActive;
  final Location? location;

  EmployeeProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.organizationId,
    required this.organization,
    required this.adminId,
    required this.createdAt,
    required this.role,
    required this.isActive,
    this.location,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      organizationId: json['organization_id'] ?? '',
      organization: json['organization'] ?? '',
      adminId: json['admin_id'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? false,
      location: json['location'] != null 
          ? Location.fromJson(json['location'])
          : null,
    );
  }
}

class AdminProfile {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String organizationId;
  final String organization;
  final String address;
  final int empCount;
  final bool isVerified;
  final String role;
  final DateTime createdAt;
  final DateTime verifiedAt;
  final String verifiedBy;
  final DateTime lastLogin;

  AdminProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.organizationId,
    required this.organization,
    required this.address,
    required this.empCount,
    required this.isVerified,
    required this.role,
    required this.createdAt,
    required this.verifiedAt,
    required this.verifiedBy,
    required this.lastLogin,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      organizationId: json['organization_id'] ?? '',
      organization: json['organization'] ?? '',
      address: json['address'] ?? '',
      empCount: json['emp_count'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      role: json['role'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      verifiedAt: DateTime.parse(json['verified_at']),
      verifiedBy: json['verified_by'] ?? '',
      lastLogin: DateTime.parse(json['last_login']),
    );
  }
}

class Location {
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  Location({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}