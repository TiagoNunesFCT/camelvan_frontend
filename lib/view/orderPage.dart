import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';

import 'package:camelvan_frontend/view/waitingPage.dart';
import 'package:counter_button/counter_button.dart';
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
  int counterValue = 0;
  int counterPrice = 0;
  List<String> items = [];
  HashMap order = new HashMap<String, int>();
  HashMap prices = new HashMap<String, int>();

  callBack() {
    setState(() {
      items;
      order;
    });
  }

  @override
  void initState() {
    super.initState();
    productList = getProducts();
    counterValue = 0;
    counterPrice = 0;
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

  int getFinalPrice() {
    int finalPrice = 0;
    order.forEach((key, value) {
      print('value:' + value.toString() + ' price:' + prices[key].toString());
      finalPrice += (value as int) * (prices[key] as int);
    });
    return finalPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Order")
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<dynamic>(
                    future: productList,
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        dynamic list = snapshot.data!.data['products'];
                        for(var i = 0; i < list.length; i++){
                          var currentItem = list[i];
                          order.putIfAbsent(currentItem['name'], () => 0);
                          prices.putIfAbsent(currentItem['name'], () => (currentItem['price'] as int) );
                          print(prices[currentItem['name']]);
                        }
                        print(snapshot.data!.data['products'].toString());
                        return ListView.builder(
                            itemCount: list.length,
                            prototypeItem: Card(
                              child: ListTile(
                                title: Text(list.first['name']),
                                subtitle: Text('${list.first['price']/100}€ - ${list.first['minDistance']}m'),
                                leading: Image(image: AssetImage('assets/bbicon.png')),
                              ),
                            ),
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return Dialog.fullscreen(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(list[index]['name']),
                                                    const SizedBox(height: 15),
                                                    SizedBox(
                                                        height: 100,
                                                        width: 50,
                                                        child: Image.asset('assets/bbicon.png', fit: BoxFit.scaleDown)
                                                    ),
                                                    const SizedBox(height: 15),
                                                    CounterButton(
                                                      loading: false,
                                                      onChange: (int val) {
                                                        setState(() {
                                                          if(val > -1) {
                                                            order[list[index]['name']] = val;
                                                            counterValue = val;
                                                          }
                                                        });
                                                      },
                                                      count: order[list[index]['name']],
                                                      countColor: Colors.purple,
                                                      buttonColor: Colors.purpleAccent,
                                                      progressColor: Colors.purpleAccent,
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        if(counterValue >= 0) {
                                                          //order[list[index]['name']] = counterValue;
                                                          items.add(list[index]['name'] + ' x ' + counterValue.toString());
                                                          //counterPrice = counterPrice + counterValue * (list[index]['price'] as int) ;
                                                          print('PRICE:' + counterPrice.toString());
                                                        }
                                                        counterValue = 0;
                                                        callBack();
                                                        },
                                                      child: const Text('Save'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    title: Text(list[index]['name']),
                                    subtitle: Text('${list[index]['price']/100}€ - ${list[index]['minDistance']}m'),
                                    leading: Image(image: AssetImage('assets/bbicon.png'))
                                ),
                              );
                            }
                        );
                      }
                      else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
            ),
            const Text('Your order: ',
                style: TextStyle(fontSize: 25)),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: order.length,
                itemBuilder: (BuildContext context, int index) {
                  MapEntry<dynamic, dynamic> orderItem = order.entries.elementAt(index);
                    return Card(
                      child: Text('${orderItem.key} x ${orderItem.value}',
                      style: const TextStyle(fontSize: 25)),
                    );

               },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text('Total: ${getFinalPrice()/100}€',
                  style: const TextStyle(fontSize: 25)
              ),
            ),Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.all(16.0),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    List<String> orderIds = [];
                    order.forEach((key, value) async { if(value != 0) {
                      try{
                        final result = await FirebaseFunctions.instance.httpsCallable('broadcastRequest').call(
                            {
                              "coordinates": [0,0],
                              "request": {
                                "name": key,
                                "quantity": value
                              }
                            });
                        String _response = result.data['orderId'] as String;
                        print('ORDERID:' + _response);
                        orderIds.add(_response);

                      } on FirebaseFunctionsException catch (error) {
                        print(error.code);
                        print(error.details);
                        print(error.message);
                      }
                    }
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  WaitingPage(),
                      settings: RouteSettings(
                        arguments: orderIds,
                      ),));
                    });
                  },
                  child: const Text('Order')),
            ),],

        ),
    );
  }
}

class Product{
  late String name;
  late String price;
  late String minDistance;

  Product(this.name, this.price, this.minDistance);
}