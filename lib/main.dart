import 'package:flutter/material.dart';

import './constants.dart';
import './containers/home/home_screen.dart';
import './containers/login/login_screen.dart';
import './containers/splash/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rocket Store',
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(bodyColor: kTextColor),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashPage(),
      routes: {
        "login": (context) => Login(),
        "home": (context) => HomeScreen()

      },
    );
  }
}