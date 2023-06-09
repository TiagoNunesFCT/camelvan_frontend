import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camelvan_frontend/view/buyerLandingPage.dart';
import 'package:camelvan_frontend/view/sellerMapPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:counter_button/counter_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:overlay_support/overlay_support.dart';



//seller coordinates
double latitude = 0;
double longitude = 0;


//marker list (for dynamic map marker loading)
List<Marker> loadedMarkers = [];

FlutterMap? leMap = FlutterMap(options: MapOptions(
  center: LatLng(38.66, -9.17),
  zoom: 13.0,
), children: [mapService, mapMarkers], mapController: mapController,);


final mapController = MapController();

//The Open Street Maps Tile Layer
TileLayer mapService = TileLayer(
    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    tileProvider: CachedTileProvider(),
    subdomains: ['a', 'b', 'c']);

//Location Marker. Defined here so it can be re-used often
Marker locationMarker= Marker(
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
);

MarkerLayer mapMarkers = MarkerLayer(
markers: [    locationMarker, Marker(
  width: 80.0,
  height: 80.0,
  point: LatLng(38.632154180709875,  -9.23013084934219),
  builder: (ctx) =>
      Container(
        child: IconButton(icon: Icon(Icons.navigation_rounded, color:Colors.blue),onPressed: () {                        Navigator.push(
          ctx,
          MaterialPageRoute(builder: (context) => SellerMapPage()),
        );},),
      ),
), Marker(
  width: 80.0,
  height: 80.0,
  point: LatLng(38.63091578859596,  -9.228979344505069),
  builder: (ctx) =>
      Container(
        child: IconButton(icon: Icon(Icons.pin_drop_rounded, color:Colors.red),onPressed: () {                        Navigator.push(
          ctx,
          MaterialPageRoute(builder: (context) => SellerMapPage()),
        );},),
      ),
), Marker(
  width: 80.0,
  height: 80.0,
  point: LatLng(38.63223596761142,  -9.23059446294993),
  builder: (ctx) =>
      Container(
        child: IconButton(icon: Icon(Icons.pin_drop_rounded, color:Colors.red),onPressed: () {                        Navigator.push(
          ctx,
          MaterialPageRoute(builder: (context) => SellerMapPage()),
        );},),
      ),
)]);


class SellerLandingPage extends StatefulWidget {
  const SellerLandingPage({Key? key}) : super(key: key);

  @override
  State<SellerLandingPage> createState() => _SellerLandingPageState();
}


class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });

  String? title;
  String? body;
}

class NotificationBadge extends StatelessWidget {

  final Function()? accepted;

  const NotificationBadge({this.accepted});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 40.0,
        height: 40.0,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ElevatedButton(
            onPressed: () {
            print(accepted);
              accepted!();
              OverlaySupportEntry.of(context)!.dismiss();
            },
            child: Text('Accept'),
          ),
          ElevatedButton(
            onPressed: () {
              OverlaySupportEntry.of(context)!.dismiss();
            },
            child: Text('Dismiss'),
          )
        ]));
  }
}

class _SellerLandingPageState extends State<SellerLandingPage> {

  PushNotification? _notificationInfo;
  bool serviceStatus = false;
  bool hasPermission = false;
  late LocationPermission permission;
  late Position position;
  late StreamSubscription<Position> positionStream;
  late Future<dynamic> productList;
  List<int> quantityList = [];
  FirebaseFirestore db = FirebaseFirestore.instance;


  void redrawMap(){

    List<Marker> allMarkers = mapMarkers.markers;
    allMarkers[0] =   Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(latitude, longitude),
      builder: (ctx) =>
          Container(
            child: IconButton(icon: Icon(Icons.navigation_rounded, color:Colors.blue),onPressed: () {
              /*Navigator.push(
              ctx,
              MaterialPageRoute(builder: (context) => SellerMapPage()),
            );*/
            print("pressed");},),
          ),
    );


    mapMarkers = MarkerLayer(markers:allMarkers);


