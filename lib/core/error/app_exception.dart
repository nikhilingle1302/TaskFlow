class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class NotFoundException extends AppException {
  const NotFoundException(super.message) : super(code: '404');
}

class ValidationException extends AppException {
  const ValidationException(super.message) : super(code: 'validation');
}

class AuthException extends AppException {
  const AuthException(super.message) : super(code: 'auth');
}

class ForbiddenException extends AppException {
  const ForbiddenException(super.message) : super(code: '403');
}
