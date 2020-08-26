import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rocket_store_flutter/containers/details/details_screen.dart';

import './../../components/topBar.dart';
import './../../components/menuDrawer/menuDrawer.dart';
import './../../api/auth_api.dart';
import './../../utils/app_config.dart';
import './../../utils/mColors.dart';


class ListNotifications extends StatefulWidget {
  @override
  _ListNotificationsState createState() => _ListNotificationsState();
}

class _ListNotificationsState extends State<ListNotifications> {
  var notifications = [];
  bool consultNotifi = true, unreadNotify = false;
  final _api = AuthApi();

  @override
  void initState() {
    this._getNotifications();
    super.initState();
  }

  _getNotifications() async {
    try{
      final token = await _api.getAccessToken();
      var query = [{
        'extraData': token['token'],
      }];

      final notifi = await _api.callMethod(context, ApiRoutes.notificationsList, query);
      if(notifi['success'] == true) {
//        print(notifi['data']);
        for (var i = 0; i < notifi['data'].length; ++i) {
          if(notifi['data'][i]['unread'] == true) {
            setState(() {
              unreadNotify = true;
            });
          }

        }
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

  _setNotification(id) async {
    final token = await _api.getAccessToken();
    dynamic data = [{
      '_id': id,
      'unread': false,
      'extraData': token['token'],
    }];

    await _api.callMethod(context, ApiRoutes.notificationSetUnread, data);
  }

  _setAllNotifications() async {
    setState(() {
      consultNotifi = true;
    });
    final token = await _api.getAccessToken();
    dynamic data = [{
      'unread': false,
      'extraData': token['token'],
    }];

    await _api.callMethod(context, ApiRoutes.notificationSetUnread, data);
    setState(() {
      unreadNotify = false;
    });
    this._getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: TopBar(
            hideBackButton: true,
            title: 'NOTIFICATIONS',
            notifications: [],
        ),
      ),
      drawer: MenuDrawer(),
      body: (consultNotifi) ? Container(
        child: Center(
          child: CupertinoActivityIndicator(radius: 15),
        ),
      ) : _buildBody(),
    );
  }

  Widget _buildBody() {
    if(notifications.length == 0) {
      return Center(
        child: Text('No notifications'),
      );
    }else {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: unreadNotify == true ? InkWell(
              onTap: (){
                this._setAllNotifications();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text('Mark all as read'),
                  ),
                  Icon(Icons.done_all)
                ],
              ),
            ) : Container(),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
//                print(notifications[index]);
                return ListTile(
                  title: Text(notifications[index]['message']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(notifications[index]['title'].toLowerCase()),
                      Text(notifications[index]['createdAtFormatted']),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: notifications[index]['unread'] == true ?
                    Icon(Icons.notification_important, color: redColor) :
                    Icon(Icons.done_all, color: Colors.blue),
                  onTap: () {
                    var temp = {
                      '_id':  notifications[index]['relatedId']
                    };
                    this._setNotification(notifications[index]['_id']);
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) => DetailsScreen(
                            product : temp)),
                            (route) => false
                    );
                  },
                );
              },
            ),
          )
        ],
      );
    }
  }
}
