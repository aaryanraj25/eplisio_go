class TimeUtils {
  // IST offset from UTC is +5:30
  static final istOffset = const Duration(hours: 5, minutes: 30);
  
  // Get current time in IST
  static DateTime nowIST() {
    return DateTime.now().toUtc().add(istOffset);
  }
  
  // Convert UTC DateTime to IST
  static DateTime toIST(DateTime utcDateTime) {
    if (utcDateTime.isUtc) {
      return utcDateTime.add(istOffset);
    } else {
      // If it's not explicitly UTC, convert to UTC first
      return utcDateTime.toUtc().add(istOffset);
    }
  }
  
  // Convert IST DateTime to UTC
  static DateTime fromIST(DateTime istDateTime) {
    // Assuming istDateTime is in local time zone and represents IST
    // We need to subtract the offset to get UTC
    return istDateTime.subtract(istOffset).toUtc();
  }
  
  // Check if a DateTime is from today (in IST)
  static bool isToday(DateTime date) {
    final now = nowIST();
    
    // Convert the date to IST if it's in UTC
    final dateInIST = date.isUtc ? toIST(date) : date;
    
    return dateInIST.year == now.year && 
           dateInIST.month == now.month && 
           dateInIST.day == now.day;
  }
  
  // Get end of today in IST (23:59:59)
  static DateTime getEndOfDay() {
    final now = nowIST();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }
  
  // Get 9 PM today in IST
  static DateTime getNinepm() {
    final now = nowIST();
    return DateTime(now.year, now.month, now.day, 21, 0, 0);
  }
  
  // Format duration as HH:MM:SS
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
  
  // Format time as HH:MM
  static String formatTimeHHMM(DateTime dateTime) {
    // Ensure we're formatting IST time
    final istTime = dateTime.isUtc ? toIST(dateTime) : dateTime;
    return '${istTime.hour.toString().padLeft(2, '0')}:${istTime.minute.toString().padLeft(2, '0')}';
  }
}