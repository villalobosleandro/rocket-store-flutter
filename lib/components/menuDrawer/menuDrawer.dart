import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import './../../api/auth_api.dart';
import './../../utils/mColors.dart';

class MenuDrawer extends StatefulWidget {
  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  final _api = AuthApi();
  dynamic user;

  @override
  void initState() {
    this._getUserInfo();
    super.initState();
  }

  _getUserInfo() async {
    final token = await _api.getAccessToken();
    setState(() {
      user = token['userProfile'];
    });
  }

  _logOut() {
    Navigator.of(context).pushNamedAndRemoveUntil('login', (Route<dynamic> route) => false);
  }

  _exitApp() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Do you really want to exit the app?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () =>Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () async {
                final storage = new FlutterSecureStorage();
                await storage.deleteAll();
                Navigator.pop(context, true);
                _logOut();
              },
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(

      child: Column(
        children: <Widget>[
          Expanded(
              flex: 9,
              child: ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: redColor,
                    ),
                    accountName: Text(user['first_name'] + ' ' +user['last_name']),
                    accountEmail: Text(user['email']),
                    currentAccountPicture: FadeInImage(
                      fit: BoxFit.fill,
                      placeholder: AssetImage('assets/images/user.png'),
                      image: NetworkImage(user['avatar']),
                    )
                  ),

                  ListTile(
                    onTap: (){
                      Navigator.of(context).pushNamedAndRemoveUntil('home', (Route<dynamic> route) => false);
                    },
                    title: Text('Home'),
                    leading: Icon(Icons.home, size: 32.0, color: Colors.black)
                  ),

                  ListTile(
                    onTap: (){
                      Navigator.of(context).pushNamedAndRemoveUntil('listInvoices', (Route<dynamic> route) => false);
                    },
                    title: Text('Invoices'),
                    leading: Icon(Icons.receipt, size: 32.0, color: Colors.black)
                  ),

                  ListTile(
                    onTap: (){
                      Navigator.of(context).pushNamedAndRemoveUntil('listNotifications', (Route<dynamic> route) => false);
                    },
                    title: Text('List Notifications'),
                    leading: Icon(Icons.notifications, size: 32.0, color: Colors.black)
                  ),


                ],
              )
          ),

          Expanded(
            flex: 1,
            child: ListTile(
                onTap: (){
                  _exitApp();
                },
                title: Text('Logout'),
                leading: Icon(Icons.exit_to_app, size: 32.0, color: Colors.black)
            )
          )
        ],
      ),
    );
  }
}
