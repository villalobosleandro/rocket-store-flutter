import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart' show required;
import 'package:flutter/services.dart';
import 'package:meteorify/meteorify.dart';

import './../utils/app_config.dart';
import './../utils/dialogs.dart';
import './../utils/session.dart';

class AuthApi {
  final _session = Session();

  Future<dynamic> getAccessToken() async {
    try {
      final result = await _session.get();
      //print('-------- $result ---------------');
      if(result != null) {
        return result;
      }
      return null;
    }on PlatformException catch(e) {
      print("Error ${e.code}:${e.message}");
    }
  }

  Future<bool> login(BuildContext context, {
    @required String username,
    @required String password}) async {

    var credentials = [{
      'user': {
        'email': username
      },
      'password': password
    }];

    try{
      final response = await Meteor.call(ApiRoutes.login, credentials);
      if(response != null) {
        final token = response['token'];
        final userId = response['userId'];
        await _session.set(token, userId);
        return true;
      }
      return false;
    }catch(error){
//      print('error => $error');
      Dialogs.alert(context, title: 'Error!', message: 'Sorry the email or password is invalid.');
      return false;
    }

  }

  Future callMethod(BuildContext context, String method, Object data) async {
//    print('method => $method');
//    print('data => $data');
    try{
      final response = await Meteor.call(method, data);
//      print('el response => $response');
      if(response != null) {
        return response;
      }
      return [];
    }on PlatformException catch(error){
//      print('el error => $error');
      return [];
    }

  }



}