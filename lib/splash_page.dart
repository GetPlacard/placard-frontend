// Placard: Revolutionize the future by using technology to empower the voices of our community

import 'package:flutter/material.dart';
import 'package:placard_frontend/create_account_page.dart';
import 'package:placard_frontend/log_in_page.dart';
import 'package:placard_frontend/wave_clipper.dart';

// https://medium.com/flutter-community/creating-awesome-login-screen-in-flutter-88d46c0d76ae
class SplashPage extends StatelessWidget {
  static const List<Color> orangeGradients = [
    Color(0xFFE57665),
    Color(0xFFDDC698),
  ];

  static const double buttonWidth = 250;

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
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints.tightForFinite(
              height: MediaQuery.of(context).size.height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      'Placard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.height / 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  constraints: BoxConstraints.tightForFinite(
                    height: MediaQuery.of(context).size.height / 3,
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      child: Text('Log In'),
                      style: buttonStyle,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      child: Text('Sign Up'),
                      style: buttonStyle,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                CreateAccountPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Image(
                  height: MediaQuery.of(context).size.height / 3,
                  image: AssetImage(
                      'assets/images/placard1_transparent_1024px.png')),
            ],
          ),
        ),
      ),
    );
  }
}
