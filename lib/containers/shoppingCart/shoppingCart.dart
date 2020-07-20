import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import './../../components/topBar.dart';

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  int numberOfProductsInCart = 0;
  var products = [];
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    this.getNumberProducts();
  }

  getNumberProducts() async {
    final storage = new FlutterSecureStorage();
    Map<String, String> allValues = await storage.readAll();
    if(allValues['car'] != null) {
      var aux = jsonDecode(allValues['car']);
      products = jsonDecode(allValues['car']);
      for(int x = 0; x < aux.length; x++){
        numberOfProductsInCart = numberOfProductsInCart + aux[x]['quantity'];
      }
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
//          title: 'CART',
//          routeName: 'home',
//          number: numberOfProductsInCart,
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
            flex: 1,
            fit: FlexFit.tight,
            child: Row(
              children: <Widget>[
                Container(
                  child: IconButton(
                    iconSize: 50,
                    onPressed: () {
                      print('borrar todo');
                    },
                    icon: Icon(Icons.delete_outline, color: Colors.black),
                  ),
                ),

                Text('My Cart' + '(3)', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),

          Flexible(
            flex: 7,
            fit: FlexFit.tight,
            child: Container(
                width: size.width,
                child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1
                            ),
                            borderRadius: BorderRadius.all(
                                Radius.circular(5.0)
                            ),
                          ),
                          height: 150,
                          child: Row(
                            children: <Widget>[

                              Flexible(
                                flex: 3,
                                fit: FlexFit.tight,
                                child: Container(
                                  height: 150,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image.network(
                                      'https://img.freepik.com/free-vector/immune-system-concept_52683-40510.jpg?size=338&ext=jpg',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),

                              Flexible(
                                flex: 7,
                                fit: FlexFit.tight,
                                child: Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 9,
                                      fit: FlexFit.tight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Text('titulo')
                                          ),
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Text('precio')
                                          ),
                                          Flexible(
                                              flex: 2,
                                              fit: FlexFit.tight,
                                              child: Text('botones')
                                          )
                                        ],
                                      ),
                                    ),

                                    Flexible(
                                      flex: 1,
                                      fit: FlexFit.tight,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          InkWell(
                                            child: Icon(
                                                Icons.close,
                                                size: 28
                                            ),
                                            onTap: (){print('borrar elemento $index');},
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ),

                            ],
                          ),
                        ),
                      );
                    }
                )
            ),
          ),

          Flexible(
            flex: 1,
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
