import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import './../../utils/mColors.dart';
import './../../components/topBar.dart';
import './../../hooks/useGetAsyncStorageProduct.dart';

class DetailsScreen extends StatefulWidget {
  final product;

  const DetailsScreen({Key key, this.product}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  useGetAsyncStorageProduct hook;
  int numberOfProductsInCart = 0;
  bool isFetching = false;

  @override
  void initState() {
    this.hook = Provider.of<useGetAsyncStorageProduct>(context, listen: false);
    super.initState();
  }


  _addElementToCart() async {

    dynamic element = {
      "_id": widget.product['_id'],
      "name": widget.product['name'],
      "price": widget.product['price'],
      "priceOnCredit": widget.product['priceOnCredit'],
      "img": widget.product['pictures'][0],
      "quantity": 1,
      "numberOfFees": widget.product['numberOfFees'] != null ? widget.product['numberOfFees'] : 1
    };

    final response = await hook.setCartInAsyncStorage(element);
    if(response) {
      FlutterToast.showToast(
          msg: 'agregado al carrito',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }else{
      FlutterToast.showToast(
          msg: 'error vuelve a intentar',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: TopBar(
//          routeName: 'home',
//          title: 'DETAILS'
        ),
      ),
      body: isFetching ? Container(
        child: Center(
          child: CupertinoActivityIndicator(radius: 15),
        ),
      ) : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Container(
                    child: Swiper(
                      autoplay: true,
                      itemBuilder: (BuildContext context, int index) {
                        return new Image.asset(
                          "assets/images/bag_2.png",
                          fit: BoxFit.fill,
                        );
                      },
                      itemCount: 3,
                      itemWidth: 300.0,
                      itemHeight: 300.0,
                      layout: SwiperLayout.TINDER,
                    )
                ),
              ),

              Expanded(
                flex: 6,
                child: Column(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: Text(widget.product['name']),
                            )
                          ],
                        )
                    ),
                    Expanded(
                      flex: 1,
                      child: RatingBar(
                        initialRating: widget.product['rating'].toDouble(),
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          color: redColor,
                          onPressed: () {
                            _addElementToCart();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              IconButton(
                                icon: SvgPicture.asset(
                                  "assets/icons/add_to_cart.svg",
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                              Text(
                                "add to shopping cart".toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),

        Expanded(
          flex: 1,
          child: Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Column(
                    children: <Widget>[
                      Text('price on credit'.toUpperCase()),
                      Text("\$ " + widget.product['priceOnCredit'].toString()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: <Widget>[
                      Text('counted price'.toUpperCase()),
                      Text("\$ " + widget.product['price'].toString())
                    ],
                  ),
                )
              ],
            ),
          ),
        ),

        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
                child: Text(widget.product['description'])
            ),
          ),
        ),
      ],
    );
  }
}