import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Dialogs {
  static void alert(BuildContext context, {String title = '', String message = ''}) {
    showDialog(context: context, builder: (context){
      return CupertinoAlertDialog(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text(message, style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15)),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text('OK'),
          )
        ],
      );
    });
  }
}