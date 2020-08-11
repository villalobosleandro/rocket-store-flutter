
import 'package:flutter/material.dart';

import './../../utils/app_config.dart';
import './../../utils/globals.dart' as globals;

void main() => runApp(Configuration());

class Configuration extends StatefulWidget {
  @override
  _ConfigurationState createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  final url = TextEditingController(text: globals.devUrl);

  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }


  Widget _buildBody() {
    return Container(
      child: Column(
        children: <Widget>[

          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Column(
                children: <Widget>[


                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 40),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.none,
                        validator: (text) {
                          if (text.length == 0) {
                            return "URL field is required";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        controller: url,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(Icons.insert_link, size: 32.0, color: Colors.red),
                          border: InputBorder.none,
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 15.0),
                          contentPadding: const EdgeInsets.only( top: 20.0, right: 30.0, bottom: 20.0, left: 5.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  OutlineButton(
                      borderSide: BorderSide(color: Colors.red),
                      child: Text("Cancel", style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('login', (Route<dynamic> route) => false);
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))
                  ),

                  OutlineButton(
                      borderSide: BorderSide(color: Colors.green),
                      child: Text("Save", style: TextStyle(color: Colors.green),),
                      onPressed: () {
                        globals.url = url.text;
                        Navigator.of(context).pushNamedAndRemoveUntil('splashPage', (Route<dynamic> route) => false);
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );

  }
}


