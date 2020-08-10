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
  bool isFetching = true, consultQuestions = true;
  TabController tabController;
  final _api = AuthApi();
  dynamic productDetail = [], comments = [], questions = [];
  var descripcion = '', question = '';
  String showOptions = 'add', commentId = '';
  double ratting = 0;

  @override
  void initState() {
    this.hook = Provider.of<useGetAsyncStorageProduct>(context, listen: false);
    tabController = TabController(length: 3, vsync: this);
//    this.numberProducts();
    this._getProductDetail();
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
        'storeProductId': widget.product['_id'],
        'typeId': 'question'
      }];
      final res = await _api.callMethod(context, ApiRoutes.listQuestions, query);
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

  _getProductDetail() async {
    try {
      final token = await _api.getAccessToken();
      var query = [{
        '_id': widget.product['_id'],
        'extraData': token['token']
      }];
      final res = await _api.callMethod(context, ApiRoutes.storeProductGet, query);
      if(res.length > 0) {
        var temp = [];
        for (var i = 0; i < res['comments'].length; ++i) {
          if(res['comments'][i]['isRemove'] == false) {
            temp.add(res['comments'][i]);
          }
        }
        setState(() {
          productDetail = res;
          comments = temp;
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
          msg: 'Added to cart'.toUpperCase(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }else{
      FlutterToast.showToast(
          msg: 'Error try again'.toUpperCase(),
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
    final storage = FlutterSecureStorage();
    Map<String, String> allValues = await storage.readAll();
    var aux = jsonDecode(allValues['SESSION']);
    dynamic temp;

    if(comments.length > 0) {
      for (var i = 0; i < comments.length; ++i) {
        //busco todos los comentarios del usuario que no esten eliminados
        if(comments[i]['user']['_id'] == aux['userId'] && comments[i]['isRemove'] == false) {
          setState(() {
            showOptions = 'edirtOrRemove';
            ratting = comments[i]['rating'].toDouble();
            descripcion = comments[i]['comment'];
            commentId = comments[i]['_id'];
          });
        }

      }
    }
  }

  _addOrEditCommentModal(context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('What do you think about this?'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Text('Rate this product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

              //ratting
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RatingBar(
                  initialRating: ratting,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  onRatingUpdate: (rating) {
                    setState(() {
                      ratting = rating;
                    });
                  },
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                ),
              ),

              //texto
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Describe your experience (optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),

              //textfromfield
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  textCapitalization: TextCapitalization.none,
                  initialValue: descripcion,
                  onChanged: (value) => descripcion = value,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                setState(() {
                  descripcion = '';
                  ratting = 0;
                });
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(
                  color: Colors.red
              )
              ),
              shape: RoundedRectangleBorder(side: BorderSide(
                  color: Colors.red,
                  width: 1,
                  style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(5)),
            ),

            FlatButton(
              onPressed: () {
                this._insertOrEditComment();
                Navigator.of(context).pop();
              },
              child: Text('Save', style: TextStyle(
                  color: Colors.green
              )
              ),
              shape: RoundedRectangleBorder(side: BorderSide(
                  color: Colors.green,
                  width: 1,
                  style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(5)),
            )
          ],
        )
    );
  }

  _modalQuestion(context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Write your question'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              //textfromfield
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  textCapitalization: TextCapitalization.none,
                  initialValue: question,
                  onChanged: (value) => question = value,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textAlign: TextAlign.start,
//                  style: const TextStyle(
//                    color: Colors.red,
//                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                setState(() {
                  question = '';
                });
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(
                  color: Colors.red
              )
              ),
              shape: RoundedRectangleBorder(side: BorderSide(
                  color: Colors.red,
                  width: 1,
                  style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(5)),
            ),

            FlatButton(
              onPressed: () {
                this._insertQuestion();
                Navigator.of(context).pop();
              },
              child: Text('Save', style: TextStyle(
                  color: Colors.green
              )
              ),
              shape: RoundedRectangleBorder(side: BorderSide(
                  color: Colors.green,
                  width: 1,
                  style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(5)),
            )
          ],
        )
    );
  }

  _insertQuestion() async {
    setState(() {
      consultQuestions = true;
    });

    try {
      final token = await _api.getAccessToken();
      dynamic data = [{
        'storeProductId': productDetail['_id'],
        'userId': token['userId'],
        'typeId': 'question',
        'message': question,
        'extraData': token['token']
      }];

      final res = await _api.callMethod(context, ApiRoutes.storeProductQuestionInsert, data);
      if(res['success'] == true) {
        setState(() {
          question = '';
        });
        this._getQuestionsAndAnswer();
      }
    } on PlatformException catch(e) {
      setState(() {
        consultQuestions = false;
      });
      Dialogs.alert(context, title: 'Error', message: 'Error try again');
    }
  }

  _insertOrEditComment() async {
    setState(() {
      isFetching = true;
    });

    try {
      final token = await _api.getAccessToken();
      dynamic data = [{
        '_id': productDetail['_id'],
        'rating': ratting,
        'comment': descripcion,
        'extraData': token['token']
      }];
      final res = await _api.callMethod(context, ApiRoutes.upSertRatingComment, data);
      if(res['success'] == true) {
        setState(() {
          ratting = 0;
          descripcion = '';
        });
        this._getProductDetail();
      }
    } on PlatformException catch(e) {
      setState(() {
        isFetching = false;
      });
      Dialogs.alert(context, title: 'Error', message: 'Error try again');
    }
  }

  _removeComment() async {
    setState(() {
      isFetching = true;
    });
    try {
      final token = await _api.getAccessToken();
      dynamic data = [{
        '_id': productDetail['_id'],
        'commentId': commentId,
        'extraData': token['token']
      }];
      final res = await _api.callMethod(context, ApiRoutes.storeRemoveComment, data);
      if(res['success'] == true) {
        setState(() {
          ratting = 0;
          descripcion = '';
        });
        this._getProductDetail();
      }
    } on PlatformException catch(e) {
      setState(() {
        isFetching = false;
      });
      Dialogs.alert(context, title: 'Error', message: 'Error try again');
    }
  }

  _showDeleteCommentDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Alert!!!"),
          content: Text("Are you sure to delete your comment?"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(
                  color: Colors.red
              )
              ),
              shape: RoundedRectangleBorder(side: BorderSide(
                  color: Colors.red,
                  width: 1,
                  style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(5)),
            ),

            FlatButton(
              onPressed: () {
                this._removeComment();
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(
                  color: Colors.green
              )
              ),
              shape: RoundedRectangleBorder(side: BorderSide(
                  color: Colors.green,
                  width: 1,
                  style: BorderStyle.solid
              ), borderRadius: BorderRadius.circular(5)),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: TopBar(
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
                        return FadeInImage(
                          fit: BoxFit.cover,
                          placeholder: AssetImage('assets/images/loading.gif'),
                          image: NetworkImage(productDetail['pictures'][0]),
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
                              child: Text(productDetail['name'], textAlign: TextAlign.justify),
                            )
                          ],
                        )
                    ),
                    Expanded(
                      flex: 1,
                      child: RatingBar(
                        initialRating: productDetail['rating'].toDouble(),
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
                      Text("\$ " + productDetail['priceOnCredit'].toString()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('counted price'.toUpperCase()),
                      Text("\$ " + productDetail['price'].toString())
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

  Widget floatingButtons() {
    return Positioned(
      bottom: 10,
      right: 10,
      child: AnimatedFloatingActionButton(
          fabButtons: <Widget> [
            editComment(),
            deleteComment()
          ],
          colorStartAnimation: Colors.red,
          colorEndAnimation: Colors.red,
          animatedIconData: AnimatedIcons.menu_close //To principal button
      ),
    );
  }

  Widget getTabBarPages() {
    return TabBarView(controller: tabController, children: <Widget>[
      //descripcion
      Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: productDetail['description'] != '' ? SingleChildScrollView(
              child: Text(productDetail['description'], textAlign: TextAlign.justify)
          ) : Center(
            child: Text('No descriptions'),
          ),
        ),
      ),

      //comentarios
      Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: comments.length > 0 ? Stack(
              children: <Widget>[
                ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
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
                    }
                ),

                floatingButtons()
              ],
            ) : Stack(
              children: <Widget>[
                Center(
                  child: Text('No comments to show'),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: addComment(),
                )
              ],
            )
          )
      ),

      //preguntas
      Container(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: questions.length > 0 ? ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
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
                          ): Container()
                        ],
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text('No questions'),
              ),
            ),

            Positioned(
              right: 10,
              bottom: 10,
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: (){
                  this._modalQuestion(context);
                },
                child: Icon(Icons.add),
              ),
            )
          ],
        )
      )
    ]);
  }

  Widget addComment() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: (){
          this._addOrEditCommentModal(context);
        },
        tooltip: 'Add Comment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget editComment() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: (){
          this._addOrEditCommentModal(context);
        },
        tooltip: 'Edit Comment',
        child: Icon(Icons.edit),
      ),
    );
  }

  Widget deleteComment() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          this._showDeleteCommentDialog();
        },
        tooltip: 'Delete comment',
        child: Icon(Icons.delete_outline),
      ),
    );
  }
}