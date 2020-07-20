import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rocket_store_flutter/utils/dialogs.dart';

import './../../components/Product.dart';
import './../../components/item_card.dart';
import './../details/details_screen.dart';
import './../../utils/app_config.dart';
import './../../api/auth_api.dart';
import './../../components/topBar.dart';
import './../../hooks/useGetAsyncStorageProduct.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFetching = true;
  final _api = AuthApi();
  final hook = useGetAsyncStorageProduct();
  List<dynamic> itemProducts = List<Product>();
  int numberOfProductsInCart = 0;

  @override
  void initState() {
    super.initState();
    this._getProducts();
//    this.getNumberProducts();
  }

//  getNumberProducts() async {
//    final storage = new FlutterSecureStorage();
//    Map<String, String> allValues = await storage.readAll();
//    print('carrito');
//    print(allValues['car']);
//    if(allValues['car'] != null) {
//      var aux = jsonDecode(allValues['car']);
//      for(int x = 0; x < aux.length; x++){
//        numberOfProductsInCart = numberOfProductsInCart + aux[x]['quantity'];
//      }
//    }
//
//    print('++++++++++++++++');
//    print(numberOfProductsInCart);
//  }

  _getProducts() async {
    try {
      final products = await _api.callMethod(context, ApiRoutes.productsList);
      if(products != []) {
        setState(() {
          itemProducts = products;
          isFetching = false;
        });
      }
      setState(() {
        isFetching = false;
      });
    } on PlatformException catch(e) {
      setState(() {
        isFetching = false;
      });
      Dialogs.alert(context, title: 'Error', message: 'Conection error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: TopBar(
//          hideBackButton: true,
//          number: numberOfProductsInCart,
        ),
      ),
      body: isFetching ? Container(
        child: Center(
          child: CupertinoActivityIndicator(radius: 15),
        ),
      ) : _buildBody(),
    );
  }

  Widget _buildBody() {
    if(itemProducts.length > 0) {
      return Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                  itemCount: itemProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) => ItemCard(
                    product: itemProducts[index],
                    press: () {
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (context) => DetailsScreen(
                              product : itemProducts[index])),
                              (route) => false
                      );
                    },
                  )),
            ),
          ),
        ],
      );
    }else {
      return Center(
        child: Text('No hay productos'),
      );
    }
  }
}
