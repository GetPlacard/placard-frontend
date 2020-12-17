import 'package:bloc/bloc.dart';
import 'package:placard_frontend/api_manager.dart';
import 'package:placard_frontend/structs/user_error_type.dart';
import 'package:placard_frontend/user_bloc/user_event.dart';
import 'package:placard_frontend/user_bloc/user_state.dart';
import 'package:placard_frontend/structs/placed_placard.dart';
import 'package:placard_frontend/structs/user.dart';

class UserBloc extends Bloc<UserChangeEvent, UserState> {
  UserBloc(this.lastValidUser, this._apiManager)
      : super(UserStateDefinite(lastValidUser));

  User lastValidUser;
  APIManager _apiManager;

  @override
  Stream<UserState> mapEventToState(UserChangeEvent event) async* {
    if (event is UserInfoChanged) {
      if (lastValidUser.isSelf) {
        yield UserStateTentative(User.copyWith(
          lastValidUser,
          username: event.username,
          email: event.email,
          address: event.address,
        ));
        try {
          lastValidUser = await _apiManager.editUserInfo(
            username: event.username,
            email: event.email,
            address: event.address,
            password: event.password,
          );
          yield UserStateDefinite(lastValidUser);
        } catch (e) {
          // TODO: figure out how to catch errors
          print(e);
          if (e is UserErrorType) {
            yield UserStateError(lastValidUser, errorType: e);
          } else {
            yield UserStateError(lastValidUser);
          }
        }
      }
    } else if (event is PlacardLikeStateChanged) {
      final placardIndex = lastValidUser.placards
          .indexWhere((placard) => placard.id == event.placedPlacardId);
      // TODO: this throws an error sometimes (index out of range)
      final currentPlacardState = lastValidUser.placards[placardIndex];
      if (currentPlacardState.likeState != event.likeState) {
        final scoreDelta = event.likeState - currentPlacardState.likeState;
        final newPlacardState = PlacedPlacard.copyWith(
          currentPlacardState,
          score: currentPlacardState.score + scoreDelta,
          likeState: event.likeState,
        );
        final List<PlacedPlacard> newPlacards =
            List.from(lastValidUser.placards);
        newPlacards[placardIndex] = newPlacardState;
        yield UserStateTentative(User.copyWith(
          lastValidUser,
          placards: newPlacards,
        ));
        try {
          final newPlacard = await _apiManager.setLikeState(
            event.placedPlacardId,
            event.likeState,
          );
          newPlacards[placardIndex] = newPlacard;
          lastValidUser = User.copyWith(
            lastValidUser,
            placards: newPlacards,
          );
          yield UserStateDefinite(lastValidUser);
        } catch (e) {
          print(e);
          yield UserStateError(lastValidUser);
        }
      }
    } else if (event is PlacardAdded) {
      if (lastValidUser.isSelf) {
        // Just return the same state, since adding a new placard would require making another request
        yield UserStateTentative(lastValidUser);
        try {
          final newPlacard = await _apiManager.placePlacard(
            event.placardTypeId,
          );
          lastValidUser.placards.add(newPlacard);
          yield UserStateDefinite(lastValidUser);
        } catch (e) {
          print(e);
          yield UserStateError(lastValidUser);
        }
      }
    } else if (event is UserInfoChangeCancelled) {
      yield UserStateTentative(lastValidUser);
      try {
        yield UserStateDefinite(await _apiManager.getSelfUser());
      } catch (e) {
        print(e);
        yield UserStateError(lastValidUser);
      }
    }
  }
}
