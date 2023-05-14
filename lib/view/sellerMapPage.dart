import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

class SellerMapPage extends StatefulWidget {
  const SellerMapPage({Key? key}) : super(key: key);

  @override
  State<SellerMapPage> createState() => _SellerMapPageState();
}

class _SellerMapPageState extends State<SellerMapPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}