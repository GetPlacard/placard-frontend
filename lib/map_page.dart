import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:placard_frontend/account_page.dart';
import 'package:placard_frontend/api_manager.dart';
import 'package:placard_frontend/user_bloc/user_bloc.dart';
import 'package:placard_frontend/user_placards_map_marker.dart';
import 'package:placard_frontend/map_styles.dart';
import 'package:placard_frontend/structs/user_placards_map_model.dart';

// This is a class so that it can be passed by reference (i think that's how it works?)
// https://stackoverflow.com/a/18273525/8005366
class MapState {
  bool ready = false;
}

class MapPage extends StatefulWidget {
  MapPage({
    Key key,
    this.selfUserTappedCallback,
    this.selfUserId,
    this.onMapReady,
    this.mapState,
  }) : super(key: key);

  final selfUserTappedCallback;
  final selfUserId;

  final Function onMapReady;
  final MapState mapState;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const double tileSize = 0.1;
  // The map stops rendering markers when they are offscreen + this distance away
  static const double mapMoveBufferBorderSize = 0.015;
  static const int maxRequests = 10;

  Completer<GoogleMapController> _mapController = Completer();
  final Map<String, UserPlacardsMapMarker> _userMarkers = {};
  Set<Marker> _markers = Set();
  Timer _markerTimer;
  Timer _moveTimer;
  APIManager _apiManager;

  Set<LatLngBounds> _alreadyCachedBounds = Set();

  // Starting position of camera before it's set to user location
  // Currently set to Boston, Massachusetts
  static final CameraPosition _homePos = CameraPosition(
    target: LatLng(42.361145, -71.057083),
    zoom: 10,
  );

  @override
  void initState() {
    // set map state to not ready
    this.widget.mapState.ready = false;
    _tryLocation();
    _markerTimer = Timer.periodic(Duration(seconds: 5), _updateAllMarkers);
    _apiManager = context.repository<APIManager>();
    super.initState();
  }

