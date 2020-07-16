import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import './../api/auth_api.dart';

class useGetAsyncStorageProduct {
  final _authApi = AuthApi();
  final storage = new FlutterSecureStorage();
//  final cart = await _authApi.getAccessToken();



//  Future getNumberOfProduct() async {
//    final storage = new FlutterSecureStorage();
//    var numberOfProductsInCart = 0;
//    Map<String, String> allValues = await storage.readAll();
//    var aux = jsonDecode(allValues['car']);
//    for(int x = 0; x < aux.length; x++){
//      numberOfProductsInCart = numberOfProductsInCart + aux[x]['quantity'];
//    }
//    return numberOfProductsInCart;
//  }

  getCar() async {
    Map<String, String> allValues = await storage.readAll();
    return allValues['car'];
  }

  addOrRemoveProductInAsyncStorage(type, id) async {
    var response = await getCar();
    var aux = response != null ? jsonDecode(response) : [];

    for (var i = 0; i < aux.length; ++i) {
      if(aux[i]['_id'] == id) {
        if(type == 'delete') {
          aux[i]['quantity'] = aux[i]['quantity'] - 1;
        }else{
          aux[i]['quantity'] = aux[i]['quantity'] + 1;
        }
      }
    }

    aux = aux.where((item) => item['quantity'] != 0).toList();
    await storage.write(key: 'car', value: jsonEncode(aux));
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
    try {
      if(cart.length == 0) {
        await storage.write(key: 'car', value: jsonEncode([value]));
      }else {
        final elementIsInShoppingCart = await validateElement(value);

        if(elementIsInShoppingCart) {
          addOrRemoveProductInAsyncStorage('add', value['_id']);
        }else {
          await storage.write(key: 'car', value: jsonEncode([...cart, value]));
        }
      }
      return true;
    }catch(e) {
      return false;
    }
  }

  deleteCart() async {
    await storage.write(key: 'car', value: jsonEncode([]));
  }

  deleteElementCart(id) async {
    var response = await getCar();
    var cart = response != null ? jsonDecode(response) : [];
    var aux = cart.where((item) => item['_id'] != id).toList();
    await storage.write(key: 'car', value: jsonEncode(aux));
  }


}