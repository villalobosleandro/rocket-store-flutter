import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './../hooks/useGetAsyncStorageProduct.dart';

class TopBar extends StatefulWidget {
  bool hideBackButton;
  String routeName;
  String title;

  @override
  _TopBarState createState() => _TopBarState();
  TopBar({Key key, this.hideBackButton = false, this.routeName = 'home', this.title = 'DASHBOARD'}) : super(key: key);
}

class _TopBarState extends State<TopBar> {

//  Widget backButton() {
//    print('el boton ');
//    print(widget.hideBackButton);
//
//    if(widget.hideBackButton == false) {
//      print('entro al if');
//      return IconButton(
//        icon: Icon(Icons.arrow_back, color: Colors.redAccent),
//        onPressed: () {
//          Navigator.of(context).pushNamedAndRemoveUntil(widget.routeName, (Route<dynamic> route) => false);
//        },
//      );
//    }else {
//      return null;
//    }
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
