import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:moment/moment.dart';
import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';

import './../../utils/mColors.dart';
import './../../components/topBar.dart';
import './../../hooks/useGetAsyncStorageProduct.dart';
import './../../api/auth_api.dart';
import './../../utils/app_config.dart';
import './../../utils/dialogs.dart';
import './../../components/menuDrawer/menuDrawer.dart';


class DetailsScreen extends StatefulWidget {
  final product;

  const DetailsScreen({Key key, this.product}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> with SingleTickerProviderStateMixin {
  useGetAsyncStorageProduct hook;
  int numberOfProducts = 0;
  bool isFetching = true;
  bool consultQuestions = true;
  TabController tabController;
  final _api = AuthApi();
  dynamic invoiceDetail = [];
  dynamic comments = [];
  dynamic questions = [];
  String showOptions = 'add';
  double ratting = 0;
  var descripcion = '';

  @override
  void initState() {
    this.hook = Provider.of<useGetAsyncStorageProduct>(context, listen: false);
    tabController = TabController(length: 3, vsync: this);
//    this.numberProducts();
    this._getInvoiceDetail();
    this._getQuestionsAndAnswer();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  _getQuestionsAndAnswer() async  {
    try {
      var query = [{
        'productId': widget.product['_id'],
        'typeId': 'question'
      }];
      final res = await _api.callMethod(context, ApiRoutes.listQuestions, query);
//      print('ressss => $res');
      if(res['data'] != null) {
        setState(() {
          questions = res['data'];
          consultQuestions = false;
        });
      }
    } on PlatformException catch(e) {
      setState(() {
        consultQuestions = false;
      });
      Dialogs.alert(context, title: 'Error', message: 'Conection error');
    }
  }

  _getInvoiceDetail() async {
    try {
      final token = await _api.getAccessToken();
      var query = [{
        'filters': {},
        'options': {},
        'extraData': token['token']
      }];
      final res = await _api.callMethod(context, ApiRoutes.productsList, query);
//      print('ressss => $res');
      if(res['data'].length > 0) {
        setState(() {
          invoiceDetail = res['data']['products'][0];
          comments = res['data']['products'][0]['comments'];
          isFetching = false;
        });

        this._initOptions();
      }
    } on PlatformException catch(e) {
      setState(() {
        isFetching = false;
      });
      Dialogs.alert(context, title: 'Error', message: 'Conection error');
    }
  }

//  numberProducts() async {
//    numberOfProducts = await hook.getNumberProducts();
//    setState(() {
//      isFetching = false;
//    });
////    print('=========== $numberOfProducts');
//
//  }

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

  _initOptions() async {
    final storage = new FlutterSecureStorage();
    Map<String, String> allValues = await storage.readAll();
    var aux = jsonDecode(allValues['SESSION']);
    dynamic temp;

    if(comments.length > 0) {
      for (var i = 0; i < comments.length; ++i) {
        //busco todos los comentarios del usuario que no esten eliminados
//        print(comments[i]);
        if(comments[i]['user']['_id'] == aux['userId'] && comments[i]['isRemove'] == false) {
          print(comments[i]['rating']);
          print(comments[i]['comment']);
          setState(() {
            showOptions = 'edirtOrRemove';
            ratting = comments[i]['rating'].toDouble();
            descripcion = comments[i]['comment'];
          });
        }

      }

//      print(band);
//      temp = aux.where((item) => (item['user']['_id'] == aux['userId'] && item['isRemove'] == false)).toList();
//      print('temp => $temp');
    }
  }

  _addOrEditComment(context) {
    showModalBottomSheet(context: context, builder: (BuildContext bc){
      return Container(
        height: MediaQuery.of(context).size.height * .60,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.close, size: 20),
                  )
                ],
              ),

              Text('Rate this product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RatingBar(
                  initialRating: ratting,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ignoreGestures: true,
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Describe your experience (optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  textCapitalization: TextCapitalization.none,
                  initialValue: descripcion,
                  onChanged: (value) => descripcion = value,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),


            ],
          ),

        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: TopBar(
//          routeName: 'home',
            title: 'DETAILS',
            numberOfProducts: numberOfProducts
        ),
      ),
      drawer: MenuDrawer(),
      body: (isFetching || consultQuestions) ? Container(
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
          flex: 2,
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
                          fit: BoxFit.cover,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: Text(invoiceDetail['name'], textAlign: TextAlign.justify),
                            )
                          ],
                        )
                    ),
                    Expanded(
                      flex: 1,
                      child: RatingBar(
                        initialRating: invoiceDetail['rating'].toDouble(),
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        ignoreGestures: true,
//                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('price on credit'.toUpperCase()),
                      Text("\$ " + invoiceDetail['priceOnCredit'].toString()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('counted price'.toUpperCase()),
                      Text("\$ " + invoiceDetail['price'].toString())
                    ],
                  ),
                )
              ],
            ),
          ),
        ),

        Expanded(
          flex: 6,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              flexibleSpace: SafeArea(
                child: getTabBar(),
              ),
            ),
            body: getTabBarPages()),
        ),
      ],
    );
  }

  Widget getTabBar() {
    return TabBar(
        controller: tabController,
        labelColor:Colors.red,
        indicatorColor: Colors.red,
        unselectedLabelColor: Colors.black,
        tabs: [
          Tab(text: "DESCRIPTION"),
          Tab(text: "COMMENTS"),
          Tab(text: "Q & A"),
        ]
    );
  }

  Widget getTabBarPages() {
    return TabBarView(controller: tabController, children: <Widget>[
      //descripcion
      Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: SingleChildScrollView(
              child: Text(invoiceDetail['description'], textAlign: TextAlign.justify)
          ),
        ),
      ),

      //comentarios
      Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: <Widget>[
                ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
//                      print('===========================');
//                      print(comments[index]);
                      if(comments[index]['isRemove'] == false) {
                        return Container(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(comments[index]['user']['name'], style: TextStyle(fontWeight: FontWeight.bold),  textAlign: TextAlign.justify),
                                RatingBar(
                                  initialRating: comments[index]['rating'].toDouble(),
                                  direction: Axis.horizontal,
                                  itemSize: 20,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  ignoreGestures: true,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                ),
                                Text(Moment(comments[index]['updateAt']).format('yyyy-MM-dd')),
                                Text(comments[index]['comment']),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }
                ),

                Positioned(
                  bottom: 10,
                  right: 10,
                  child: AnimatedFloatingActionButton(
                      fabButtons: <Widget>[
                        showOptions == 'add' ? addComment() : null,
                        showOptions != 'add' ? editComment() : null,
                        showOptions != 'add' ? deleteComment(): null
                      ],
                      colorStartAnimation: Colors.red,
                      colorEndAnimation: Colors.red,
                      animatedIconData: AnimatedIcons.menu_close //To principal button
                  ),
                )
              ],
            )
          )
      ),

      //preguntas
      Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
//              print('====================');
//              print(questions[index]);
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
//                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.chat_bubble, color: Colors.grey),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(questions[index]['message'], textAlign: TextAlign.justify, style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),

                      questions[index]['answer'] != null ? Row(
                        children: <Widget>[
                          Icon(Icons.chat, color: Colors.grey),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(questions[index]['answer']['message'], textAlign: TextAlign.justify),
                          )
                        ],
                      ): null
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      )
    ]);
  }

  Widget addComment() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Add Comment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget editComment() {
    return Container(
      child: FloatingActionButton(
        onPressed: (){
          print('lcick en edit');
          this._addOrEditComment(context);
        },
        tooltip: 'Edit Comment',
        child: Icon(Icons.edit),
      ),
    );
  }

  Widget deleteComment() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Delete comment',
        child: Icon(Icons.delete_outline),
      ),
    );
  }
}