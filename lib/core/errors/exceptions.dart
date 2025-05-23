class AuthException implements Exception {
  final String message;
  
  AuthException(this.message);
  
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);
  
  @override
  String toString() => message;
}