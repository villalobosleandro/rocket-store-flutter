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
  bool isFetching = true, consultQuestions = true, consultNotifi = true;
  TabController tabController;
  final _api = AuthApi();
  dynamic productDetail = [], comments = [], questions = [];
  var descripcion = '', question = '', notifications = [];
  String showOptions = 'add', commentId = '';
  double ratting = 0;

  @override
  void initState() {
    this.hook = Provider.of<useGetAsyncStorageProduct>(context, listen: false);
    tabController = TabController(length: 3, vsync: this);
    this._getProductDetail();
    this._getQuestionsAndAnswer();
    this._getNotifications();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  _getNotifications() async {
    try{
      final token = await _api.getAccessToken();
      var query = [{
        'extraData': token['token'],
        'unread': true
      }];

      final notifi = await _api.callMethod(context, ApiRoutes.notificationsList, query);
      if(notifi['success'] == true) {
        setState(() {
          notifications = notifi['data'];
          consultNotifi = false;
        });
      }
      setState(() {
        consultNotifi = false;
      });
    }on PlatformException catch(e) {
      setState(() {
        consultNotifi = false;
      });
    }
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
          content: Container(
            height: 250,
            child: Column(
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
                    maxLines: 2,
                    textAlign: TextAlign.start,
                  ),
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    OutlineButton(
                      borderSide: BorderSide(
                        color: redColor,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
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
                    ),

                    FlatButton(
                      color: Colors.green,
                      onPressed: () {
                        this._insertOrEditComment();
                        Navigator.of(context).pop();
                      },
                      child: Text('Save', style: TextStyle(
                          color: Colors.white
                      )
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
    );
  }

  _modalQuestion(context) {
    showDialog(

        context: context,
        builder: (_) => AlertDialog(
          title: Text('Write your question'),
          content: Container(
            height: 150,
            child: Column(
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
                    maxLines: 2,
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    OutlineButton(
                      borderSide: BorderSide(
                        color: redColor,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
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
                    ),

                    FlatButton(
                      color: Colors.green,
                      onPressed: () {
                        this._insertQuestion();
                        Navigator.of(context).pop();
                      },
                      child: Text('Save', style: TextStyle(
                          color: Colors.white
                        )
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
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
          content: Container(
              height: 100,
              child: Column(
                children: <Widget>[
                  Text("Are you sure to delete your comment?"),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      OutlineButton(
                        borderSide: BorderSide(
                          color: redColor,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel', style: TextStyle(
                            color: redColor
                          )
                        ),
                      ),

                      FlatButton(
                        color: Colors.green,
                        onPressed: () {
                          this._removeComment();
                          Navigator.of(context).pop();
                        },
                        child: Text('Confirm', style: TextStyle(
                            color: Colors.white
                        )
                        ),
                      ),
                    ],
                  )
                ],
              )
          ),
        ));
  }

  _showModalImagePreview(images, context) {
    print(images.length);
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Container(
            height: 350.0,
            child: images.length == 1 ? FadeInImage(
              fit: BoxFit.fill,
              height: 350.0,
              width: 350.0,
              placeholder: AssetImage('assets/images/loading.gif'),
              image: NetworkImage(images[0]),
            ) : Swiper(
              containerHeight: 350.0,
              layout: SwiperLayout.TINDER,
              autoplay: true,
              itemCount: images.length,
              itemWidth: 350.0,
              itemHeight: 350.0,
              itemBuilder: (BuildContext context, int index) {
                return FadeInImage(
                  fit: BoxFit.fill,
                  height: 350.0,
                  width: 350.0,
                  placeholder: AssetImage('assets/images/loading.gif'),
                  image: NetworkImage(images[index]),
                );
              },
            ),
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: TopBar(
            title: 'DETAILS',
            notifications: notifications
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
                child: InkWell(
                  onTap: (){
                    this._showModalImagePreview(productDetail['pictures'], context);
                  },
                  child: Container(
                      child: productDetail['pictures'].length == 1 ?  Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FadeInImage(
                          fit: BoxFit.fill,
                          placeholder: AssetImage('assets/images/loading.gif'),
                          image: NetworkImage(productDetail['pictures'][0]),
                        ),
                      ) : Swiper(
                        autoplay: true,
                        itemBuilder: (BuildContext context, int index) {
                          return FadeInImage(
                            fit: BoxFit.fill,
                            placeholder: AssetImage('assets/images/loading.gif'),
                            image: NetworkImage(productDetail['pictures'][index]),
                          );
                        },
                        itemCount: productDetail['pictures'].length,
                        itemWidth: 300.0,
                        itemHeight: 300.0,
                        layout: SwiperLayout.TINDER,
                      ),
                  ),
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
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(productDetail['name'], textAlign: TextAlign.justify),
                              ),
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
                      Text("\$ " + _api.formatter(productDetail['priceOnCredit']).toString()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('counted price'.toUpperCase()),
                      Text("\$ " + _api.formatter(productDetail['price']).toString())
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
        labelColor: redColor,
        indicatorColor: redColor,
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
          colorStartAnimation: redColor,
          colorEndAnimation: redColor,
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
                              Text(comments[index]['updatedAtFromNow'], style: TextStyle(fontSize: 12)),
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
                          ListTile(
                            title: Text(questions[index]['message'],
                                    textAlign: TextAlign.justify,
                                ),
                            leading: Icon(Icons.chat, color: Colors.grey),
                            subtitle: questions[index]['answer'] != null ? Text(questions[index]['answer']['message']) : Container(),
                          ),
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
                backgroundColor: redColor,
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
        backgroundColor: redColor,
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
        backgroundColor: redColor,
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
        backgroundColor: redColor,
        onPressed: () {
          this._showDeleteCommentDialog();
        },
        tooltip: 'Delete comment',
        child: Icon(Icons.delete_outline),
      ),
    );
  }
}