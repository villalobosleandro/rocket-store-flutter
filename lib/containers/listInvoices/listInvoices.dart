import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './../invoiceDetail/invoiceDetail.dart';
import './../../components/topBar.dart';
import './../../components/menuDrawer/menuDrawer.dart';
import './../../api/auth_api.dart';
import './../../hooks/useGetAsyncStorageProduct.dart';
import './../../utils/app_config.dart';
import './../../utils/mColors.dart';


class ListInvoices extends StatefulWidget {
  @override
  _ListInvoicesState createState() => _ListInvoicesState();
}

class _ListInvoicesState extends State<ListInvoices> {
  bool isFetching = true, consultNotifi = true;
  final _api = AuthApi(), hook = useGetAsyncStorageProduct();
  dynamic invoices = [], notifications =[];

  @override
  void initState() {
    this._getInvoices();
    this._getNotifications();
    super.initState();
  }

  _getNotifications() async {
    try{
      final token = await _api.getAccessToken();
      var query = [{
        'extraData': token['token'],
        'unread': true
      }];

      final notifi = await _api.callMethod(context, ApiRoutes.notificationsList, query);
      if(notifi['success'] == true) {
        setState(() {
          notifications = notifi['data'];
          consultNotifi = false;
        });
      }
      setState(() {
        consultNotifi = false;
      });
    }on PlatformException catch(e) {
      setState(() {
        consultNotifi = false;
      });
    }
  }

  _getInvoices() async {
    try{
      final token = await _api.getAccessToken();
      var query = [{
        'extraData': token['token'],
      }];

      final profile = await _api.callMethod(context, ApiRoutes.profileGet, query);
      if(profile.length > 0) {
        var data = [{
        'userId': profile['id'],
        'itemsAsArray': true,
        'options': {
          'limit': 1000
        },
          'extraData': token['token']
        }];
        final res = await _api.callMethod(context, ApiRoutes.listInvoicesByUserId, data);
        if(res.length > 0) {
          setState(() {
            invoices = res['invoices'];
            isFetching = false;
          });
        }
      }

    }on PlatformException catch(e) {
      setState(() {
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: TopBar(
          title: 'INVOICES',
          notifications: notifications
        ),
      ),
      drawer: MenuDrawer(),
      body: (isFetching || consultNotifi) ? Container(
        child: Center(
          child: CupertinoActivityIndicator(radius: 15),
        ),
      ) : _buildBody(),
    );
  }

  Widget _buildBody() {
    print('==============');
    print(invoices);
    print('==============');
    print(invoices.length);
    if(invoices.length == 0) {
      return Center(
        child: Text('There are no invoices'),
      );
    }else {
      return Column(
        children: <Widget>[
          Container(
            color: redColor,
            height: 50,
            child: Row(
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width / 4,
                    alignment: Alignment(-1, 0),
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                          '# Order'.toUpperCase(),
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.white),
                      ),
                    )
                ),

                Container(
                    width: MediaQuery.of(context).size.width / 4,
                    alignment: Alignment(0, 0),
                    height: 50,
                    child: Text(
                        'Amaount'.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                    )
                ),

                Container(
                    width: MediaQuery.of(context).size.width / 4,
                    alignment: Alignment(0, 0),
                    height: 50,
                    child: Text(
                        'Date'.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                    )
                ),

                Container(
                    width: MediaQuery.of(context).size.width / 4,
                    alignment: Alignment(1, 0),
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                          'Method'.toUpperCase(),
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.white),
                      ),
                    )
                )
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: (){
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) => InvoiceDetail(
                            invoiceId : invoices[index]['_id'])),
                            (route) => false
                    );

                  },
                  child: Row(
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width / 4,
                          alignment: Alignment(-1, 0),
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                                invoices[index]['correlative'].toString(),
                                textAlign: TextAlign.start,
                            ),
                          )
                      ),

                      Container(
                          width: MediaQuery.of(context).size.width / 4,
                          alignment: Alignment(0, 0),
                          height: 50,
                          child: Text(_api.formatter(invoices[index]['amount']).toString(),  textAlign: TextAlign.center)
                      ),

                      Container(
                          width: MediaQuery.of(context).size.width / 4,
                          alignment: Alignment(0, 0),
                          height: 50,
                          child: Text(invoices[index]['createdAtFormatted'],  textAlign: TextAlign.center)
                      ),

                      Container(
                          width: MediaQuery.of(context).size.width / 4,
                          alignment: Alignment(1, 0),
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(invoices[index]['method'], textAlign: TextAlign.end),
                          )
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      );
    }
  }
}
