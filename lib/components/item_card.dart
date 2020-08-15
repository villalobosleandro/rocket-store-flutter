import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './../utils/mColors.dart';
import './../api/auth_api.dart';

class ItemCard extends StatefulWidget {
  final product;
  final Function press;

  const ItemCard({Key key, this.product, this.press}) : super(key: key);

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final _api = AuthApi();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
//    print(widget.product);
//
//  print('--------------');
//  print(DateTime.now());
//  print(DateFormat.yMd().add_jms().format(DateTime.now()));



    return GestureDetector(
      onTap: widget.press,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Container(
          height: 160,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                  height: 150,
                    child: FadeInImage(
                      fit: BoxFit.fill,
                      placeholder: AssetImage('assets/images/loading.gif'),
                      image: NetworkImage(widget.product['pictures'][0]),
                    ),
                ),
              ),

              Expanded(
                flex: 7,
                child: Container(
                  height: 150,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.product['name'], maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("\$ ${_api.formatter(widget.product['price']).toString()}"),
                        Text('Counted'),
                        widget.product['priceOnCredit'] != null ? Text("\$ ${_api.formatter(widget.product['priceOnCredit']).toString()}") : null,
                        widget.product['priceOnCredit'] != null ? Text('Credit') : null,
                        widget.product['creditInstallmentMessage'] != null ? Text(widget.product['creditInstallmentMessage']) : null
                      ],
                    ),
                  )
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}