import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'orderPage.dart';

class BuyerLandingPage extends StatefulWidget {
  const BuyerLandingPage({Key? key}) : super(key: key);

  @override
  State<BuyerLandingPage> createState() => _BuyerLandingPageState();
}

class _BuyerLandingPageState extends State<BuyerLandingPage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('HomePage')
      ),
      body: Center(
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderPage()));
            },
            child: SizedBox(
              height: 250,
              width: 150,
              child: DropShadow(
                  blurRadius: 10,
                  offset: const Offset(3, 3),
                  spread: 1,
                  child: Image.asset('assets/bbicon.png', fit: BoxFit.scaleDown)
              ),
            ),
          )
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_rounded),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_sharp),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}