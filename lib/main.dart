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
import './containers/invoiceDetail/invoiceDetail.dart';
import './containers/example/example.dart';
import './containers/listNotifications/listNotifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final routes = <String, WidgetBuilder> {
//      'example': (BuildContext context) => MyExampleApp(),
      'login': (BuildContext context) => Login(),
      'home': (BuildContext context) => HomeScreen(),
      'detailScreen': (BuildContext context) => DetailsScreen(),
      'shoppingCart': (BuildContext context) => ShoppingCart(),
      'listInvoices': (BuildContext context) => ListInvoices(),
      'configuration': (BuildContext context) => Configuration(),
      'splashPage': (BuildContext context) => SplashPage(),
      'invoiceDetail': (BuildContext context) => InvoiceDetail(),
      'listNotifications': (BuildContext context) => ListNotifications(),
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
          primaryIconTheme: IconThemeData(color: Colors.black),
          textTheme: Theme.of(context).textTheme.apply(bodyColor: Color(0xFF535353)),
          visualDensity: VisualDensity.adaptivePlatformDensity,
//          iconTheme: IconThemeData(
//              color: Colors.red,
//          ),
        ),
        home: SplashPage(),
        routes: routes,
      ),
    );
  }
}