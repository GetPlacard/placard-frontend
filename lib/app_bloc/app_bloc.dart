import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:placard_frontend/app_bloc/app_event.dart';
import 'package:placard_frontend/app_bloc/app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppLoading());

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is AppInitialized) {
      try {
        final user = await event.apiManager.getSelfUser();
        yield AppReady(
          event.apiManager,
          user,
        );
      } catch (e) {
        yield AppError();
      }
    } else if (event is AppNoLoginStored) {
      yield AppOnboarding();
    } else if (event is AppLogoutRequested) {
      final secureStorage = new FlutterSecureStorage();
      await secureStorage.delete(key: 'placard_user_id');
      await secureStorage.delete(key: 'placard_access_token');
      yield AppOnboarding();
    }
  }
}
