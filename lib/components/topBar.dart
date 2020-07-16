import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './../hooks/useGetAsyncStorageProduct.dart';

class TopBar extends StatefulWidget {
  bool hideBackButton;
  String routeName;
  String title;
  int number;

  @override
  _TopBarState createState() => _TopBarState();
  TopBar({Key key,
    this.hideBackButton = false,
    this.routeName = 'home',
    this.title = 'DASHBOARD',
    this.number = 0
  }) : super(key: key);
}

class _TopBarState extends State<TopBar> {

//  @override
//  void initState() {
//    super.initState();
////    this.getNumberProducts();
//  }



  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(widget.title, style: TextStyle(color: Colors.black)),
      leading: widget.hideBackButton == false ? IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.redAccent),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(widget.routeName, (Route<dynamic> route) => false);
        },
      ) : null,
      actions: <Widget>[
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
                    widget.number.toString(),
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
        )
      ],
    );

//    if(widget.hideBackButton == true) {
//      return AppBar(
//        backgroundColor: Colors.white,
//        elevation: 0,
//        title: Text(widget.title, style: TextStyle(color: Colors.black)),
//        leading: widget.hideBackButton != false ? IconButton(
//          icon: Icon(Icons.arrow_back, color: Colors.redAccent),
//          onPressed: () {
//            Navigator.of(context).pushNamedAndRemoveUntil(widget.routeName, (Route<dynamic> route) => false);
//          },
//        ) : null,
//      );
//    }else {
//      print('entro al else');
//      return AppBar(
//        backgroundColor: Colors.white,
//        elevation: 0,
//        title: Text(widget.title, style: TextStyle(color: Colors.black)),
//        leading: this.backButton(),
////        actions: <Widget>[
////          IconButton(
////            icon: Icon(Icons.access_alarm),
////            onPressed: () {
////              Navigator.of(context).pushNamedAndRemoveUntil('home', (Route<dynamic> route) => false);
////            },
////          ),
////          IconButton(
////            icon: Icon(Icons.search),
////            onPressed: () {
////              print('click');
////            },
////          )
////        ],
//      );
//    }
  }
}
