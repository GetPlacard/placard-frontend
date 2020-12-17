import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:placard_frontend/api_manager.dart';
import 'package:placard_frontend/app_bloc/app_bloc.dart';
import 'package:placard_frontend/app_bloc/app_event.dart';
import 'package:placard_frontend/login_manager.dart';
import 'package:placard_frontend/structs/login_credentials.dart';
import 'package:placard_frontend/structs/sign_up_status.dart';
import 'package:placard_frontend/structs/user_error_type.dart';
import 'package:placard_frontend/wave_clipper.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  // https://emailregex.com/
  // I don't really know how this works
  final emailRegExp = RegExp(
      r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  static const List<Color> orangeGradients = [
    Color(0xFFE57665),
    Color(0xFFDDC698),
  ];

  static const double formWidth = 300;

  final _formKey = GlobalKey<FormState>();

  UserErrorType _errorType = UserErrorType();
  String _username;
  String _email;
  String _address;
  String _password;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      primary: Theme.of(context).accentColor,
      onPrimary: Color(0xFF222222),
      textStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      padding: EdgeInsets.all(10),
    );

    // Preserve text field value after rebuild
    final _usernameController = TextEditingController(text: _username);
    final _emailController = TextEditingController(text: _email);
    final _addressController = TextEditingController(text: _address);
    final _passwordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: orangeGradients,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.height / 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    constraints: BoxConstraints.tightForFinite(
                      height: MediaQuery.of(context).size.height / 4,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 20),
                Form(
                  key: _formKey,
                  child: SizedBox(
                    width: formWidth,
                    child: Column(
                      children: [
                        TextFormField(
                          key: const Key('CreateAccountUsernameTextField'),
                          onChanged: (String value) {
                            _username = value;
                          },
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Username cannot be empty';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Username',
                            errorText: _usernameErrorToMsg(_errorType.username),
                          ),
                          controller: _usernameController,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          key: const Key('CreateAccountEmailTextField'),
                          onChanged: (String value) {
                            _email = value;
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
                            errorText: _emailErrorToMsg(_errorType.email),
                          ),
                          controller: _emailController,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          key: const Key('CreateAccountAddressTextField'),
                          onChanged: (String value) {
                            _address = value;
                          },
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Address cannot be empty';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Address',
                            errorText: _addressErrorToMsg(_errorType.address),
                          ),
                          controller: _addressController,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          key: const Key('CreateAccountPasswordTextField'),
                          onChanged: (String value) {
                            _password = value;
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
                            labelText: 'Password',
                            errorText: _passwordErrorToMsg(_errorType.password),
                          ),
                          controller: _passwordController,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          key: const Key(
                              'CreateAccountConfirmPasswordTextField'),
                          validator: (String value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                          ),
                          controller: _confirmPasswordController,
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: formWidth,
                          child: ElevatedButton(
                            child: Text('Sign Up'),
                            style: buttonStyle,
                            onPressed: () async {
                              if (_formKey.currentState.validate() &&
                                  _email != null &&
                                  _password != null) {
                                final signUpResult =
                                    await LoginManager().createAccount(
                                  _username,
                                  _email,
                                  _address,
                                  _password,
                                );
                                if (signUpResult is SignUpSuccess) {
                                  // If login is valid, write and start app
                                  final secureStorage =
                                      new FlutterSecureStorage();
                                  await secureStorage.write(
                                    key: 'placard_user_id',
                                    value: signUpResult.loginCredentials.userId,
                                  );
                                  await secureStorage.write(
                                    key: 'placard_access_token',
                                    value: signUpResult
                                        .loginCredentials.accessToken,
                                  );
                                  context.bloc<AppBloc>().add(
                                        AppInitialized(APIManager(
                                            signUpResult.loginCredentials)),
                                      );
                                } else if (signUpResult is SignUpError) {
                                  setState(() {
                                    _errorType = signUpResult.errorType;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 20),
              ],
            ),
            SafeArea(
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: Colors.white,
                iconSize: 28,
              ),
            ),
          ],
        ),
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
