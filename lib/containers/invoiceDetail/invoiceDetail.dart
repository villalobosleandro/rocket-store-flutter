import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:moment/moment.dart';

import './../../api/auth_api.dart';
import './../../utils/app_config.dart';

class InvoiceDetail extends StatefulWidget {
  final invoiceId;

  const InvoiceDetail({Key key, this.invoiceId}) : super(key: key);

  @override
  _InvoiceDetailState createState() => _InvoiceDetailState();
}

class _InvoiceDetailState extends State<InvoiceDetail> {
  bool isFetching = true, profileConsult = true;
  final _api = AuthApi();
  dynamic invoice = {}, profileUser = {};
  var amount = 0;

  @override
  void initState() {
    this._getInvoiceDetail();
    super.initState();
  }

  _getInvoiceDetail() async {
    try{
      final token = await _api.getAccessToken();
      var query = [{
        'extraData': token['token'],
        '_id': widget.invoiceId,
        'itemsAsArray': true
      }];

      final res = await _api.callMethod(context, ApiRoutes.invoiceGet, query);

      if(res['_id'] != null) {
        print('=================');
        print(res);
        var query = [{
          'extraData': token['token'],
        }];

        final profile = await _api.callMethod(context, ApiRoutes.profileGet, query);

        if(profile.length > 0) {
//          print('--------------');
//          print(profile);
          setState(() {
            profileUser = profile;
            profileConsult = false;
          });
        }
        setState(() {
          invoice = res;
          isFetching = false;
        });
      }

    }on PlatformException catch(e) {
      setState(() {
        isFetching = false;
      });
      FlutterToast.showToast(
          msg: 'Conexion error'.toUpperCase(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pushNamedAndRemoveUntil('listInvoices', (Route<dynamic> route) => false);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
        ),
        title: Text('Invoice Detail', style: TextStyle(color: Colors.black)),
      ),
      body: (isFetching || profileConsult) ? Container(
        child: Center(
          child: CupertinoActivityIndicator(radius: 15),
        ),
      ) : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _topPart(),
                SizedBox(height: 10),
                _middlePart(),
                SizedBox(height: 10),
                _bottomPart(),
//                SizedBox(height: 10),
//                _amountPart()
              ]
          )
      ),
    );
  }

  Widget _topPart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Invoice details #' + invoice['correlative']),
        SizedBox(height: 10),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Client Information'),
              Text('Id: ' + invoice['userId']),
              Text('Name: ' + profileUser['first_name'] + ' ' + profileUser['last_name']),
              Text('Email: ' + profileUser['email']),
              Text('City: ' + profileUser['city']),
              Text('Phone number: ' + profileUser['phone'].toString())
            ],
          ),
        ),
      ],
    );
  }

  Widget _middlePart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Invoice Information'),
        Text('Orden: ' + invoice['correlative']),
        Text('Control: ' + invoice['_id']),
//        Text('Date: ' + Moment(invoice['timestamp']).format('yyyy-MM-dd hh:mm')),
        Text('Status: ' + invoice['status']),
        Text('Method: ' + invoice['method']),
      ],
    );
  }

  Widget _bottomPart() {
    return Flexible(
      child: ListView.builder(
        itemCount: invoice['items'].length,
        itemBuilder: (context, index) {
//          print('=====================');
//          print(invoice['items'][index]);
          if(invoice['method'] == 'credito'){
//            print('entro al if $amount');
              amount = amount + (invoice['items'][index]['qty'] * (invoice['items'][index]['priceOnCredit'] * invoice['items'][index]['numberOfFees']));
          }else {
//            print('no entro al if');
              amount = amount + (invoice['items'][index]['qty'] * invoice['items'][index]['price']);
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(invoice['items'][index]['item']),
                Text(invoice['items'][index]['qty'].toString()),
//                Text(invoice['method'] == 'credito' ? invoice['items'][index]['priceOnCredit'].toString() : invoice['items'][index]['price'].toString())
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _amountPart() {
    return Text('monto final $amount');
  }


}
