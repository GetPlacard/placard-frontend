import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:placard_frontend/api_manager.dart';
import 'package:placard_frontend/app_bloc/app_bloc.dart';
import 'package:placard_frontend/app_bloc/app_event.dart';
import 'package:placard_frontend/app_bloc/app_state.dart';
import 'package:placard_frontend/loading_page.dart';
import 'package:placard_frontend/splash_page.dart';
import 'package:placard_frontend/structs/login_credentials.dart';
import 'package:placard_frontend/tab_manager.dart';
import 'package:placard_frontend/user_bloc/user_bloc.dart';

void main() {
  runApp(PlacardApp());
}

class PlacardApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        final bloc = AppBloc();
        _initializeApp(bloc);
        return bloc;
      },
      child: BlocBuilder<AppBloc, AppState>(
        builder: (BuildContext context, AppState state) {
          Widget appView;
          if (state is AppLoading) {
            appView = LoadingPage();
          } else if (state is AppReady) {
            appView = TabManager();
          } else if (state is AppOnboarding) {
            appView = SplashPage();
          } else {
            // Just a bit of backup text just in case of an error
            appView = Scaffold(
              body: Center(
                child: Text(
                  'Uh oh, you really shouldn\'t be seeing this page...\nAn unknown error has occurred.',
                ),
              ),
            );
          }

          MaterialApp appWidget = MaterialApp(
            title: 'Placard',
            theme: ThemeData(
              primarySwatch: Colors.amber,
              textTheme: GoogleFonts.interTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            // theme: ThemeData(
            //   primarySwatch: Colors.amber,
            //   colorScheme: ColorScheme.fromSwatch(
            //     brightness: Brightness.light,
            //     primarySwatch: Colors.amber,
            //     accentColor: Color(0xFFE38870),
            //   ),
            //   accentColor: Color(0xFFE38870),
            //   // scaffoldBackgroundColor: Color(0xFF2A2A2A),
            //   textTheme: GoogleFonts.interTextTheme(
            //     Theme.of(context).textTheme,
            //   ),
            // ),
            home: appView,
          );
          // If app is ready, wrap it in the providers
          return state is AppReady
              ? RepositoryProvider(
                  create: (BuildContext context) => state.apiManager,
                  child: BlocProvider(
                    create: (BuildContext context) =>
                        UserBloc(state.selfUser, state.apiManager),
                    child: appWidget,
                  ),
                )
              : appWidget;
        },
      ),
    );
  }

  Future<void> _initializeApp(AppBloc bloc) async {
    final secureStorage = new FlutterSecureStorage();
    final userId = await secureStorage.read(key: 'placard_user_id');
    final accessToken = await secureStorage.read(key: 'placard_access_token');
    if (userId == null || accessToken == null) {
      bloc.add(AppNoLoginStored());
    } else {
      bloc.add(
        AppInitialized(
          APIManager(
            LoginCredentials(
              userId,
              accessToken,
            ),
          ),
        ),
      );
    }
  }
}
