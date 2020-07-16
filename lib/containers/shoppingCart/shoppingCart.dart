import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import './../../components/topBar.dart';

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  int numberOfProductsInCart = 0;
  var products;
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    this.getNumberProducts();
  }

  getNumberProducts() async {
    final storage = new FlutterSecureStorage();
    Map<String, String> allValues = await storage.readAll();
    var aux = jsonDecode(allValues['car']);
    products = jsonDecode(allValues['car']);
    print('products');
    print(products);
    print(products.length);
    for(int x = 0; x < aux.length; x++){
      numberOfProductsInCart = numberOfProductsInCart + aux[x]['quantity'];
    }
    setState(() {
      isFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: TopBar(
          title: 'CART',
          routeName: 'home',
          number: numberOfProductsInCart,
        ),
      ),
      body: isFetching ? Container(
      child: Center(
        child: CupertinoActivityIndicator(radius: 15),
      ),
    ) : _buildBody()
    );
  }

  Widget _buildBody() {
    if(products.length == 0) {
      return Center(
        child: Text('No hay productos'),
      );
    }else {
      final size = MediaQuery.of(context).size;
      return Column(
        children: <Widget>[
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Row(
              children: <Widget>[
                Container(
                  child: IconButton(
                    iconSize: 70,
                    onPressed: () {
                      print('borrar todo');
                    },
                    icon: Icon(Icons.delete_outline, color: Colors.black),
                  ),
                ),

                Text('My Cart' + '(3)', style: TextStyle(fontSize: 30)),
              ],
            ),
          ),

          Flexible(
            flex: 6,
            fit: FlexFit.tight,
            child: Container(
                width: size.width,
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 50,
                        child: Center(child: Text('Entry')),
                      );
                    }
                )
            ),
          ),

          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Container(
              width: size.width,
              color: Colors.deepPurpleAccent,
              child: Text('aqui va el precio y boton de pagar'),
            ),
          )
        ],
      );
    }
  }
}
