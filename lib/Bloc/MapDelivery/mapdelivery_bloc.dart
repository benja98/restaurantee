import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
// ignore: library_prefixes
import 'package:polyline_do/polyline_do.dart' as Polylinedo;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restaurantee/Controller/MapBoxController.dart';
import 'package:restaurantee/Helpers/Helpers.dart';
import 'package:restaurantee/Services/url.dart';
import 'package:restaurantee/Themes/ThemeMaps.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'mapdelivery_event.dart';
part 'mapdelivery_state.dart';

class MapdeliveryBloc extends Bloc<MapdeliveryEvent, MapdeliveryState> {
  MapdeliveryBloc() : super(MapdeliveryState()) {
    on<OnMapReadyEvent>(_onMapReady);
    on<OnMarkertsDeliveryEvent>(_onMarkertDelivery);
    on<OnEmitLocationDeliveryEvent>(_onEmitLocationDelivery);
  }

  late GoogleMapController _mapController;
  late IO.Socket _socket;

  Polyline _myRouteDestinationDelivery = const Polyline(
      polylineId: PolylineId('myRouteDestinationDelivery'),
      color: Colors.black87,
      width: 5);

  void initMapDeliveryFrave(GoogleMapController controller) {
    if (!state.isReadyMapDelivery) {
      _mapController = controller;

      _mapController.setMapStyle(jsonEncode(themeMapsFrave));

      add(OnMapReadyEvent());
    }
  }

  void moveCamareLocation(LatLng location) {
    final cameraUpdate = CameraUpdate.newLatLng(location);
    _mapController.animateCamera(cameraUpdate);
  }

  void initSocketDelivery() {
    _socket = IO.io('${URLS.BASE_URL}orders-delivery-socket', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.connect();
  }

  void disconectSocket() {
    _socket.disconnect();
  }

  Future<void> _onMapReady(
      OnMapReadyEvent event, Emitter<MapdeliveryState> emit) async {
    emit(state.copyWith(isReadyMapDelivery: true));
  }

  Future<void> _onMarkertDelivery(
      OnMarkertsDeliveryEvent event, Emitter<MapdeliveryState> emit) async {
    // Polylines

    final mapBoxResponse =
        await mapBoxController.getCoordsOriginAndDestinationDelivery(
            event.location, event.destination);

    final geometry = mapBoxResponse.routes![0].geometry;

    final points = Polylinedo.Polyline.Decode(
            encodedString: geometry.toString(), precision: 6)
        .decodedCoords;

    final List<LatLng> routeCoords =
        points.map((p) => LatLng(p[0], p[1])).toList();

    _myRouteDestinationDelivery =
        _myRouteDestinationDelivery.copyWith(pointsParam: routeCoords);

    final currentPoylines = state.polyline;
    currentPoylines!['myRouteDestinationDelivery'] =
        _myRouteDestinationDelivery;

    // ------------------------ Markets

    final marketCustom =
        await getAssetImageMarker('Assets/food-delivery-marker.png');
    final iconDestination =
        await getAssetImageMarker('Assets/delivery-destination.png');

    final markerDelivery = Marker(
        markerId: const MarkerId('markerDelivery'),
        position: event.location,
        icon: marketCustom);

    final markerDestination = Marker(
        markerId: const MarkerId('markerDestination'),
        position: event.destination,
        icon: iconDestination);

    final newMarker = {...state.markers};
    newMarker['markerDelivery'] = markerDelivery;
    newMarker['markerDestination'] = markerDestination;

    emit(state.copyWith(polyline: currentPoylines, markers: newMarker));
  }

  Future<void> _onEmitLocationDelivery(
      OnEmitLocationDeliveryEvent event, Emitter<MapdeliveryState> emit) async {
    _socket.emit('position', {
      'idOrder': event.idOrder,
      'latitude': event.location.latitude,
      'longitude': event.location.longitude
    });
  }
}
