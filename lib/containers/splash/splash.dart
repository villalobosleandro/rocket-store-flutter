import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:meteorify/meteorify.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import './../../api/auth_api.dart';
import './../../utils/app_config.dart';
import './../../utils/globals.dart' as globals;

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _authApi = AuthApi();
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
//    this.connectionBackend();
    this.check();
  }

  connectionBackend() async {
    try{
      final response = await Meteor.connect(globals.url);

      if(response != null) {
        print('status = $response');
      }
    }catch(error){
      await storage.deleteAll();
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  check() async {
    final data = await _authApi.getAccessToken();
//    print('***************** session token $data');
    if(data != null) {
//      Navigator.pushReplacementNamed(context, 'home');
      Navigator.pushNamed(context, 'home');
    }else {
//      Navigator.pushReplacementNamed(context, 'login');
      Navigator.pushNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CupertinoActivityIndicator(radius: 15),
      ),
    );
  }
}
