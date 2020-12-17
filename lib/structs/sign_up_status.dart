import 'package:placard_frontend/structs/login_credentials.dart';
import 'package:placard_frontend/structs/user_error_type.dart';

abstract class SignUpStatus {}

class SignUpSuccess extends SignUpStatus {
  SignUpSuccess(this.loginCredentials);

  final LoginCredentials loginCredentials;
}

class SignUpError extends SignUpStatus {
  SignUpError(this.errorType);

  final UserErrorType errorType;
}
