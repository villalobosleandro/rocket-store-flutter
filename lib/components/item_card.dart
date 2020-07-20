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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: redColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Hero(
                tag: "${widget.product['_id']}",
                child: Image.asset(
                  'assets/images/bag_2.png',
                   fit: BoxFit.fill,
                ),
//                child: Image.network(widget.product['pictures'][0]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20 / 3),
            child: Text(
              widget.product['name'],
              style: TextStyle(color: Colors.grey),
              maxLines: 1,
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