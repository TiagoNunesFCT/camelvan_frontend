import 'dart:js';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WaitingPage extends StatelessWidget {
  const WaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderIds = ModalRoute.of(context)!.settings.arguments as List<String>;
    return Scaffold(
       body: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             const Padding(
               padding: EdgeInsets.all(20.0),
               child: Center(child: Text('Searching for the nearest Kamel, please wait...')),
             ),
             CircularProgressIndicator(),
             Text(orderIds[0])
           ],
         ),
       ),
    );
  }
}
