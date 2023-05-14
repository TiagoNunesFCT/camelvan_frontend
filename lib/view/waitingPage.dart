import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WaitingPage extends StatefulWidget {
  const WaitingPage({Key? key}) : super(key: key);

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  @override
  Widget build(BuildContext context) {
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
