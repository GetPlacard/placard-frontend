import 'package:placard_frontend/structs/placard_type.dart';

class PlacedPlacard {
  const PlacedPlacard(
    this.id,
    this.type,
    this.score,
    this.likeState,
  );

  PlacedPlacard.copyWith(
    PlacedPlacard placard, {
    String id,
    PlacardType type,
    int score,
    int likeState,
  }) : this(
          id ?? placard.id,
          type ?? placard.type,
          score ?? placard.score,
          likeState ?? placard.likeState,
        );

  final String id;
  final PlacardType type;
  final int score;
  final int likeState;
}
