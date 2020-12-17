import 'package:placard_frontend/structs/user.dart';
import 'package:placard_frontend/structs/user_error_type.dart';

abstract class UserState {
  const UserState(this.user);

  final User user;
}

class UserStateTentative extends UserState {
  const UserStateTentative(User user) : super(user);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is UserStateTentative && o.user == user;
  }

  @override
  int get hashCode => user.hashCode;
}

class UserStateDefinite extends UserState {
  const UserStateDefinite(User user) : super(user);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is UserStateDefinite && o.user == user;
  }

  @override
  int get hashCode => user.hashCode;
}

class UserStateError extends UserState {
  UserStateError(User user, {errorType})
      : errorType = errorType ?? UserErrorType(),
        super(user);

  final UserErrorType errorType;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is UserStateError && o.errorType == errorType && o.user == user;
  }

  @override
  int get hashCode => errorType.hashCode;
}
