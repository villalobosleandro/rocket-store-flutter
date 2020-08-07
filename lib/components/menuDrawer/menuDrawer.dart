import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MenuDrawer extends StatefulWidget {
  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {

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

        child: Container(
          decoration: BoxDecoration(
            border: Border(right: BorderSide(width: 2.0, color: Colors. black12)),
          ),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 9,
                child: Container(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('home', (Route<dynamic> route) => false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(width: 2.0, color: Colors.black12))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0, left: 18.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.home, size: 32.0, color: Colors.black45),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 18.0),
                                    child: Text('Home'),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () {
//                          Navigator.of(context).pushNamedAndRemoveUntil('MovementsHistory', (Route<dynamic> route) => false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 18.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(width: 2.0, color: Colors.black12))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0, left: 18.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.receipt, size: 32.0, color: Colors.black45),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 18.0),
                                    child: Text('Invoices'),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 1,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          _exitApp();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 18.0),
                          child: Container(

                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0, left: 18.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.exit_to_app, size: 32.0, color: Colors.black45),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 18.0),
                                    child: Text('Logout'),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )

                    ],
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}
