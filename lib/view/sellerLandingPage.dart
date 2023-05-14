import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:counter_button/counter_button.dart';
import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SellerLandingPage extends StatefulWidget {
  const SellerLandingPage({Key? key}) : super(key: key);

  @override
  State<SellerLandingPage> createState() => _SellerLandingPageState();
}

class _SellerLandingPageState extends State<SellerLandingPage> {
  late Future<dynamic> productList;
  int counterValue = 0;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<int> quantityList = [];

  @override
  void initState() {
    super.initState();
    productList = getProducts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('DraggableScrollableSheet'),
        ),
        //future builder for DraggableScrollableSheet
        body: FutureBuilder<dynamic>(
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
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
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
                              ));
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
        ));

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
