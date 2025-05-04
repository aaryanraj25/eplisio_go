class StatisticsModel {
  final int totalSales;
  final int totalVisits;
  final PerformanceModel performance;

  StatisticsModel({
    required this.totalSales,
    required this.totalVisits,
    required this.performance,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalSales: _parseToInt(json['total_sales']),
      totalVisits: _parseToInt(json['total_visits']),
      performance: json['performance'] != null 
          ? PerformanceModel.fromJson(json['performance']) 
          : PerformanceModel(rank: 0, totalClients: 0),
    );
  }
  
  // Helper method to parse numeric values to int
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class PerformanceModel {
  final int rank;
  final int totalClients;

  PerformanceModel({
    required this.rank,
    required this.totalClients,
  });

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      rank: StatisticsModel._parseToInt(json['rank']),
      totalClients: StatisticsModel._parseToInt(json['total_clients']),
    );
  }
}

class ClockResponseModel {
  final String clockInTime;
  final String? clockOutTime;
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
      clockInTime: json['clock_in_time'] ?? '',
      clockOutTime: json['clock_out_time'],
      message: json['message'] ?? 'Success',
      workFromHome: json['work_from_home'] ?? false,
    );
  }
}