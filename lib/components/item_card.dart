import 'package:flutter/material.dart';

import './../constants.dart';
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
    // TODO: implement initState
    super.initState();
    print('ajjjjjajajjajajaja');
    print(widget.product['pictures'][0]);
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.press,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(kDefaultPaddin),
              decoration: BoxDecoration(
                color: redColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Hero(
                tag: "${widget.product['_id']}",
                child: Image.network(widget.product['pictures'][0]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin / 4),
            child: Text(
              // products is out demo list
              widget.product['name'],
              style: TextStyle(color: kTextLightColor),
            ),
          ),
          Text(
            "\$${widget.product['price']}",
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}