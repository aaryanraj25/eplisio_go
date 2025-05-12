// lib/features/meetings/data/repositories/meetings_repository.dart

import 'package:eplisio_go/core/constants/api_client.dart';
import 'package:eplisio_go/features/clinic/data/model/clinic_model.dart';
import 'package:eplisio_go/features/meetings/data/model/meeting_model.dart';
import 'package:flutter/material.dart';

class MeetingsRepository {
  final ApiClient _apiClient;

  MeetingsRepository(this._apiClient);

  Future<MeetingModel?> getActiveMeeting() async {
    try {
      final response = await _apiClient.get('/meetings/active');
      if (response.data == null) return null;
      return MeetingModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Error getting active meeting: $e');
      throw Exception('Failed to get active meeting');
    }
  }

  Future<List<MeetingModel>> getCompletedMeetings({
    int skip = 0,
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
    String? meetingType,
    String? clinicId,
    String? clientId,
    String? search,
  }) async {
    try {
      final queryParams = {
        'skip': skip.toString(),
        'limit': limit.toString(),
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (meetingType != null) 'meeting_type': meetingType,
        if (clinicId != null) 'clinic_id': clinicId,
        if (clientId != null) 'client_id': clientId,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiClient.get(
        '/meetings/completed',
        queryParameters: queryParams,
      );

      if (response.data == null) return [];

      return (response.data as List)
          .map((item) => MeetingModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error getting completed meetings: $e');
      throw Exception('Failed to get completed meetings');
    }
  }

  Future<List<ClinicModel>> getNearbyClinics({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.get(
        '/hospital/employee/clinics',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      final clinicResponse = ClinicResponse.fromJson(response.data);
      return clinicResponse.hospitals;
    } catch (e) {
      debugPrint('Error fetching nearby clinics: $e');
      throw Exception('Failed to fetch nearby clinics: $e');
    }
  }

  Future<List<ClientModel>> getClients({
    required String clinicId,
    String? search,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/clients',
        queryParameters: {
          'clinic_id': clinicId,
          if (search != null && search.isNotEmpty) 'search': search,
          'skip': skip,
          'limit': limit,
        },
      );

      return (response.data as List)
          .map((json) => ClientModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch clients: $e');
    }
  }

  Future<void> checkIn({
    required String clinicId,
    required String clientId, // Add clientId parameter
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    try {
      await _apiClient.post(
        '/meetings/check-in',
        data: {
          'clinic_id': clinicId,
          'client_id': clientId, // Add clientId to request body
          'latitude': latitude,
          'longitude': longitude,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
    } catch (e) {
      throw Exception('Failed to check in: $e');
    }
  }

  Future<void> checkOut({
    required String meetingId,
    required CheckoutRequest request,
  }) async {
    try {
      final response = await _apiClient.post(
        '/meetings/check-out/$meetingId',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw 'Failed to check out';
      }
    } catch (e) {
      throw 'Failed to check out: $e';
    }
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
