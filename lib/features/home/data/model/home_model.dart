import 'package:intl/intl.dart';

class StatisticsModel {
  final int totalSales;
  final int totalVisits;
  final PerformanceModel performance;

  StatisticsModel({
    this.totalSales = 0,
    this.totalVisits = 0,
    required this.performance,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalSales: json['total_sales']?.toInt() ?? 0,
      totalVisits: json['total_visits']?.toInt() ?? 0,
      performance: PerformanceModel.fromJson(json['performance'] ?? {}),
    );
  }

  // Add empty constructor for initial state
  factory StatisticsModel.empty() {
    return StatisticsModel(
      performance: PerformanceModel.empty(),
    );
  }
}

class PerformanceModel {
  final int rank;
  final int totalClients;

  PerformanceModel({
    this.rank = 0,
    this.totalClients = 0,
  });

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      rank: json['rank']?.toInt() ?? 0,
      totalClients: json['total_clients']?.toInt() ?? 0,
    );
  }

  factory PerformanceModel.empty() {
    return PerformanceModel();
  }
}
class ClockResponseModel {
  final DateTime clockInTime;
  final DateTime? clockOutTime;
  final String message;
  final bool workFromHome;

  ClockResponseModel({
    required this.clockInTime,
    this.clockOutTime,
    required this.message,
    this.workFromHome = false,
  });

  factory ClockResponseModel.fromJson(Map<String, dynamic> json) {
    return ClockResponseModel(
      clockInTime: _parseDateTime(json['clock_in_time']),
      clockOutTime: json['clock_out_time'] != null 
          ? _parseDateTime(json['clock_out_time'])
          : null,
      message: json['message'] ?? 'Success',
      workFromHome: json['work_from_home'] ?? false,
    );
  }

  static DateTime _parseDateTime(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr).toLocal(); // Convert to local time (IST)
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedClockInTime => 
      DateFormat('HH:mm').format(clockInTime);
  
  String get formattedClockOutTime => 
      clockOutTime != null ? DateFormat('HH:mm').format(clockOutTime!) : '--:--';
}


class ClockInfoModel {
  final String attendanceId;
  final DateTime clockInTime;
  final DateTime? clockOutTime;
  final bool workFromHome;
  final double? totalHours;
  final Map<String, dynamic>? clockInLocation;
  final Map<String, dynamic>? clockOutLocation;

  ClockInfoModel({
    required this.attendanceId,
    required this.clockInTime,
    this.clockOutTime,
    this.workFromHome = false,
    this.totalHours,
    this.clockInLocation,
    this.clockOutLocation,
  });

  factory ClockInfoModel.fromJson(Map<String, dynamic> json) {
    return ClockInfoModel(
      attendanceId: json['attendance_id'] ?? '',
      clockInTime: _parseDateTime(json['clock_in_time']),
      clockOutTime: json['clock_out_time'] != null 
          ? _parseDateTime(json['clock_out_time']) 
          : null,
      workFromHome: json['work_from_home'] ?? false,
      totalHours: json['total_hours']?.toDouble(),
      clockInLocation: json['clock_in_location'],
      clockOutLocation: json['clock_out_location'],
    );
  }

  static DateTime _parseDateTime(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr).toLocal(); // Convert to local time
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedClockInTime => 
      DateFormat('HH:mm').format(clockInTime);
  
  String get formattedClockOutTime => 
      clockOutTime != null ? DateFormat('HH:mm').format(clockOutTime!) : '--:--';
}