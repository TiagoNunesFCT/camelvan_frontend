//The Open Street Maps Tile Layer
import 'package:camelvan_frontend/view/sellerLandingPage.dart';
import 'package:camelvan_frontend/view/sellerMapPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

TileLayer mapService = TileLayer(
    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    tileProvider: CachedTileProvider(),
    subdomains: ['a', 'b', 'c']);

//Marker Layers
MarkerLayer mapMarkers = MarkerLayer(        markers: [
  Marker(
    width: 80.0,
    height: 80.0,
    point: LatLng(38.657, -9.15),
    builder: (ctx) =>
        Container(
          child: IconButton(icon: Icon(Icons.my_location_rounded, color:Colors.red),onPressed: () {                        Navigator.push(
            ctx,
            MaterialPageRoute(builder: (context) => SellerMapPage()),//REPLACE THIS WITH THE PAGE YOU WANT
          );},),
        ),
  ),
  Marker(
    width: 80.0,
    height: 80.0,
    point: LatLng(38.663, -9.215),
    builder: (ctx) =>
        Container(
          child: IconButton(icon: Icon(Icons.my_location_rounded, color:Colors.red),onPressed: () {                        Navigator.push(
            ctx,
            MaterialPageRoute(builder: (context) => SellerMapPage()),//REPLACE THIS WITH THE PAGE YOU WANT
          );},),
        ),
  ),
  Marker(
    width: 80.0,
    height: 80.0,
    point: LatLng(latitude, longitude),
    builder: (ctx) =>
        Container(
          child: IconButton(icon: Icon(Icons.man_rounded, color:Colors.blue),onPressed: () {                        Navigator.push(
            ctx,
            MaterialPageRoute(builder: (context) => SellerMapPage()),
          );},),
        ),
  ),
]);




////NO SCAFFOLD DA PÁGINA:

/*
FlutterMap(options: MapOptions(
center: LatLng(38.66, -9.17),
zoom: 13.0,
), children: [mapService, mapMarkers],)

 */