import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import './../hooks/useGetAsyncStorageProduct.dart';


class TopBar extends StatefulWidget {
  bool hideBackButton;
  String title;
  int numberOfProducts;
  dynamic notifications;

  @override
  _TopBarState createState() => _TopBarState();
  TopBar({
    Key key,
    this.hideBackButton = false,
    this.title = 'ROCKET',
    this.numberOfProducts = 0,
    this.notifications = 0
  }) : super(key: key);

}

class _TopBarState extends State<TopBar> {
  BuildContext get context => null;
  final hook = useGetAsyncStorageProduct();

  @override
  void initState() {
//    print('==============');
//    print(widget.notifications);
//    print(widget.notifications.length);
    this.numberProducts();
    super.initState();
  }


  numberProducts() async {
    int numberOfProductsInCart = await hook.getNumberProducts();
//    print('tobar $numberOfProductsInCart');
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<useGetAsyncStorageProduct>(

      builder: (context, viewModel, child) {
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(widget.title, style: TextStyle(color: Colors.black)),
//          leading: IconButton(
//            icon: Icon(Icons.exposure, color: Colors.black, size: 28),
//            onPressed: () => Scaffold.of(context).openDrawer(),
//          ),
          actions: <Widget>[

            widget.notifications.length > 0 ? IconButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('listNotifications', (Route<dynamic> route) => false);
              },
              padding: const EdgeInsets.symmetric(horizontal: 5),
              icon: Stack(
                children: <Widget>[
                  Icon(Icons.notifications, color: Colors.black, size: 28),
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        widget.notifications.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ) : Container(),

            viewModel.productsCount != 0 ?

            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('shoppingCart', (Route<dynamic> route) => false);
                },
                icon: Stack(
                  children: <Widget>[
                    Icon(Icons.shopping_cart, color: Colors.black, size: 28),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          viewModel.productsCount.toString(),
                          style: TextStyle(
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

          ],
        );
      },
    );
  }
}

