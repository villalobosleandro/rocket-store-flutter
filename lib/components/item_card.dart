import 'package:flutter/material.dart';

import './../utils/mColors.dart';

class ItemCard extends StatefulWidget {
  final product;
  final Function press;
  const ItemCard({Key key, this.product, this.press}) : super(key: key);

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
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
                  child: Image.asset(
                    'assets/images/campana.png',
                    fit: BoxFit.cover,
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
                        Text("\$ ${widget.product['price'].toString()}"),
                        Text('Counted'),
                        widget.product['priceOnCredit'] != null ? Text("\$ ${widget.product['priceOnCredit'].toString()}") : null,
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