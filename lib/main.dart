import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meteorify/meteorify.dart';
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
import './utils/globals.dart' as globals;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    this.connectionBackend();
    super.initState();
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
          textTheme: Theme.of(context).textTheme.apply(bodyColor: Color(0xFF000000)),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor: Color(0xFFFF4122),
//          accentColor: Colors.orange,
//          hintColor: Colors.green
        ),
        home: SplashPage(),
        routes: routes,
      ),
    );
  }
}