import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late Future<List<Product>> productList;

  @override
  void initState() {
    super.initState();
    productList = getProducts();
  }

  Future<List<Product>> getProducts()  async {
    try {
      final result = await FirebaseFunctions.instance.httpsCallable('getAllNear').call(
          {
            "coordinates": [0,0]
          }
      );
      print(result.data.products[0]);
      return result.data.products as List<Product>;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final List<String> items = List<String>.generate(10000, (i) => 'Item $i');
    return Scaffold(
        appBar: AppBar(
            title: Text("Order")
        ),
        body: FutureBuilder<List<Product?>>(
          future: productList,
          builder: (context, snapshot) {
            if(snapshot.hasData){
              List<Product?> list = snapshot.data!;
              ListView.builder(
                  itemCount: items.length,
                  prototypeItem: Card(
                    child: ListTile(
                      title: Text(items.first),
                      subtitle: Text('Dist + Preço'),
                      leading: Image(image: AssetImage('assets/bbicon.png')),
                    ),
                  ),
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(items[index]),
                        subtitle: Text('Dist + Preço'),
                        leading: Image(image: AssetImage('assets/bbicon.png'))
                    );
                  }
              );
            }
            else {
              return const CircularProgressIndicator();
            }
            return Text("Fail");
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
