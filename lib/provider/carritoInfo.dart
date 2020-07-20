import 'package:flutter/material.dart';

class CarritoInfo with ChangeNotifier{
  dynamic _elemento = {};

  get elemento {
    return _elemento;
  }

  set elemento(dynamic info) {
    this._elemento = info;
    notifyListeners();
  }
}