import 'dart:async';

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

//seller coordinates
double latitude = 0;
double longitude = 0;


FlutterMap leMap = FlutterMap(options: MapOptions(
  center: LatLng(38.66, -9.17),
  zoom: 13.0,
), children: [mapService, mapMarkers],);




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


class SellerLandingPage extends StatefulWidget {
  const SellerLandingPage({Key? key}) : super(key: key);

  @override
  State<SellerLandingPage> createState() => _SellerLandingPageState();
}

class _SellerLandingPageState extends State<SellerLandingPage> {

  bool serviceStatus = false;
  bool hasPermission = false;
  late LocationPermission permission;
  late Position position;
  late StreamSubscription<Position> positionStream;


  void redrawMap(){
    leMap = FlutterMap(options: MapOptions(
      center: LatLng(38.66, -9.17),
      zoom: 13.0,
    ), children: [mapService, mapMarkers],);
  }

  //The State's Initialization
  @override
  void initState() {

;

    //if this is the first time the page is running, initialize the map
    if (firstState) {
      /*initMap();*/
    }

    //start Geolocation
    checkGps();
    super.initState();





  }



  checkGps() async {
    serviceStatus = await Geolocator.isLocationServiceEnabled();
    if(serviceStatus){
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        }else if(permission == LocationPermission.deniedForever){
          print("'Location permissions are permanently denied");
        }else{
          hasPermission = true;
        }
      }else{
        hasPermission = true;
      }

      if(hasPermission){
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    }else{
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("geoLocation() Method Coordinates");
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457


    longitude = position.longitude;
    latitude = position.latitude;

    setState(() {
      //refresh UI
    });

   const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 5, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

     positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) {

      print("positionStream() Method Coordinates");
      print(position.latitude); //Output: 29.6593457
      print(position.longitude); //Output: 80.24599079

      longitude = position.longitude;
      latitude = position.latitude;

      setState(() {
        //refresh UI on update
      });
    });
  }











  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('')
        ),
        body: Center(
            child: Container(
                child: Stack(children:[leMap,
                    Text("Current Position: Lat: " + latitude.toString() + " Lon: " + longitude.toString())])
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



/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

enum _PositionItemType {
  log,
  position,
}


class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}

