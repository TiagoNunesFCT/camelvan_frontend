import 'package:cached_network_image/cached_network_image.dart';
import 'package:camelvan_frontend/view/buyerLandingPage.dart';
import 'package:camelvan_frontend/view/sellerMapPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

//Has a signal been received at this moment? (useful for the indicator)
bool gotSignal = false;
//Is this the first initialization of the page?
bool firstState = true;
//Has the map been initialized?
bool initializedMap = false;
//Is this the first time geolocation data was aquired? (useful to automatically center and zoom for the first time)
bool firstSignal = true;

//The Open Street Maps Tile Layer
TileLayer mapService = TileLayer(
    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    tileProvider: CachedTileProvider(),
    subdomains: ['a', 'b', 'c']);

MarkerLayer mapMarkers = MarkerLayer(        markers: [
  Marker(
    width: 80.0,
    height: 80.0,
    point: LatLng(38.657, -9.15),
    builder: (ctx) =>
        Container(
          child: IconButton(icon: Icon(Icons.my_location_rounded, color:Colors.red),onPressed: () {                        Navigator.push(
            ctx,
            MaterialPageRoute(builder: (context) => SellerMapPage()),
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
            MaterialPageRoute(builder: (context) => SellerMapPage()),
          );},),
        ),
  ),
]);


class SellerLandingPage extends StatefulWidget {
  const SellerLandingPage({Key? key}) : super(key: key);

  @override
  State<SellerLandingPage> createState() => _SellerLandingPageState();
}

class _SellerLandingPageState extends State<SellerLandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('')
        ),
        body: Center(
            child: Container(
                child: Stack(children:[FlutterMap(options: MapOptions(
                  center: LatLng(38.66, -9.17),
                  zoom: 13.0,
                ), children: [mapService, MarkerLayer()],)/*,Image.asset('assets/bbicon.png', fit: BoxFit.scaleDown)*/])
            )
        )
    );
  }
}





class CachedTileProvider extends TileProvider {
  CachedTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer tileLayer) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, tileLayer),
      //Now you can set options that determine how the image gets cached via whichever plugin you use.
    );
  }
}