  @override
  void dispose() {
    _markerTimer.cancel();
    if (_moveTimer != null) {
      _moveTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _homePos,
        tiltGesturesEnabled: false,
        onMapCreated: (GoogleMapController controller) async {
          _mapController.complete(controller);
          // TODO: Themes
          controller.setMapStyle(lightStyle);
          _initializeMap();
        },
        onCameraMove: (CameraPosition cameraPosition) {
          if (_moveTimer != null) {
            _moveTimer.cancel();
          }
          _moveTimer = Timer(Duration(milliseconds: 500), _getNewMarkers);
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final LocationData location = await _tryLocation();
            final GoogleMapController controller = await _mapController.future;

            final CameraPosition newCameraPosition = CameraPosition(
                bearing: 0,
                target: LatLng(location.latitude, location.longitude),
                tilt: 0,
                zoom: 16);

            controller.animateCamera(
                CameraUpdate.newCameraPosition(newCameraPosition));
          } catch (e) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('You have not granted the location permission'),
                action: SnackBarAction(
                  label: 'Try Again',
                  onPressed: _tryLocation,
                ),
              ),
            );
          }
        },
        child: Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _updateAllMarkers(Timer timer) async {
    final controller = await _mapController.future;
    if (await controller.getZoomLevel() > 15) {
      Set<Marker> newMarkers = Set();
      await Future.wait(_userMarkers.values.map((marker) async {
        final cameraBounds = await controller.getVisibleRegion();

        bool visibleLong = false;
        if (cameraBounds.southwest.longitude >
            cameraBounds.northeast.longitude) {
          if ((cameraBounds.southwest.longitude - mapMoveBufferBorderSize <
                      marker.userPlacardsModel.longitude &&
                  marker.userPlacardsModel.longitude < 180) ||
              (-180 < marker.userPlacardsModel.longitude &&
                  marker.userPlacardsModel.longitude <
                      cameraBounds.northeast.longitude +
                          mapMoveBufferBorderSize)) {
            visibleLong = true;
          }
        } else {
          if (cameraBounds.southwest.longitude - mapMoveBufferBorderSize <
                  marker.userPlacardsModel.longitude &&
              marker.userPlacardsModel.longitude <
                  cameraBounds.northeast.longitude + mapMoveBufferBorderSize) {
            visibleLong = true;
          }
        }

        if (visibleLong &&
            cameraBounds.southwest.latitude - mapMoveBufferBorderSize <
                marker.userPlacardsModel.latitude &&
            marker.userPlacardsModel.latitude <
                cameraBounds.northeast.latitude + mapMoveBufferBorderSize) {
          await marker.updateMarkerImage();
          if (marker.userPlacardsModel.placedPlacardIds.isNotEmpty) {
            newMarkers.add(marker.toMarker());
          }
        }
      }));
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  Future<void> _getNewMarkers() async {
    final controller = await _mapController.future;

    // TODO: make sure the server deals with when the camera is over the 180/-180 deg lat line
    // https://pub.dev/documentation/google_maps_flutter_platform_interface/latest/google_maps_flutter_platform_interface/LatLngBounds-class.html
    final cameraBounds = await controller.getVisibleRegion();

    double distanceLong;
    if (cameraBounds.southwest.longitude > cameraBounds.northeast.longitude) {
      distanceLong = 360 -
          cameraBounds.southwest.longitude.abs() -
          cameraBounds.northeast.longitude.abs();
    } else {
      distanceLong =
          cameraBounds.northeast.longitude - cameraBounds.southwest.longitude;
    }

    double distanceLat =
        cameraBounds.northeast.latitude - cameraBounds.southwest.latitude;

    // If the screen is smaller than one tile
    if (distanceLong < tileSize && distanceLat < tileSize) {
      if (!_alreadyCachedBounds.contains(cameraBounds)) {
        final chunkResults = await _apiManager.getMapChunkPlacards(
          cameraBounds.northeast.latitude,
          cameraBounds.southwest.latitude,
          cameraBounds.southwest.longitude,
          cameraBounds.northeast.longitude,
        );
        await Future.wait(chunkResults.map((UserPlacardsMapModel result) async {
          final newUserMarker = UserPlacardsMapMarker(
            result,
            _createMapMarkerTapCallback(result),
            context.repository<APIManager>(),
          );
          _userMarkers[result.id] = newUserMarker;
          if (newUserMarker.userPlacardsModel.placedPlacardIds.isNotEmpty) {
            await newUserMarker.updateMarkerImage();
            _markers.add(newUserMarker.toMarker());
          }
        }));
        _alreadyCachedBounds.add(cameraBounds);
        setState(() {});
      }
    } else {
      if (cameraBounds.southwest.longitude > cameraBounds.northeast.longitude) {
        // If split over date line, split into two parts
        double roundedLeftMinLong = cameraBounds.southwest.latitude -
            (cameraBounds.southwest.latitude % tileSize);
        double roundedLeftMaxLong = 180;
        double roundedRightMinLong = -180;
        double roundedRightMaxLong = cameraBounds.northeast.latitude +
            (tileSize - (cameraBounds.northeast.latitude % tileSize));

        double roundedMinLat = cameraBounds.southwest.longitude -
            (cameraBounds.southwest.longitude % tileSize);
        double roundedMaxLat = cameraBounds.northeast.longitude +
            (tileSize - (cameraBounds.northeast.longitude % tileSize));

        final leftRequests = (1 / tileSize) *
            (roundedLeftMaxLong - roundedLeftMinLong) *
            (1 / tileSize) *
            (roundedMaxLat - roundedMinLat);
        final rightRequests = (1 / tileSize) *
            (roundedRightMaxLong - roundedRightMinLong) *
            (1 / tileSize) *
            (roundedMaxLat - roundedMinLat);

        if (leftRequests + rightRequests < maxRequests) {
          for (double i = roundedLeftMinLong;
              i <= roundedLeftMaxLong;
              i += tileSize) {
            for (double j = roundedMinLat; j <= roundedMaxLat; j += tileSize) {
              // vars are backwards because lat, long
              _addUserPlacardMarkers(j, i);
            }
          }
          for (double i = roundedRightMinLong;
              i <= roundedRightMaxLong;
              i += tileSize) {
            for (double j = roundedMinLat; j <= roundedMaxLat; j += tileSize) {
              _addUserPlacardMarkers(j, i);
            }
          }
        }
      } else {
        double roundedMinLat = cameraBounds.southwest.latitude -
            (cameraBounds.southwest.latitude % tileSize);
        double roundedMaxLat = cameraBounds.southwest.latitude -
            (cameraBounds.southwest.latitude % tileSize) +
            tileSize;
        double roundedMinLong = cameraBounds.southwest.longitude -
            (cameraBounds.southwest.longitude % tileSize);
        double roundedMaxLong = cameraBounds.northeast.longitude +
            (tileSize - (cameraBounds.northeast.longitude % tileSize));

        if ((1 / tileSize) *
                (roundedMaxLat - roundedMinLat) *
                (1 / tileSize) *
                (roundedMaxLong - roundedMinLong) <
            maxRequests) {
          final futureList = <Future<void>>[];
          for (double i = roundedMinLat; i <= roundedMaxLat; i += tileSize) {
            for (double j = roundedMinLong;
                j <= roundedMaxLong;
                j += tileSize) {
              futureList.add(_addUserPlacardMarkers(i, j));
            }
          }
          await Future.wait(futureList);
          setState(() {});
        }
      }
    }
  }

  // create markers for a certain chunk
  Future<void> _addUserPlacardMarkers(double minLat, double minLong) async {
    final tileBounds = LatLngBounds(
      southwest: LatLng(minLat, minLong + tileSize),
      northeast: LatLng(minLat + tileSize, minLong),
    );
    if (!_alreadyCachedBounds.contains(tileBounds)) {
      final chunkResults = await _apiManager.getMapChunkPlacards(
        minLat,
        minLat + tileSize,
        minLong,
        minLong + tileSize,
      );
      await Future.wait(chunkResults.map((UserPlacardsMapModel result) async {
        final newUserMarker = UserPlacardsMapMarker(
          result,
          _createMapMarkerTapCallback(result),
          context.repository<APIManager>(),
        );
        _userMarkers[result.id] = newUserMarker;
        if (newUserMarker.userPlacardsModel.placedPlacardIds.isNotEmpty) {
          await newUserMarker.updateMarkerImage();
          _markers.add(newUserMarker.toMarker());
        }
      }));
      _alreadyCachedBounds.add(tileBounds);
    }
  }

  Function _createMapMarkerTapCallback(UserPlacardsMapModel model) {
    if (model.id == this.widget.selfUserId) {
      return this.widget.selfUserTappedCallback;
    } else {
      return () async {
        final accountPage = AccountPage(
          UserBloc(await _apiManager.getOtherUser(model.id), _apiManager),
          key: PageStorageKey('otherUserAccountPage'),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => accountPage,
          ),
        );
      };
    }
  }

  Future<void> _initializeMap() async {
    try {
      final LocationData location = await _tryLocation();
      final GoogleMapController controller = await _mapController.future;

      final CameraPosition newCameraPosition = CameraPosition(
        bearing: 0,
        target: LatLng(location.latitude, location.longitude),
        tilt: 0,
        zoom: 16,
      );

      await controller
          .moveCamera(CameraUpdate.newCameraPosition(newCameraPosition));
    } catch (e) {
      try {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('You have not granted the location permission'),
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: _tryLocation,
            ),
          ),
        );
      } catch (e) {
        print(e);
      }
    }

    await _getNewMarkers();

    // idk i just have to pass an argument dart is dumb
    await _updateAllMarkers(_markerTimer);

    // Call Map Ready Callback
    this.widget.onMapReady();

    this.widget.mapState.ready = true;
  }

  Future<LocationData> _tryLocation() async {
    Location location = new Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw 'Location Service Unavailable';
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw 'Location Permission Not Granted';
      }
    }

    return location.getLocation();
  }
}
