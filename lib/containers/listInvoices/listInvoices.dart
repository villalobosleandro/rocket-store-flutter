import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/moment.dart';

import './../../components/topBar.dart';
import './../../components/menuDrawer/menuDrawer.dart';
import './../../api/auth_api.dart';
import './../../hooks/useGetAsyncStorageProduct.dart';
import './../../utils/app_config.dart';

class ListInvoices extends StatefulWidget {
  @override
  _ListInvoicesState createState() => _ListInvoicesState();
}

class _ListInvoicesState extends State<ListInvoices> {
  bool isFetching = true;
  final _api = AuthApi(), hook = useGetAsyncStorageProduct();
  dynamic invoices = [];

  @override
  void initState() {
    this._getInvoices();
    super.initState();
  }

  _getInvoices() async {
    try{
      final token = await _api.getAccessToken();
      var query = [{
        'extraData': token['token']
      }];

      final profile = await _api.callMethod(context, ApiRoutes.profileGet, query);
      if(profile.length > 0) {
        var data = [{
        'userId': profile['id'],
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
        ),
      ),
      drawer: MenuDrawer(),
      body: isFetching ? Container(
        child: Center(
          child: CupertinoActivityIndicator(radius: 15),
        ),
      ) : _buildBody(),
    );
  }

  Widget _buildBody() {
    if(invoices.length == 0) {
      return Center(
        child: Text('There are no invoices'),
      );
    }else {
      return Column(
        children: <Widget>[
          Container(
            color: Colors.grey,
            height: 50,
            child: Row(
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width / 4,
                    alignment: Alignment(-1, 0),
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('#Order',  textAlign: TextAlign.start),
                    )
                ),

                Container(
                    width: MediaQuery.of(context).size.width / 4,
                    alignment: Alignment(0, 0),
                    height: 50,
                    child: Text('Amaount',  textAlign: TextAlign.center)
                ),

                Container(
                    width: MediaQuery.of(context).size.width / 4,
                    alignment: Alignment(0, 0),
                    height: 50,
                    child: Text('Date',  textAlign: TextAlign.center)
                ),

                Container(
                    width: MediaQuery.of(context).size.width / 4,
                    alignment: Alignment(1, 0),
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text('Method', textAlign: TextAlign.end),
                    )
                )
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
//                print(invoices[index]);
                return Row(
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width / 4,
                        alignment: Alignment(-1, 0),
                        height: 50,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(invoices[index]['correlative'].toString(),  textAlign: TextAlign.start),
                        )
                    ),

                    Container(
                        width: MediaQuery.of(context).size.width / 4,
                        alignment: Alignment(0, 0),
                        height: 50,
                        child: Text(invoices[index]['amount'].toString(),  textAlign: TextAlign.center)
                    ),

                    Container(
                        width: MediaQuery.of(context).size.width / 4,
                        alignment: Alignment(0, 0),
                        height: 50,
                        child: Text(Moment(invoices[index]['updateAt']).format('yyyy-MM-dd'),  textAlign: TextAlign.center)
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
                );
              },
            ),
          )



        ],
      );
    }
  }
}
