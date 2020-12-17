import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:placard_frontend/api_manager.dart';
import 'package:placard_frontend/app_bloc/app_bloc.dart';
import 'package:placard_frontend/app_bloc/app_event.dart';
import 'package:placard_frontend/login_manager.dart';
import 'package:placard_frontend/structs/login_credentials.dart';
import 'package:placard_frontend/wave_clipper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  bool _loginInvalid = false;
  String _email;
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

    final _emailController = TextEditingController(text: _email);
    final _passwordController = TextEditingController();
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
                        'Log In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.height / 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    constraints: BoxConstraints.tightForFinite(
                      height: MediaQuery.of(context).size.height / 4,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 8),
                Form(
                  key: _formKey,
                  child: SizedBox(
                    width: formWidth,
                    child: Column(
                      children: [
                        Container(
                          child: _loginInvalid
                              ? Column(
                                  children: [
                                    Card(
                                      color: Colors.red[100],
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            'The email or password you have entered is incorrect.'),
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                  ],
                                )
                              : null,
                        ),
                        TextFormField(
                          key: const Key('LoginEmailTextField'),
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
                          ),
                          controller: _emailController,
                        ),
                        TextFormField(
                          key: const Key('LoginPasswordTextField'),
                          onChanged: (String value) {
                            _password = value;
                          },
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Password cannot be empty';
                            }
                            return null;
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                          ),
                          controller: _passwordController,
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: formWidth,
                          child: ElevatedButton(
                            child: Text('Log In'),
                            style: buttonStyle,
                            onPressed: () async {
                              if (_formKey.currentState.validate() &&
                                  _email != null &&
                                  _password != null) {
                                final loginResult = await LoginManager().login(
                                  _email,
                                  _password,
                                );
                                if (loginResult != null &&
                                    loginResult is LoginCredentials) {
                                  // If login is valid, write and start app
                                  final secureStorage =
                                      new FlutterSecureStorage();
                                  await secureStorage.write(
                                    key: 'placard_user_id',
                                    value: loginResult.userId,
                                  );
                                  await secureStorage.write(
                                    key: 'placard_access_token',
                                    value: loginResult.accessToken,
                                  );
                                  context.bloc<AppBloc>().add(
                                      AppInitialized(APIManager(loginResult)));
                                } else {
                                  setState(() {
                                    _loginInvalid = true;
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
                SizedBox(height: MediaQuery.of(context).size.height / 8),
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
}
