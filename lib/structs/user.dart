import 'package:placard_frontend/structs/placed_placard.dart';

class User {
  const User(this.id, this.username, this.isSelf, this.latitude, this.longitude,
      this.placards,
      {this.email, this.address});

  User.copyWith(
    User original, {
    String id,
    String username,
    String email,
    bool isSelf,
    String latitude,
    String longitude,
    String address,
    List<PlacedPlacard> placards,
  }) : this(
          id ?? original.id,
          username ?? original.username,
          isSelf ?? original.isSelf,
          latitude ?? original.latitude,
          longitude ?? original.longitude,
          placards ?? original.placards,
          email: email ?? original.email,
          address: address ?? original.address,
        );

  final String id;
  final String username;
  final String email;
  final bool isSelf;
  final double latitude;
  final double longitude;
  final String address;
  final List<PlacedPlacard> placards;
}
