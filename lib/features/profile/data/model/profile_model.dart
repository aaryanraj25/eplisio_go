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
