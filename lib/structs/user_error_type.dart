enum UsernameError { none, taken, invalid }
enum EmailError { none, taken, invalid }
enum AddressError { none, invalid }
enum PasswordError { none, invalid }

class UserErrorType {
  UserErrorType({username, email, address, password})
      : username = username ?? UsernameError.none,
        email = email ?? EmailError.none,
        address = address ?? AddressError.none,
        password = password ?? PasswordError.none;

  UserErrorType.fromJSON(Map input)
      : username = _usernameStrToEnum(input['username']),
        email = _emailStrToEnum(input['email']),
        address = _addressStrToEnum(input['address']),
        password = _passwordStrToEnum(input['password']);

  final UsernameError username;
  final EmailError email;
  final AddressError address;
  final PasswordError password;

  static UsernameError _usernameStrToEnum(String str) {
    switch (str) {
      case 'taken':
        return UsernameError.taken;
        break;
      case 'invalid':
        return UsernameError.invalid;
        break;
      default:
        return UsernameError.none;
        break;
    }
  }

  static EmailError _emailStrToEnum(String str) {
    switch (str) {
      case 'taken':
        return EmailError.taken;
        break;
      case 'invalid':
        return EmailError.invalid;
        break;
      default:
        return EmailError.none;
        break;
    }
  }

  static AddressError _addressStrToEnum(String str) {
    switch (str) {
      case 'invalid':
        return AddressError.invalid;
        break;
      default:
        return AddressError.none;
        break;
    }
  }

  static PasswordError _passwordStrToEnum(String str) {
    switch (str) {
      case 'invalid':
        return PasswordError.invalid;
        break;
      default:
        return PasswordError.none;
        break;
    }
  }
}
