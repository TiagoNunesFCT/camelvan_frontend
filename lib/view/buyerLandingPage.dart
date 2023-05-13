import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BuyerLandingPage extends StatefulWidget {
  const BuyerLandingPage({Key? key}) : super(key: key);

  @override
  State<BuyerLandingPage> createState() => _BuyerLandingPageState();
}

class _BuyerLandingPageState extends State<BuyerLandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('')
        ),
        body: Center(
            child: Container(
                child: Image.asset('assets/bbicon.png', fit: BoxFit.scaleDown)
            )
        )
    );
  }
}