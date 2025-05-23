class ClinicResponse {
  final int totalHospitals;
  final String? workMode;
  final bool coordinatesProvided;
  final List<ClinicModel> hospitals;

  ClinicResponse({
    required this.totalHospitals,
    this.workMode,
    required this.coordinatesProvided,
    required this.hospitals,
  });

  factory ClinicResponse.fromJson(Map<String, dynamic> json) {
    return ClinicResponse(
      totalHospitals: json['total_hospitals'] ?? 0,
      workMode: json['work_mode'],
      coordinatesProvided: json['coordinates_provided'] ?? false,
      hospitals: (json['hospitals'] as List)
          .map((hospital) => ClinicModel.fromJson(hospital))
          .toList(),
    );
  }
}

class ClinicsResponses {
  final int total;
  final List<ClinicModel> clinics;
  final int page;
  final int pages;

  ClinicsResponses({
    required this.total,
    required this.clinics,
    required this.page,
    required this.pages,
  });

  factory ClinicsResponses.fromJson(Map<String, dynamic> json) {
    return ClinicsResponses(
      total: json['total'] ?? 0,
      clinics: (json['clinics'] as List<dynamic>)
          .map((clinic) => ClinicModel.fromJson(clinic))
          .toList(),
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
    );
  }
}

class ClinicSearchResult {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;

  ClinicSearchResult({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
  });

  factory ClinicSearchResult.fromJson(Map<String, dynamic> json) {
    return ClinicSearchResult(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }
}


class ClinicModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String country;
  final String? pincode;
  final String? phone;
  final String? email;
  final String? website;
  final double latitude;
  final double longitude;
  final String? specialties; // Make nullable
  final String type;
  final String status;
  final String organizationId;
  final String addedBy;
  final String addedByRole;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? googlePlaceId;
  final double? rating; // Make nullable
  final int totalRatings;
  final double? distance; // Make nullable
  final bool? withinRange; // Make nullable
  final String source;

  ClinicModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    this.pincode,
    this.phone,
    this.email,
    this.website,
    required this.latitude,
    required this.longitude,
    this.specialties, // Make optional
    required this.type,
    required this.status,
    required this.organizationId,
    required this.addedBy,
    required this.addedByRole,
    required this.createdAt,
    this.updatedAt,
    this.googlePlaceId,
    this.rating, // Make optional
    required this.totalRatings,
    this.distance, // Make optional
    this.withinRange, // Make optional
    required this.source,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      specialties: json['specialties'],
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      organizationId: json['organization_id'] ?? '',
      addedBy: json['added_by'] ?? '',
      addedByRole: json['added_by_role'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
      googlePlaceId: json['google_place_id'],
      rating: json['rating']?.toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      distance: json['distance']?.toDouble(),
      withinRange: json['within_range'],
      source: json['source'] ?? '',
    );
  }
}

class ClinicManualCreate {
  final String name;
  final String type;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final double latitude;
  final double longitude;
  final String phone;
  final String website;

  ClinicManualCreate({
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.website,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'website': website,
    };
  }
}