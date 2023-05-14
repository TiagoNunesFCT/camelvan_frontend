import 'package:cached_network_image/cached_network_image.dart';
import 'package:camelvan_frontend/view/registerPage.dart';
import 'package:camelvan_frontend/view/sellerLandingPage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:camelvan_frontend/view/sellerLandingPage.dart';
import 'package:camelvan_frontend/view/sellerMapPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'buyerLandingPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {


  @override
  void initState() {
    super.initState();
  }



  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Navigate the user to the Home page
                        try {
                          final credential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text);

                          FirebaseFirestore db = FirebaseFirestore.instance;

                          final docRef =
                              db.collection("users").doc(emailController.text);
                          final fcmToken =
                              await FirebaseMessaging.instance.getToken();
                          await FirebaseFunctions.instance
                              .httpsCallable('addToken')
                              .call({
                            "token": fcmToken,
                          });
                          docRef.get().then(
                            (DocumentSnapshot doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              if (data['type'] == 'buyer') {
                                Navigator.popUntil(
                                    context, ModalRoute.withName('/'));
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BuyerLandingPage()));
                              } else {
                                Navigator.popUntil(
                                    context, ModalRoute.withName('/'));
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SellerLandingPage()));
                              }
                            },
                            onError: (e) => print("Error getting document: $e"),
                          );
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            print('No user found for that email.');
                          } else if (e.code == 'wrong-password') {
                            print('Wrong password provided for that user.');
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill input')),
                        );
                      }
                    },
                    child: const Text('Sign in'),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()));
                    },
                    child: const Text('Register'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddMapDialog extends StatefulWidget {
  double lat = 0;
  double long = 0;

  AddMapDialog(double lat, double long) {
    this.lat = lat;
    this.long = long;
  }

  _AddRatingDialogState createState() => new _AddRatingDialogState();
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

class _AddRatingDialogState extends State<AddMapDialog> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
            child: AlertDialog(
      title: Text("New Route"),
      content: Container(
          child: Image.asset('assets/bbicon.png', fit: BoxFit.scaleDown)
      ),
      actions: <Widget>[
        Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {},
                child: Text('ok'),
              ),
              TextButton(
                onPressed: () {},
                child: Text('cancel'),
              ),
            ])
      ],
    )));
  }
}
