import 'dart:typed_data';

class PlacardType {
  const PlacardType(
    this.id,
    this.name,
    this.imageBytes,
  );

  final String id;
  final String name;
  final Uint8List imageBytes;
}
