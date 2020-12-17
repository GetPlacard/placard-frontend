abstract class UserChangeEvent {}

class UserInfoChanged extends UserChangeEvent {
  UserInfoChanged({this.username, this.email, this.address, this.password});

  String username;
  String email;
  String address;
  String password;
}

class PlacardLikeStateChanged extends UserChangeEvent {
  PlacardLikeStateChanged(this.placedPlacardId, this.likeState);

  final String placedPlacardId;
  final int likeState;
}

class PlacardAdded extends UserChangeEvent {
  PlacardAdded(this.placardTypeId);

  final String placardTypeId;
}

class UserInfoChangeCancelled extends UserChangeEvent {
  UserInfoChangeCancelled();
}
