import 'package:placard_frontend/api_manager.dart';

abstract class AppEvent {}

class AppInitialized extends AppEvent {
  AppInitialized(this.apiManager) : super();

  final APIManager apiManager;
}

class AppNoLoginStored extends AppEvent {}

class AppLogoutRequested extends AppEvent {}
