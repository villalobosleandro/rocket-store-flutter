
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './../../components/Product.dart';
import './../../components/item_card.dart';
import './../details/details_screen.dart';
import './../../utils/app_config.dart';
import './../../api/auth_api.dart';
import './../../components/topBar.dart';
import './../../hooks/useGetAsyncStorageProduct.dart';
import './../../components/menuDrawer/menuDrawer.dart';
import './../../utils/dialogs.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFetching = true, consultCampaing = true, consultCategories = true;

  List<dynamic> itemProducts = List<Product>();
  int numberOfProducts = 0;
  final _api = AuthApi(), hook = useGetAsyncStorageProduct();
  dynamic campaing = {}, categories = [];

  @override
  void initState() {
    super.initState();
    this._getActiveCampaing();
    this._getCategories();
    this._getProducts();
    this.numberProducts();
  }

  _getActiveCampaing() async {
    try{
      final token = await _api.getAccessToken();
      var query = [{
        'extraData': token['token']
      }];

      final res = await _api.callMethod(context, ApiRoutes.storeCampaign, query);
//      print('campaing => ');
//      print(res);
      setState(() {
        campaing = res;
        consultCampaing = false;
      });
    }on PlatformException catch(e) {
      setState(() {
        consultCampaing = false;
      });
    }
  }

  _getCategories() async {
    try{
      final token = await _api.getAccessToken();
      var query = [{
        'extraData': token['token']
      }];

      final res = await _api.callMethod(context, ApiRoutes.listCategories, query);
//      print('caregorias => ');
//      print(res);

      setState(() {
        categories = res;
        consultCategories = false;
      });
    }on PlatformException catch(e) {
      setState(() {
        consultCategories = false;
      });
    }
  }

  numberProducts() async {
    numberOfProducts = await hook.getNumberProducts();
//    print('=========== $numberOfProductsInCart');

  }

  _getProducts() async {
    try {
      final token = await _api.getAccessToken();
      var query = [{
        'filters': {
          'categoryId': ''
        },
        'options': {},
        'extraData': token['token']
      }];
      final products = await _api.callMethod(context, ApiRoutes.productsList, query);
//      print('products => ');
//      print(products);
      if(products['data']['products'] != []) {
        setState(() {
          itemProducts = products['data']['products'];
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
  }

  _filterWithCategories(categoryId) async {
//    print('categoryId => $categoryId');
    setState(() {
      isFetching = true;
    });
    try {
      final token = await _api.getAccessToken();
      var query = [{
        'filters': {
          'categoryId': categoryId
        },
        'options': {},
        'extraData': token['token']
      }];
      final products = await _api.callMethod(context, ApiRoutes.productsList, query);
      if(products['data']['products'] != []) {
        setState(() {
          itemProducts = products['data']['products'];
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: TopBar(
          hideBackButton: true,
          title: 'DASHBOARD',
          numberOfProducts: numberOfProducts
        ),
      ),
      drawer: MenuDrawer(),
      body: (consultCampaing || isFetching ||  consultCategories) ? Container(
        child: Center(
          child: CupertinoActivityIndicator(radius: 15),
        ),
      ) : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            children: <Widget>[
              _buildCampaing(),
              _buildCategories(),
              _buildProducts()
            ]
        )
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 100,
      child: (
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              var iconType;
              switch(categories[index]['filter']) {
                case 'TEC': {
                  iconType = Icons.devices_other;
                }
                break;

                case 'VIDEOJUEGOS': {
                  iconType = Icons.games;
                }
                break;

                case 'DEPORTE': {
                  iconType = Icons.rowing;
                }
                break;

                case 'MOTOS': {
                  iconType = Icons.motorcycle;
                }
                break;

                case 'FLORES': {
                  iconType = Icons.local_florist;
                }
                break;

                default: {
                  iconType = Icons.adjust;
                }
                break;
              }
              return InkWell(
                onTap: (){
                  _filterWithCategories(categories[index]['_id']);
                },
                child: Container(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(iconType),
                      Text(categories[index]['name'], maxLines: 1)
                    ],
                  ),
                ),
              );
            }
          )
      ),
    );
  }

  Widget _buildCampaing() {
    if(campaing['data']['imageUrl'] != null) {
      final size = MediaQuery.of(context).size;
      return Container(
        height: 120,
        width: size.width - 20,
          child: FadeInImage(
            fit: BoxFit.cover,
            placeholder: AssetImage('assets/images/loading.gif'),
            image: NetworkImage(campaing['data']['imageUrl']),
          ),
      );
    }else {
      return Container();
    }
  }

  Widget _buildProducts() {
    print('========================');
    print(itemProducts.length);
    if(itemProducts.length > 0) {
      return Flexible(
        child: ListView.builder(
          itemCount: itemProducts.length,
          itemBuilder: (context, index) => ItemCard(
            product: itemProducts[index],
            press: () {
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) => DetailsScreen(
                      product : itemProducts[index])),
                      (route) => false
              );
            },
          ),
        ),
      );
    }else {
      return Center(
        child: Text('No products'),
      );
    }

  }
}
