import 'dart:math';

import 'package:placard_frontend/structs/login_credentials.dart';
import 'package:placard_frontend/structs/sign_up_status.dart';
import 'package:placard_frontend/structs/user_error_type.dart';
import 'package:uuid/uuid.dart';

class LoginManager {
  Future<LoginCredentials> login(String email, String password) async {
    if (Random().nextBool()) {
      return LoginCredentials(
        Uuid().v4(),
        Uuid().v4(),
      );
    } else {
      return null;
    }
  }

  Future<SignUpStatus> createAccount(
      String username, String email, String address, String password) async {
    if (Random().nextBool()) {
      return SignUpSuccess(LoginCredentials(
        Uuid().v4(),
        Uuid().v4(),
      ));
    } else {
      return SignUpError(UserErrorType.fromJSON({
        'username': Random().nextBool() ? 'taken' : 'none',
        'email': Random().nextBool() ? 'invalid' : 'none',
        'address': Random().nextBool() ? 'invalid' : 'none',
        'password': Random().nextBool() ? 'invalid' : 'none',
      }));
    }
  }
}
