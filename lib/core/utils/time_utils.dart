
class TimeUtils {
  static final istOffset = const Duration(hours: 5, minutes: 30);
  
  static DateTime nowIST() {
    return DateTime.now().toUtc().add(istOffset);
  }
  
  static DateTime toIST(DateTime dateTime) {
    return dateTime.toUtc().add(istOffset);
  }
  
  static DateTime fromIST(DateTime istDateTime) {
    return istDateTime.subtract(istOffset).toUtc();
  }
  
  static bool isToday(DateTime date) {
    final now = nowIST();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  static DateTime getEndOfDay() {
    final now = nowIST();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }
  
  
  static DateTime getNinepm() {
    final now = nowIST();
    return DateTime(now.year, now.month, now.day, 21, 0, 0);
  }
}