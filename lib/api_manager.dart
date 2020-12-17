import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:placard_frontend/structs/login_credentials.dart';
import 'package:placard_frontend/structs/placard_type.dart';
import 'package:placard_frontend/structs/placed_placard.dart';
import 'package:placard_frontend/structs/user.dart';
import 'package:placard_frontend/structs/user_error_type.dart';
import 'package:placard_frontend/structs/user_placards_map_model.dart';

// TODO: remove this later
import 'package:uuid/uuid.dart';
import 'package:english_words/english_words.dart';

class APIManager {
  APIManager(this.loginCredentials);

  static const baseURL = 'http://localhost:8097';

  final DefaultCacheManager cacheManager = DefaultCacheManager();
  final LoginCredentials loginCredentials;

  Future<Uint8List> getPlacardImage(String id) async {
    // final url = '$baseURL/placard_image?placard_type_id=$id';
    final links = const [
      'https://hobbelpaarde.files.wordpress.com/2014/03/img_0804.jpg',
      'https://i.ytimg.com/vi/8pLunejSTnw/maxresdefault.jpg',
      'https://i.ytimg.com/vi/Mxv-o_R6JRg/maxresdefault.jpg',
      'https://keyassets.timeincuk.net/inspirewp/live/wp-content/uploads/sites/12/2016/09/iStock-landscape.jpg',
      'https://learn.zoner.com/wp-content/uploads/2018/08/landscape-photography-at-every-hour-part-ii-photographing-landscapes-in-rain-or-shine.jpg',
      'https://cdn.fstoppers.com/styles/large-16-9/s3/lead/2018/11/stop-taking-cliche-and-iconic-landscape-images.jpg',
    ];
    final url = links[Random().nextInt(links.length)];
    return await cacheManager
        .getSingleFile(url)
        .then((res) => res.readAsBytes());
  }

  Future<User> getSelfUser() async {
    List<PlacedPlacard> placards = [];
    for (int i = 0; i < Random().nextInt(5); i++) {
      placards.add(await getPlacedPlacardInfo(Uuid().v4()));
    }
    return User(Uuid().v4(), generateWordPairs().first.asPascalCase, true,
        42.33118, -71.257840, placards,
        email: '${generateWordPairs().first.asLowerCase}@gmail.com',
        address:
            '${Random().nextInt(999) + 1} ${generateWordPairs().first.asPascalCase} Street, Boston MA, 02495');
  }

  Future<User> getOtherUser(String id) async {
    List<PlacedPlacard> placards = [];
    for (int i = 0; i < Random().nextInt(5); i++) {
      placards.add(await getPlacedPlacardInfo(Uuid().v4()));
    }
    return User(
      Uuid().v4(),
      generateWordPairs().first.asPascalCase,
      false,
      43.33118,
      -72.257840,
      placards,
    );
  }

  Future<PlacardType> getPlacardTypeInfo(String id) async {
    return PlacardType(
      id,
      generateWordPairs().first.asPascalCase,
      await getPlacardImage(id),
    );
  }

  Future<PlacedPlacard> getPlacedPlacardInfo(String id) async {
    return PlacedPlacard(
      id,
      await getPlacardTypeInfo(Uuid().v4()),
      Random().nextInt(200),
      Random().nextInt(3) - 1,
    );
  }

  Future<List<UserPlacardsMapModel>> getMapChunkPlacards(
    double minLat,
    double maxLat,
    double minLong,
    double maxLong,
  ) async {
    final List<UserPlacardsMapModel> placardModelList = [];
    for (int i = 0; i < (Random().nextInt(7) + 1); i++) {
      double distanceLong;
      if (minLong > maxLong) {
        distanceLong = 360 - minLong.abs() - maxLong.abs();
      } else {
        distanceLong = maxLong - minLong;
      }

      double distanceLat = maxLat - minLat;

      final List<String> placardList = [];

      for (int j = 0; j < (Random().nextInt(5)); j++) {
        placardList.add(Uuid().v4());
      }

      placardModelList.add(
        UserPlacardsMapModel(
          Uuid().v4(),
          ((180 + minLat + (Random().nextDouble() * distanceLat)) % 360) - 180,
          ((180 + minLong + (Random().nextDouble() * distanceLong)) % 360) -
              180,
          placardList,
        ),
      );
    }
    return placardModelList;
  }

  Future<List<PlacardType>> getSearchResults(String query) async {
    final List<PlacardType> results = [];
    for (int i = 0; i < (Random().nextInt(5)); i++) {
      results.add(await getPlacardTypeInfo(Uuid().v4()));
    }
    return results;
  }

  Future<User> editUserInfo(
      {String username, String email, String address, String password}) async {
    // TODO: do something with password, probably separate request
    if (Random().nextBool()) {
      throw UserErrorType.fromJSON({
        'username': Random().nextBool() ? 'taken' : 'none',
        'email': Random().nextBool() ? 'invalid' : 'none',
        'address': Random().nextBool() ? 'invalid' : 'none',
        'password': Random().nextBool() ? 'invalid' : 'none',
      });
    }
    return User.copyWith(
      await getSelfUser(),
      username: username,
      email: email,
      address: address,
    );
  }

  Future<PlacedPlacard> placePlacard(String placardTypeId) async {
    return PlacedPlacard(
      Uuid().v4(),
      await getPlacardTypeInfo(Uuid().v4()),
      1,
      1,
    );
  }

  Future<PlacedPlacard> setLikeState(
      String placedPlacardId, int likeState) async {
    if (likeState != -1 && likeState != 0 && likeState != 1) {
      throw Exception("Invalid Like State");
    }
    return PlacedPlacard(
      placedPlacardId,
      await getPlacardTypeInfo(Uuid().v4()),
      Random().nextInt(200),
      likeState,
    );
  }
}
