import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import './../hooks/useGetAsyncStorageProduct.dart';


class TopBar extends StatefulWidget {
  bool hideBackButton;
  String title;
  int numberOfProducts;

  @override
  _TopBarState createState() => _TopBarState();
  TopBar({
    Key key,
    this.hideBackButton = false,
    this.title = 'ROCKET',
    this.numberOfProducts = 0
  }) : super(key: key);

}

class _TopBarState extends State<TopBar> {
  BuildContext get context => null;
  final hook = useGetAsyncStorageProduct();

  @override
  void initState() {
    this.numberProducts();
    super.initState();
  }


  numberProducts() async {
    int numberOfProductsInCart = await hook.getNumberProducts();
//    print('tobar $numberOfProductsInCart');
  }

  _logOut() {
    Navigator.of(context).pushNamedAndRemoveUntil('login', (Route<dynamic> route) => false);
  }

  _exitApp() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Do you really want to exit the app?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () =>Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () async {
                final storage = new FlutterSecureStorage();
                await storage.delete(key: 'SESSION');
                Navigator.pop(context, true);
                _logOut();
              },
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<useGetAsyncStorageProduct>(

      builder: (context, viewModel, child) {
//        print('*************');
//        print(widget.numberOfProducts);
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(widget.title, style: TextStyle(color: Colors.black)),
          leading: IconButton(
            icon: Icon(Icons.menu, color: Colors.black, size: 28,),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          actions: <Widget>[
            widget.numberOfProducts != 0 ?
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('shoppingCart', (Route<dynamic> route) => false);
                },
                icon: new Stack(
                  children: <Widget>[
                    new Icon(Icons.shopping_cart, color: Colors.black, size: 28),
                    new Positioned(
                      right: 0,
                      child: new Container(
                        padding: EdgeInsets.all(1),
                        decoration: new BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: new Text(
                          widget.numberOfProducts.toString(),
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                )
            ) : Container(),

//            IconButton(
//              onPressed: () {
//                _exitApp();
//              },
//
//              icon: Icon(Icons.exit_to_app, color: Colors.black, size: 28),
//            )
          ],
        );
      },
    );
  }
}

