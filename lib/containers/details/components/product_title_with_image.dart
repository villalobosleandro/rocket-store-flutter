import 'package:flutter/material.dart';
import './../../../components/Product.dart';

import './../../../constants.dart';
import './../../../utils/mColors.dart';

class ProductTitleWithImage extends StatelessWidget {
  const ProductTitleWithImage({
    Key key,
    @required this.product,
  }) : super(key: key);

  final product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
//          Text(
//            "Aristocratic Hand Bag",
//            style: TextStyle(color: Colors.red),
//          ),
          Text(
            product['name'],
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          SizedBox(height: kDefaultPaddin),
          Row(
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: [
//                      TextSpan(text: "Price\n", style: TextStyle(color: redColor, fontSize: 24)),
                    TextSpan(
                      text: "\$${product['price']}",
                      style: Theme.of(context).textTheme.headline4.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(width: kDefaultPaddin),
              Expanded(
                child: Hero(
                  tag: "${product['_id']}",
                  child: Image.asset(
                    'assets/images/bag_2.png',
                    fit: BoxFit.fill,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}