import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placard_frontend/structs/user_error_type.dart';
import 'package:placard_frontend/user_bloc/user_bloc.dart';
import 'package:placard_frontend/user_bloc/user_event.dart';
import 'package:placard_frontend/user_bloc/user_state.dart';

class UserSettingsPage extends StatefulWidget {
  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  // https://emailregex.com/
  // I don't really know how this works
  final emailRegExp = RegExp(
      r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  UserInfoChanged userInfoEvent = UserInfoChanged();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              context.bloc<UserBloc>().add(UserInfoChangeCancelled());
              Navigator.of(context).pop();
            }),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                context.bloc<UserBloc>().add(userInfoEvent);
              }
            },
          )
        ],
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listenWhen: (oldState, newState) =>
            oldState is UserStateTentative && newState is UserStateDefinite,
        listener: (BuildContext context, UserState userState) {
          Navigator.of(context).pop();
        },
        builder: (BuildContext context, UserState userState) {
          // Preserve text field value after rebuild
          final _usernameController = TextEditingController(
              text: userInfoEvent.username ?? userState.user.username);
          final _emailController = TextEditingController(
              text: userInfoEvent.email ?? userState.user.email);
          final _addressController = TextEditingController(
              text: userInfoEvent.address ?? userState.user.address);
          final _passwordController = TextEditingController();
          final _confirmPasswordController = TextEditingController();
          final formWidget = Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  key: const Key('UserSettingsUsernameTextField'),
                  onChanged: (String value) {
                    userInfoEvent.username = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Username cannot be empty';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Username',
                    errorText: userState is UserStateError
                        ? _usernameErrorToMsg(userState.errorType.username)
                        : null,
                  ),
                  controller: _usernameController,
                ),
                SizedBox(height: 8),
                TextFormField(
                  key: const Key('UserSettingsEmailTextField'),
                  onChanged: (String value) {
                    userInfoEvent.email = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Email cannot be empty';
                    } else if (!emailRegExp.hasMatch(value)) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: userState is UserStateError
                        ? _emailErrorToMsg(userState.errorType.email)
                        : null,
                  ),
                  controller: _emailController,
                ),
                SizedBox(height: 8),
                TextFormField(
                  key: const Key('UserSettingsAddressTextField'),
                  onChanged: (String value) {
                    userInfoEvent.address = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Address cannot be empty';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Address',
                    errorText: userState is UserStateError
                        ? _addressErrorToMsg(userState.errorType.address)
                        : null,
                  ),
                  controller: _addressController,
                ),
                SizedBox(height: 8),
                Divider(height: 24),
                TextFormField(
                  key: const Key('UserSettingsPasswordTextField'),
                  onChanged: (String value) {
                    userInfoEvent.password = value;
                  },
                  validator: (String value) {
                    // TODO: add some more complex validation
                    if (value.length < 8 && value.isNotEmpty) {
                      return 'Passwords must contain at least 8 characters';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Change Password',
                    errorText: userState is UserStateError
                        ? _passwordErrorToMsg(userState.errorType.password)
                        : null,
                  ),
                  controller: _passwordController,
                ),
                SizedBox(height: 8),
                TextFormField(
                  key: const Key('UserSettingsConfirmPasswordTextField'),
                  validator: (String value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                  controller: _confirmPasswordController,
                ),
              ],
            ),
          );
          return userState is UserStateTentative
              ? Stack(
                  children: [
                    formWidget,
                    Container(
                      child: Center(child: CircularProgressIndicator()),
                      color: Colors.black.withAlpha(100),
                    ),
                  ],
                  fit: StackFit.expand,
                )
              : formWidget;
        },
      ),
    );
  }

  String _usernameErrorToMsg(UsernameError errorType) {
    switch (errorType) {
      case UsernameError.invalid:
        return 'Invalid username';
        break;
      case UsernameError.taken:
        return 'This username has already been taken';
        break;
      default:
        return null;
        break;
    }
  }

  String _emailErrorToMsg(EmailError errorType) {
    switch (errorType) {
      case EmailError.invalid:
        return 'Invalid email';
        break;
      case EmailError.taken:
        return 'This email is already in use';
        break;
      default:
        return null;
        break;
    }
  }

  String _addressErrorToMsg(AddressError errorType) {
    switch (errorType) {
      case AddressError.invalid:
        return 'This is not a valid address';
        break;
      default:
        return null;
        break;
    }
  }

  String _passwordErrorToMsg(PasswordError errorType) {
    switch (errorType) {
      case PasswordError.invalid:
        return 'Invalid password';
        break;
      default:
        return null;
        break;
    }
  }
}