    print("redrawingMap");
    setState(() {

      leMap = FlutterMap(options: MapOptions(
        center: LatLng(latitude, longitude),
        zoom: 13.0,
      ), children: [mapService, mapMarkers], mapController: mapController,);
    });

  }


  void registerNotification() async {
    // For handling the received notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      print("AAAAAAAAAAAAAAAAA");
      print(message.data);




      // Parse the message received
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );

      setState(() {
        _notificationInfo = notification;
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // ...
      
      
      
      if (_notificationInfo != null) {
        // For displaying the notification as an overlay
        showSimpleNotification(
          Text(_notificationInfo!.title!),
          subtitle: NotificationBadge(accepted: () {
            loadMarkers(message.data["route"]);
          }),
          duration: Duration(seconds: 10),
        );
      }
    });
  }

  //The State's Initialization
  @override
  void initState() {
    super.initState();
    productList = getProducts();
    registerNotification();

    //if this is the first time the page is running, initialize the map


    //start Geolocation
    checkGps();
    super.initState();

  }

  Future<dynamic> getProducts() async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      final docRef = db
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection("products");
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await FirebaseFunctions.instance.httpsCallable('addToken').call({
        "token": fcmToken,
      });

      docRef.get().then((value) {
        for (var element in value.docs) {
          quantityList.add(element.data()['quantity']);
        }
      });

      return docRef.get();
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
    }
    return [];
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
      redrawMap();
    });

   const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 0, //minimum distance (measured in meters) a
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
        redrawMap();
      });
    });
  }




void loadMarkers(List<List<double>> payload){
  print("Logging: loading markers");
  print("Found "+payload.length.toString()+" markers.");
  List<List<double>> loadedMarkerList = payload;
  List<Marker> newMarkerList = [];
  newMarkerList.add(locationMarker);
  for (List<double> coord in loadedMarkerList){
    print("Found Marker: Lat: " + coord[0].toString()+ " Lon: " + coord[1].toString());
    Marker toAdd = Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(coord[0], coord[1]),
      builder: (ctx) =>
          Container(
            child: IconButton(icon: Icon(Icons.my_location_rounded, color:Colors.red),onPressed: () {
              /*Navigator.push(
              ctx,
              MaterialPageRoute(builder: (context) => SellerMapPage()),
            );*/
            print("pressed");},),
          ),
    );
    print("Marker Created");
    newMarkerList.add(toAdd);
    print("Marker Added to List");
  }

  mapMarkers = MarkerLayer(markers: newMarkerList);
  setState(() {
    redrawMap();
  });
}






  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('HomePage'),
        ),
        //future builder for DraggableScrollableSheet
        body: Stack(children:[leMap!,FutureBuilder<dynamic>(
          future: productList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print((snapshot.data!).docs);
              List<dynamic> list =
                  snapshot.data!.docs.map((e) => e.data()).toList();
              print(list);
              return DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.25,
                  maxChildSize: 0.75,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      color: Colors.white,
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Material(color:(index % 2 == 0) ? const Color(0xFFf4d6b1) : const Color(0xFFecc18d), child:ListTile(

                              tileColor: (index % 2 == 0) ? const Color(0xFFf4d6b1) : const Color(0xFFecc18d),
                              title: Text(list[index]['name']),
                              subtitle: Text(
                                  '${list[index]['price'] / 100}€ - ${list[index]['minDistance']}m'),
                              leading:
                                  Image(image: AssetImage('assets/bbicon.png')),
                              trailing: //counter button
                                  CounterButton(
                                key: UniqueKey(),
                                loading: false,
                                onChange: (int val) {
                                  setState(() {
                                    if (val > -1) {
                                      quantityList[index] = val;

                                      db
                                          .collection("users")
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.email)
                                          .collection("products")
                                          .doc(list[index]['dbid'])
                                          .update({"quantity": val});

                                      print(quantityList[index]);
                                    }
                                  });
                                },
                                count: quantityList[index],
                              )));
                        },
                      ),
                    );
                  });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )]));

    // body: SizedBox.expand(child: DraggableScrollableSheet(
    //   builder: (BuildContext context, ScrollController scrollController) {
    //     return Container(
    //       child: ListView.builder(
    //         controller: scrollController,
    //         itemCount: 25,
    //         itemBuilder: (BuildContext context, int index) {
    //           return ListTile(
    //               title: Text('Item $index'),
    //               tileColor: (index % 2 == 0)
    //                   ? const Color(0xFFf4d6b1)
    //                   : const Color(0xFFecc18d));
    //         },
    //       ),
    //     );
    //   },
    // )));
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

