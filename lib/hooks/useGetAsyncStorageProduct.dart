import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class useGetAsyncStorageProduct with ChangeNotifier  {
  final storage = new FlutterSecureStorage();
  int productsCount = 0;

  getCar() async {
    Map<String, String> allValues = await storage.readAll();
    return allValues['car'];
  }

  Future<int> getNumberProducts() async {
    final storage = new FlutterSecureStorage();
    int temp = 0;
    Map<String, String> allValues = await storage.readAll();
//    print('carrito');
//    print(allValues['car']);
    if(allValues['car'] != null) {
      var aux = jsonDecode(allValues['car']);
      for(int x = 0; x < aux.length; x++){
        temp = temp + aux[x]['quantity'];
      }
    }
    productsCount = temp;
//    print('aaaaaaaaaa $productsCount');
    return temp;
  }

  addOrRemoveProductInAsyncStorage(type, id) async {
    var response = await getCar();
    var aux = response != null ? jsonDecode(response) : [];
    int numberProduct = await getNumberProducts();

//    print('entrooooooo $numberProduct');

    for (var i = 0; i < aux.length; ++i) {
      if(aux[i]['_id'] == id) {
        if(type == 'delete') {
          aux[i]['quantity'] = aux[i]['quantity'] - 1;

          productsCount = productsCount -1;
//          productsCount = numberProduct - 1;
          notifyListeners();
        }else{
          aux[i]['quantity'] = aux[i]['quantity'] + 1;
          productsCount = productsCount +1;
//          productsCount = numberProduct + 1;
//          print('despues d eto $productsCount');
          notifyListeners();
        }
      }
    }

    aux = aux.where((item) => item['quantity'] != 0).toList();
    await storage.write(key: 'car', value: jsonEncode(aux));
    notifyListeners();
  }

  Future<bool> validateElement(value) async {
    var response = await getCar();
    var cart = response != null ? jsonDecode(response) : [];
    for (var i = 0; i < cart.length; ++i) {
      if(cart[i]['_id'] == value['_id']) {
        return true;
      }
    }
    return false;
  }

  Future<bool> setCartInAsyncStorage(value) async {
    var response = await getCar();
    var cart = response != null ? jsonDecode(response) : [];
    int numberProduct = await getNumberProducts();
    try {
      if(cart.length == 0) {
        await storage.write(key: 'car', value: jsonEncode([value]));
        productsCount = 1;
        notifyListeners();
      }else {
        final elementIsInShoppingCart = await validateElement(value);

        if(elementIsInShoppingCart) {
          addOrRemoveProductInAsyncStorage('add', value['_id']);
          notifyListeners();
        }else {
          await storage.write(key: 'car', value: jsonEncode([...cart, value]));
          productsCount = productsCount + 1;
//          productsCount = numberProduct + 1;
          notifyListeners();
        }
      }

      notifyListeners();
      return true;
    }on Exception catch(e) {
      return false;
    }
  }

  deleteCart() async {
    await storage.write(key: 'car', value: jsonEncode([]));
    notifyListeners();
  }

  deleteElementCart(id) async {
    var response = await getCar();
    var cart = response != null ? jsonDecode(response) : [];
    var aux = cart.where((item) => item['_id'] != id).toList();
    await storage.write(key: 'car', value: jsonEncode(aux));
    notifyListeners();
  }

}