import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import './../api/auth_api.dart';

class useGetAsyncStorageProduct {
  final _authApi = AuthApi();
  final storage = new FlutterSecureStorage();
//  final cart = await _authApi.getAccessToken();



  Future getNumberOfProduct() async {

  }

  Future getCar() async {
    Map<String, String> allValues = await storage.readAll();
    return allValues['car'];
  }

  addOrRemoveProductInAsyncStorage(type, id) async {
    var response = await getCar();
    var aux = response != null ? jsonDecode(response) : [];

    for (var i = 0; i < aux.length; ++i) {
      if(aux[i]['_id'] == id) {
        if(type == 'delete') {
          aux[i]['quantity']--;
        }else{
          aux[i]['quantity']++;
        }
      }
    }

    aux = [aux.where((item) => item['quantity'] != 0)];
    print('aux $aux');
//    print(jsonEncode([aux]));
//    await storage.write(key: 'car', value: jsonEncode([aux]));
//    return false;
  }

  Future<bool> validateElement(value) async {
    var response = await getCar();
    var cart = response != null ? jsonDecode(response) : [];
    for (var i = 0; i < cart.length; ++i) {
      if(cart[i]['_id'] == value['_id']) {
        print('3333333333');
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
        print('11111111');
        await storage.write(key: 'car', value: jsonEncode([value]));
      }else {
        print('2222222222222');
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


}