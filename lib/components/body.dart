//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:rocket_store_flutter/utils/app_config.dart';
//
//import './../constants.dart';
//import './Product.dart';
//import './../containers/details/details_screen.dart';
//import './categories.dart';
//import './item_card.dart';
//
//class Body extends StatefulWidget {
//  @override
//  _BodyState createState() => _BodyState();
//}
//
//class _BodyState extends State<Body> {
//  bool isFetching = true;
//
//
//  @override
//  void initState() {
//    // TODO: implement initState
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Column(
//      crossAxisAlignment: CrossAxisAlignment.start,
//
//      children: <Widget>[
//        //Categories(),
//        Expanded(
//          child: Padding(
//            padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
//            child: _buildBody(),
//          ),
//        ),
//      ],
//    );
//
//
//  }
//
//  Widget _buildBody() {
//    return GridView.builder(
//        itemCount: products.length,
//        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//          crossAxisCount: 2,
//          mainAxisSpacing: kDefaultPaddin,
//          crossAxisSpacing: kDefaultPaddin,
//          childAspectRatio: 0.75,
//        ),
//        itemBuilder: (context, index) => ItemCard(
//          product: products[index],
//          press: () => Navigator.push(
//              context,
//              MaterialPageRoute(
//                builder: (context) => DetailsScreen(
//                  product: products[index],
//                ),
//              )),
//        ));
//  }
//}