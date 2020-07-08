import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../constants.dart';
import '../../components/Product.dart';
import './components/body.dart';

class DetailsScreen extends StatelessWidget {
  final product;

  const DetailsScreen({Key key, this.product}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // each product have a color
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: Body(product: product),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('DETAILS', style: TextStyle(color: Colors.black),),
      backgroundColor: Colors.white,
      elevation: 0
    );
  }
}