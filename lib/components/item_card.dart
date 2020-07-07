import 'package:flutter/material.dart';

import './Product.dart';
import './../constants.dart';
import './../utils/mColors.dart';

class ItemCard extends StatefulWidget {
  final Product product;
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
    print(widget.product.name);
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
              // For  demo we use fixed height  and width
              // Now we dont need them
              // height: 180,
              // width: 160,
              decoration: BoxDecoration(
                color: redColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Hero(
                tag: "${widget.product.id}",
                child: Image.asset(widget.product.presentationImage),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin / 4),
            child: Text(
              // products is out demo list
              widget.product.name,
              style: TextStyle(color: kTextLightColor),
            ),
          ),
          Text(
            "\$${widget.product.price}",
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}