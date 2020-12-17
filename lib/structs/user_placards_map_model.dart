class UserPlacardsMapModel {
  UserPlacardsMapModel(
    this.id,
    this.latitude,
    this.longitude,
    this.placedPlacardIds,
  );

  final String id;
  final List<String> placedPlacardIds;
  final double latitude;
  final double longitude;

  void rotatePlacards() {
    if (placedPlacardIds != null && placedPlacardIds.isNotEmpty) {
      placedPlacardIds.add(placedPlacardIds.removeAt(0));
    }
  }
}
