

import 'package:camelvan_frontend/view/clientPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class WaitingPage extends StatefulWidget {
  const WaitingPage({super.key});

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  @override
  Widget build(BuildContext context) {
    final orderIds = ModalRoute.of(context)!.settings.arguments as List<String>;
    final email = FirebaseAuth.instance.currentUser!.email;
    int verifed = 0;
    for (int i = 0; i < orderIds.length; i++) {
      DatabaseReference starCountRef =
      FirebaseDatabase.instance.ref('users/$email/order/$orderIds[i]');
      starCountRef.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value as Map;
        if(data['status'].equals() == 'accepted'){
          verifed++;
          print(verifed);
          if(verifed == orderIds.length){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ClientPage()));
          }
        }
      });
    }


    return const Scaffold(
       body: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Padding(
               padding: EdgeInsets.all(20.0),
               child: Center(child: Text('Searching for the nearest Kamel, please wait...')),
             ),
             CircularProgressIndicator(),
           ],
         ),
       ),
    );
  }
}
