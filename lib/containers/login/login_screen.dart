import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './../../api/auth_api.dart';
import './../../utils/dialogs.dart';
import './../../utils/app_config.dart';
import './../../utils/globals.dart' as globals;
import '../../utils/responsive.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  RegExp emailRegExp = RegExp(r'^\w+[\w-\.]*\@\w+((-\w+)|(\w*))\.[a-z]{2,3}$');
  final _formKey = GlobalKey<FormState>();
  var _email = '', _password = '';
  bool formValid = false;
  bool isFetching = false;
  bool isEnabled = true;
  final _authAPI = AuthApi();

  _login() async {
//    print('-------------------------------------');
//    print(globals.url);
    if(isFetching) return;
    if(formValid) {
      setState(() {
        isFetching = true;
      });
      try {
        final isOk = await _authAPI.login(context, username: _email, password: _password);
        if(isOk == true) {
          setState(() {
            isFetching = false;
          });
          Navigator.pushNamed(context, 'home');
        }else{
          setState(() {
            isFetching = false;
            isEnabled = true;
          });
        }
      }on PlatformException catch(e) {
        setState(() {
          isFetching = false;
          isEnabled = true;
        });
      }
    }else {
      setState(() {
        isFetching = false;
        isEnabled = true;
      });
      Dialogs.alert(context, title: 'Error', message: 'Re-enter data');
    }
  }

  _validateForm() {
    if(_email.length > 0 && _password.length > 0) {
      return '';
    }else {
      if(_password.length == 0 && _email.length > 0) {
        //el campo de clave esta vacio
        return 'Password is empty';
      }
      else if(_email.length == 0 && _password.length > 0) {
        //el campo email esta vacio
        return 'Email is empty';
      }else {
        return 'All fields empty';
      }
    }
  }

  _toogle () {
    setState(() {
      isEnabled = false;
    });
    final isValid = _validateForm();
    if(isValid != '') {
      setState(() {
        isEnabled = true;
      });
      FlutterToast.showToast(
          msg: isValid,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }else{
      setState(() {
        formValid = true;
      });
      _login();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final responsive = Responsive(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/rockstoreloginWhite.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Container(
                  width: size.width,
                  height: size.height,
                  child: SafeArea(
                    child: Column(
                      children: <Widget>[

                        Text('ROCKET',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: responsive.ip(7),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'RobotoSlab Bold'
                          ),
                        ),

                        Text('store',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: responsive.ip(4),
                              color: Colors.black,
                              fontFamily: 'RobotoSlab Light'
                          ),
                        ),

                        SizedBox(height: responsive.hp(32)),

//                        SizedBox(height: responsive.hp(12)),

                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: size.width,
                              minWidth: size.width
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: size.width - 30,
                                  child: TextFormField(
                                    textCapitalization: TextCapitalization.none,
                                    onChanged: (value) => _email = value,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.black38,
                                      hintText: 'Email',
                                      border: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(5)
                                      ),
                                      hintStyle: const TextStyle(color: Colors.white, fontSize: 15.0),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                SizedBox(height: responsive.hp(3)),

                                Container(
                                  width: size.width - 30,
                                  child: TextFormField(
                                    textCapitalization: TextCapitalization.none,
                                    onChanged: (value) => _password = value,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.black38,
                                      hintText: 'Password',
                                      border: UnderlineInputBorder(
                                          borderRadius: BorderRadius.circular(5)
                                      ),
                                      hintStyle: const TextStyle(color: Colors.white, fontSize: 15.0),
                                    ),
                                    keyboardType: TextInputType.text,
                                    obscureText: true,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        AppConfig.debugMode ? SizedBox(height: responsive.hp(18)) : SizedBox(height: responsive.hp(22)),

                        ButtonTheme(
                          minWidth: size.width - 30,
                          height: 50.0,
                          child: RaisedButton(
                            disabledColor: Colors.grey,
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onPressed: isEnabled ? ()=> _toogle() : null ,
                            child: Text(
                              "L O G I N",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.ip(2.5)
                              ),
                            ),
                          ),
                        ),

                        AppConfig.debugMode ? Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamedAndRemoveUntil('configuration', (Route<dynamic> route) => false);
                            },
                            child: Container(
                              alignment: Alignment(1, 0),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 18.0),
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Icon(Icons.settings),
                                    Text('Configuration')
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ) : Container()
                      ],
                    ),
                  ),
                ),
              ),

              isFetching ?
              Positioned.fill(
                  child: Container(
                    child: Center(
                      child: CupertinoActivityIndicator(radius: 15),
                    ),
                  )) :Container()
            ],
          ),


        ),
      ),
    );
  }

}

