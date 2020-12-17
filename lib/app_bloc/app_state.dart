import 'package:placard_frontend/api_manager.dart';
import 'package:placard_frontend/structs/user.dart';

abstract class AppState {
  const AppState();
}

class AppLoading extends AppState {
  const AppLoading() : super();
}

class AppReady extends AppState {
  const AppReady(this.apiManager, this.selfUser) : super();

  final APIManager apiManager;
  final User selfUser;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is AppReady && o.apiManager == apiManager;
  }

  @override
  int get hashCode => apiManager.hashCode;
}

class AppError extends AppState {
  const AppError() : super();
}

class AppOnboarding extends AppState {
  const AppOnboarding() : super();
}
