import 'package:flutter/material.dart';

import './constants.dart';
import './containers/home/home_screen.dart';
import './containers/login/login_screen.dart';
import './containers/splash/splash.dart';
import './containers/details/details_screen.dart';
import './containers/shoppingCart/shoppingCart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final routes = <String, WidgetBuilder> {
      'login': (BuildContext context) => Login(),
      'home': (BuildContext context) => HomeScreen(),
      'detailScreen': (BuildContext context) => DetailsScreen(),
      'shoppingCart': (BuildContext context) => ShoppingCart()
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rocket Store',
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(bodyColor: kTextColor),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashPage(),
      routes: routes,
    );
  }
}