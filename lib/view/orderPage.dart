import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late Future<dynamic> productList;

  @override
  void initState() {
    super.initState();
    productList = getProducts();
  }

  Future<dynamic> getProducts()  async {
    try {
      final result =  FirebaseFunctions.instance.httpsCallable('getAllNear').call(
          {
            "coordinates": [0,0]
          });

      return result;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Order")
        ),
        body: FutureBuilder<dynamic>(
          future: productList,
          builder: (context, snapshot) {
            if(snapshot.hasData){
              dynamic list = snapshot.data!.data['products'];
              return ListView.builder(
                  itemCount: list.length,
                  prototypeItem: Card(
                    child: ListTile(
                      title: Text(list.first['name']),
                      subtitle: Text('${list.first['price']/100}% - ${list.first['minDistance']}m'),
                      leading: Image(image: AssetImage('assets/bbicon.png')),
                    ),
                  ),
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(list[index]['name']),
                        subtitle: Text('${list[index]['price']/100}% - ${list[index]['minDistance']}m'),
                        leading: Image(image: AssetImage('assets/bbicon.png'))
                    );
                  }
              );
            }
            else {
              return const CircularProgressIndicator();
            }
          },
        )
    );
  }
}

class Product{
  late String name;
  late String price;
  late String minDistance;

  Product(this.name, this.price, this.minDistance);
}
