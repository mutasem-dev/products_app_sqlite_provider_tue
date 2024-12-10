import 'dart:io';
import 'package:flutter/material.dart';
import 'package:products_db/database_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'product.dart';

Future main() async {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  databaseFactory = databaseFactoryFfi;
  runApp(const MyAppo());
}

class MyAppo extends StatelessWidget {
  const MyAppo({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DatabaseProvider.instance,
      builder: (context, child) {
        return MaterialApp(
          home: ProductsPage(),
        );
      },
    );
  }
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    // TODO: implement initState
    DatabaseProvider.instance
        .add(Product(name: 'p1', quantity: 10, price: 20.5));
    DatabaseProvider.instance
        .add(Product(name: 'p2', quantity: 20, price: 30.5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products app'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Products: ',
                style: TextStyle(fontSize: 25),
              ),
              ElevatedButton(onPressed: () {}, child: Text('add product')),
            ],
          ),
          Consumer<DatabaseProvider>(
            builder: (context, value, child) {
              return FutureBuilder<List<Product>>(
                future: DatabaseProvider.instance.getAllProduct(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Product> products = snapshot.data!;
                    if (products.isEmpty) {
                      return Text(
                        'no products found',
                        style: TextStyle(fontSize: 25),
                      );
                    } else {
                      return Expanded(
                          child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              tileColor: Colors.blue,
                              leading: Text(products[index].name),
                              title:
                                  Text('quantity: ${products[index].quantity}'),
                              subtitle: Text('price: ${products[index].price}'),
                              trailing: IconButton(
                                  onPressed: () {
                                    DatabaseProvider.instance
                                        .delete(products[index].id!);
                                  },
                                  icon: Icon(Icons.delete)),
                            ),
                          );
                        },
                      ));
                    }
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else
                    return CircularProgressIndicator();
                },
              );
            },
          )
          // Expanded(child: ListView.builder(itemBuilder: (context, index) {

          // },
          // )
          // ),
        ],
      ),
    );
  }
}
