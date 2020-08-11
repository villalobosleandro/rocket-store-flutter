import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './containers/home/home_screen.dart';
import './containers/login/login_screen.dart';
import './containers/splash/splash.dart';
import './containers/details/details_screen.dart';
import './containers/shoppingCart/shoppingCart.dart';
import './hooks/useGetAsyncStorageProduct.dart';
import './containers/listInvoices/listInvoices.dart';
import './containers/configuration/configuration.dart';

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
      'shoppingCart': (BuildContext context) => ShoppingCart(),
      'listInvoices': (BuildContext context) => ListInvoices(),
      'configuration': (BuildContext context) => Configuration(),
      'splashPage': (BuildContext context) => SplashPage()
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<useGetAsyncStorageProduct>(
          create: (_) => useGetAsyncStorageProduct(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rocket Store',
        theme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(bodyColor: Color(0xFF535353)),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashPage(),
        routes: routes,
      ),
    );
  }
}