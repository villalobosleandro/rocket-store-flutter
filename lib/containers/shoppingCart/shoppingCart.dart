import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import './../../components/topBar.dart';
import './../../components/menuDrawer/menuDrawer.dart';
import './../../hooks/useGetAsyncStorageProduct.dart';
import './../../api/auth_api.dart';
import './../../utils/app_config.dart';
import './../../utils/dialogs.dart';

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  int numberOfProductsInCart = 0, _radioValue1 = 0, totalAmountCount = 0, totalAmountCredit = 0;
  bool isFetching = true;
  useGetAsyncStorageProduct hook;
  var products = [];
  final _api = AuthApi();

  //contado 0, a credito 1

  @override
  void initState() {
    this.hook = Provider.of<useGetAsyncStorageProduct>(context, listen: false);
    super.initState();
    this.getNumberProducts();
  }

  getNumberProducts() async {
    numberOfProductsInCart = 0;
    totalAmountCount = 0;
    totalAmountCredit = 0;

    await hook.getCar();
    final storage = FlutterSecureStorage();
    Map<String, String> allValues = await storage.readAll();
    if(allValues['car'] != null) {
      var aux = jsonDecode(allValues['car']);
      products = jsonDecode(allValues['car']);
      for(int x = 0; x < aux.length; x++){
        numberOfProductsInCart = numberOfProductsInCart + aux[x]['quantity'];
        totalAmountCount = totalAmountCount + aux[x]['price'] * aux[x]['quantity'];
        totalAmountCredit = totalAmountCredit + aux[x]['priceOnCredit'] * aux[x]['quantity'] * aux[x]['numberOfFees'];
      }
    }
    setState(() {
      isFetching = false;
    });
  }

  _addOrRemoveElement(type, id) async {
    hook.addOrRemoveProductInAsyncStorage(type, id);
    this.getNumberProducts();

  }

  void _handleRadioValueChange1(int value) {
    setState(() {
      _radioValue1 = value;
    });
  }

  _modalConfirm(context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Are you sure to proceed with the purchase?'),

          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(
                  color: Colors.red
                )
              ),
              shape: RoundedRectangleBorder(side: BorderSide(
                  color: Colors.red,
                  width: 1,
                  style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(5)),
            ),

            FlatButton(
              onPressed: () {
                this._payment();
                Navigator.of(context).pop();
              },
              child: Text('Save', style: TextStyle(
                  color: Colors.green
                )
              ),
              shape: RoundedRectangleBorder(side: BorderSide(
                  color: Colors.green,
                  width: 1,
                  style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(5)),
            )
          ],
        )
    );
  }

  _payment() async {
    print('entro');
    setState(() {
      isFetching = true;
    });

    try {
      final token = await _api.getAccessToken();
      dynamic arreglo = await hook.getCar();
      dynamic car = jsonDecode(arreglo), orders = {};
      var query = [{
        'extraData': token['token']
      }];
      final profile = await _api.callMethod(context, ApiRoutes.profileGet, query);
      if(profile.length > 0) {
        for (var i = 0; i < car.length; ++i) {
          dynamic temp = {
            'productId': car[i]['_id'],
            'item': car[i]['name'],
            'price': car[i]['price'],
            'priceOnCredit': car[i]['priceOnCredit'],
            'qty': car[i]['quantity'],
            'img': car[i]['img'],
            'numberOfFees': car[i]['numberOfFees'],
          };
          orders[car[i]['_id']] = temp;
        }

        dynamic data = [{
          'amount': _radioValue1 == 0 ? totalAmountCount : totalAmountCredit,
          'order_by': profile['id'],
          'order_by_id': profile['id'],
          'method': _radioValue1 == 0 ? 'contado' : 'credito',
          'to_go': false,
          'fee': 'N/A',
          'fee_type': 'IPC',
          'fee_amount': null,
          'userId': profile['id'],
          'orders': orders,
          'from': 'android-store',
          'totalItems': numberOfProductsInCart,
          'extraData': token['token']
        }];

        final res = await _api.callMethod(context, ApiRoutes.storeInsert, data);
        if(res.length != 0) {
          hook.deleteCart();
          FlutterToast.showToast(
              msg: 'order successfully generated'.toUpperCase(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.of(context).pushNamedAndRemoveUntil('listInvoices', (Route<dynamic> route) => false);
        }
      }

    } on PlatformException catch(e) {
      setState(() {
        isFetching = false;
      });
      Dialogs.alert(context, title: 'Error', message: 'Error try again');
    }
  }

  _confirmDeleteCart(context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Are you sure to remove all products from the cart?'),

          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(
                  color: Colors.red
              )
              ),
              shape: RoundedRectangleBorder(side: BorderSide(
                  color: Colors.red,
                  width: 1,
                  style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(5)),
            ),

            FlatButton(
              onPressed: () {
                hook.deleteCart();
                this.getNumberProducts();
                Navigator.of(context).pop();
              },
              child: Text('Save', style: TextStyle(
                  color: Colors.green
              )
              ),
              shape: RoundedRectangleBorder(side: BorderSide(
                  color: Colors.green,
                  width: 1,
                  style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(5)),
            )
          ],
        )
    );

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
      drawer: MenuDrawer(),
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
        child: Text('The cart is empty'),
      );
    }else {
      final size = MediaQuery.of(context).size;
      return Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: IconButton(
                        iconSize: 50,
                        onPressed: () {
                          this._confirmDeleteCart(context);
                        },
                        icon: Icon(Icons.delete_outline, color: Colors.black),
                      ),
                    ),

                    Text('My Cart ($numberOfProductsInCart)', style: TextStyle(fontSize: 20)),
                  ],
                ),

                Row(
                  children: <Widget>[
                    Radio(
                      activeColor: Colors.red,
                      value: 0,
                      groupValue: _radioValue1,
                      onChanged: _handleRadioValueChange1,
                    ),
                    Text(
                      'Count',
                      style: TextStyle(fontSize: 16.0),
                    ),

                    Radio(
                      activeColor: Colors.red,
                      value: 1,
                      groupValue: _radioValue1,
                      onChanged: _handleRadioValueChange1,
                    ),
                    Text(
                      'Credit',
                      style: TextStyle(fontSize: 16.0),
                    ),

                  ],
                )
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
//                      print('=============');
//                      print(products);
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
                                        child: FadeInImage(
                                          fit: BoxFit.cover,
                                          placeholder: AssetImage('assets/images/loading.gif'),
                                          image: NetworkImage(products[index]['img']),
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
                                      flex: _radioValue1 == 0 ? 9 : 7,
                                      fit: FlexFit.tight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              flex: 1,
                                              fit: FlexFit.tight,
                                              child: Text(products[index]['name'], style: TextStyle(fontWeight: FontWeight.bold),)
                                            ),
                                            Flexible(
                                              flex: 1,
                                              fit: FlexFit.tight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(_radioValue1 == 0 ? products[index]['price'].toString() : products[index]['priceOnCredit'].toString()),
                                              )
                                            ),
                                            Flexible(
                                                flex: 2,
                                                fit: FlexFit.tight,
                                                child: Row(
                                                  children: <Widget>[
                                                    ClipOval(
                                                      child: Material(
                                                        color: Colors.red, // button color
                                                        child: InkWell(
//                                                          splashColor: Colors.red, // inkwell color
                                                          child: SizedBox(
                                                              width: 40,
                                                              height: 40,
                                                              child: Icon(Icons.keyboard_arrow_down, color: Colors.white,)),
                                                          onTap: () {
                                                            this._addOrRemoveElement('delete', products[index]['_id']);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: Text(products[index]['quantity'].toString(), style: TextStyle(fontSize: 20),),
                                                    ),
                                                    ClipOval(
                                                      child: Material(
                                                        color: Colors.red, // button color
                                                        child: InkWell(
//                                                          splashColor: Colors.red, // inkwell color
                                                          child: SizedBox(
                                                              width: 40,
                                                              height: 40,
                                                              child: Icon(Icons.keyboard_arrow_up, color: Colors.white,)),
                                                          onTap: () {
                                                            this._addOrRemoveElement('add', products[index]['_id']);

                                                          },
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                            )
                                          ],
                                        ),
                                      ),
                                    ),

                                    _radioValue1 == 1 ? Flexible(
                                      flex: 2,
                                      fit: FlexFit.tight,
                                      child: Text('X ' + products[index]['numberOfFees'].toString(), style: TextStyle(fontSize: 18),),
                                    ) : Container(),

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
                                            onTap: (){
                                              hook.deleteElementCart(products[index]['_id'], products[index]['quantity']);
                                              this.getNumberProducts();
                                            },
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.green)),
                    onPressed: () {
                      this._modalConfirm(context);
                    },
                    color: Colors.green,
                    textColor: Colors.white,

                    child: Container(
                      width: 80,
                      height: 40,
                      alignment: Alignment(0, 0),
                      child: Text("Buy now".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                    ),
                  ),

                  Text(_radioValue1 == 0 ?
                    '\$  ' + totalAmountCount.toString() :
                    '\$  ' + totalAmountCredit.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  )

                ],
              ),
            ),
          )
        ],
      );
    }
  }
}
