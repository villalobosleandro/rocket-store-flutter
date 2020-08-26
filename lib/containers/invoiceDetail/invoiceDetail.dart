import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './../../api/auth_api.dart';
import './../../utils/app_config.dart';
import './../../utils/mColors.dart';

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
        print('==================');
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

  _getTotalAmount() {
    var number = 0;
    for (var i = 0; i < invoice['items'].length; ++i) {
      if(invoice['method'] == 'credito'){
        number = number + (invoice['items'][i]['qty'] * (invoice['items'][i]['priceOnCredit'] * invoice['items'][i]['numberOfFees']));
      }else {
        number = number + (invoice['items'][i]['qty'] * invoice['items'][i]['price']);
      }
    }

    return number;
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
                _middlePart(),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.shopping_cart, color: redColor),
                      Text('Products')
                    ],
                  ),
                ),
                _bottomPart(),
                SizedBox(height: 10),
                _amountPart()
              ]
          )
      ),
    );
  }

  Widget _middlePart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.featured_play_list, size: 24, color: redColor),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('Invoice Information',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('Order: #' + invoice['correlative']),
          Text('Control: ' + invoice['_id']),
          Text('Date: ' + invoice['createdAtFormatted']),
          Text('Status Order: ' + invoice['status']),
          Text('Pay Method: ' + invoice['method']),
        ],
      ),
    );
  }

  Widget _bottomPart() {
    return Flexible(
      child: ListView.builder(
        itemCount: invoice['items'].length,
        itemBuilder: (context, index) {
          var price;
          if(invoice['method'] == 'credito'){
              price = invoice['items'][index]['qty'] * (invoice['items'][index]['priceOnCredit'] * invoice['items'][index]['numberOfFees']);
          }else {
              price = invoice['items'][index]['qty'] * invoice['items'][index]['price'];
          }

          return Container(
//            width: 200,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: ListTile(
                leading: FadeInImage(
                  fit: BoxFit.fill,
                  placeholder: AssetImage('assets/images/loading.gif'),
                  image: NetworkImage(invoice['items'][index]['img']),
                ),
                title: Text(invoice['items'][index]['item']),
                subtitle: Row(
                  children: <Widget>[
                    Text(invoice['items'][index]['qty'].toString()),
                    Text(' X '),
                    Text(invoice['method'] == 'credito' ?
                    _api.formatter(invoice['items'][index]['priceOnCredit']).toString() :
                    _api.formatter(invoice['items'][index]['price']).toString(),
                    ),
                    invoice['method'] == 'credito' ? Text(' X ') : Container(),
                    invoice['method'] == 'credito' ? Text(
                        invoice['items'][index]['numberOfFees'].toString() + ' Quotes',
                        style: TextStyle(fontSize: 12),
                    ) : Container(),

                  ],
                ),
                trailing: Column(
//                  crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(_api.formatter(price).toString(), style: TextStyle(fontSize: 12))
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _amountPart() {
    var number = _getTotalAmount();
    return Container(
      height: 65,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text('Subtotal: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_api.formatter(number)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text('IPC%: '),
                Text(invoice['fee_amount'] != null ? invoice['fee_amount'].toString() : '0')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text('Total: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_api.formatter(number)),
              ],
            )
          ],
        ),
      ),
    );
  }


}
