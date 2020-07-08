import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rocket_store_flutter/utils/dialogs.dart';

import '../../constants.dart';
import './../../components/Product.dart';
import './../../components/item_card.dart';
import './../details/details_screen.dart';
import './../../utils/app_config.dart';
import './../../api/auth_api.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFetching = true;
  final _api = AuthApi();
  List<dynamic> itemProducts = List<Product>();

  @override
  void initState() {
    super.initState();
    this._getProducts();
  }

  _getProducts() async {
    try {
      final products = await _api.callMethod(context, ApiRoutes.productsList);
      if(products != []) {
        setState(() {
          itemProducts = products;
          isFetching = false;
        });
      }
      setState(() {
        isFetching = false;
      });
    } on PlatformException catch(e) {
      setState(() {
        isFetching = false;
      });
      Dialogs.alert(context, title: 'Error', message: 'Conection error');
    }
    print('000000000000000000000000');
    print(itemProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
            child: GridView.builder(
                itemCount: itemProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: kDefaultPaddin,
                  crossAxisSpacing: kDefaultPaddin,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) => ItemCard(
                  product: itemProducts[index],
                  press: () {
//                    print('click click');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            product: itemProducts[index],
                          ),
                        ));
                  },
                )),
          ),
        ),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text('DASHBOARD', style: TextStyle(color: Colors.black),),
    );
  }
}
