class SetPasswordModel {
  final String email;
  final String password;
  
  SetPasswordModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class EmployeeModel {
  final String employeeId;
  final String name;
  final String email;
  final String role;
  final String organization;
  final String organizationId;
  final String adminId;

  EmployeeModel({
    required this.employeeId,
    required this.name,
    required this.email,
    required this.role,
    required this.organization,
    required this.organizationId,
    required this.adminId,
  });

  factory EmployeeModel.empty() {
    return EmployeeModel(
      employeeId: '',
      name: '',
      email: '',
      role: '',
      organization: '',
      organizationId: '',
      adminId: '',
    );
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      employeeId: json['employee_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      organization: json['organization'] ?? '',
      organizationId: json['organization_id'] ?? '',
      adminId: json['admin_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'role': role,
      'organization': organization,
      'organization_id': organizationId,
      'admin_id': adminId,
    };
  }

  bool get isEmpty => employeeId.isEmpty;
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    return 'EmployeeModel(employeeId: $employeeId, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmployeeModel && other.employeeId == employeeId;
  }

  @override
  int get hashCode => employeeId.hashCode;
}

class EmployeeAuthResponse {
  final String token;
  final EmployeeModel employee;
  final String message;

  EmployeeAuthResponse({
    required this.token,
    required this.employee,
    required this.message,
  });

  factory EmployeeAuthResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeAuthResponse(
      token: json['token'],
      employee: EmployeeModel(
        employeeId: json['employee_id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        organization: json['organization'],
        organizationId: json['organization_id'],
        adminId: json['admin_id'],
      ),
      message: json['message'],
    );
  }
}
