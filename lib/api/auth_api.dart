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
      Dialogs.alert(context, title: 'Error!', message: 'Sorry the email or password is invalid.');
      return false;
    }

  }

  Future callMethod(BuildContext context, String method, {Object data}) async {
    final token = await getAccessToken();
    data = [{
      'options': {},
      'extraData': token['token']
    }];
    try{
      final response = await Meteor.call(method, data);
      //print('aaaaaaaaaaaaaaa');
      //print(response['data']['products']);
      if(response != null) {
        return response['data']['products'];
      }
      return [];
    }catch(error){
      return [];
    }

  }



}