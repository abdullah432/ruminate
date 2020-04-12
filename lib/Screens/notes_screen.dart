import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:notesapp/Screens/note_edit_screen.dart';
import 'package:notesapp/Screens/setNotification.dart';
import 'package:notesapp/Screens/welcome_screen.dart';
import 'package:notesapp/utils/MyClipper.dart';
import 'package:notesapp/utils/User.dart';
import 'package:notesapp/utils/auth_provider.dart';
import 'package:notesapp/utils/authentication.dart';
import 'package:notesapp/utils/firestore.dart';
import 'package:notesapp/utils/receivednotification.dart';
import 'package:rxdart/subjects.dart';
import '../utils/important_methods.dart';
import 'package:notesapp/global.dart';

String noteTxt = 'Hello my name is nitesh kumar';

class NotesScreen extends StatefulWidget {
  var noteTextConatiner;
  final useruid;
  NotesScreen(this.useruid, {this.noteTextConatiner});
  @override
  _NotesScreenState createState() => _NotesScreenState(useruid);
}

class _NotesScreenState extends State<NotesScreen> {
  var useruid;
  _NotesScreenState(this.useruid);
  //user record
  User _userRecord = new User();
  bool isAdmin = false;
  //db
  var _db = Firestore.instance;
  //custom firestore
  CustomFirestore _customFirestore = new CustomFirestore();
  //Document snapshot of user note collection in listview
  DocumentSnapshot dSnapshot;
  //scrollcontroller(jump to bottom of listview)
  ScrollController _scrollController = new ScrollController();
  final PageController pageController = PageController(viewportFraction: 0.8);

  //When pushnotification send then ok button should reach us to that note
  var snapshotdata;

  //local notification

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
  final BehaviorSubject<ReceivedNotification>
      didReceiveLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();

  final BehaviorSubject<String> selectNotificationSubject =
      BehaviorSubject<String>();

  NotificationAppLaunchDetails notificationAppLaunchDetails;

  @override
  void initState() {
    loadUserData();
    super.initState();

    localNotificationInitialize();

    print('again');

    // _configureDidReceiveLocalNotificationSubject();
    // _configureSelectNotificationSubject();
  }

  localNotificationInitialize() async {
    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('ruminate_appicon');
    // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
    // of the `IOSFlutterLocalNotificationsPlugin` class
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
        animateToNotifyNote(payload);
      }
      selectNotificationSubject.add(payload);
    });
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                // await Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         SecondScreen(receivedNotification.payload),
                //   ),
                // );
                print('didreceive');
              },
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      // await Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => SecondScreen(payload)),
      // );
      print('config: ' + payload);
      animateToNotifyNote(payload);
    });
  }

  loadUserData() async {
    _userRecord = await _customFirestore.loadUserData(useruid);
    if (_userRecord.isAdmin != null) {
      isAdmin = _userRecord.isAdmin;
    } else {
      isAdmin = false;
    }
    if (this.mounted) {
      setState(() {
        print('userdata image: ' + _userRecord.imageUrl);
      });
    }
  }

  animateToNotifyNote(uid) {
    int itemCount = snapshotdata.data.documents.length;
    print('Length: ' + itemCount.toString());
    print('searching start');
    for (int i = 0; i < itemCount; i++) {
      dSnapshot = snapshotdata.data.documents[i];
      print(dSnapshot.documentID);
      if (uid == dSnapshot.documentID) {
        print('found');
        pageController.animateToPage(
          i,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
    }
    print('end');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: _db
              .collection('users')
              .document(useruid)
              .collection('notes')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );

            if (snapshot.hasData) {
              // updateUserData(snapshot.data);
              snapshotdata = snapshot;

              return notesscreenui(snapshot, context);
            }
          }),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          int itemCount = snapshotdata.data.documents.length;
          print('itemCount: '+itemCount.toString());
          if (itemCount != 0) {
            DocumentSnapshot documentSnapshot =
                snapshotdata.data.documents[itemCount - 1];
            print(documentSnapshot.data['text']);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NoteEditScreen(documentSnapshot.data['chanelID'])),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NoteEditScreen(0)),
            );
          }
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
        elevation: 8.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, //
    );
  }

  notesscreenui(var snapshot, BuildContext context) {
    int itemCount = snapshot.data.documents.length;
    print('before Global.onLaunch: ' + Global.onLaunch.toString());
    if (!Global.editNote && !notificationAppLaunchDetails?.didNotificationLaunchApp ?? true) {
      Timer(
          Duration(seconds: 1),
          () => pageController.animateTo(
                pageController.position.maxScrollExtent + 800.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              )
          // print('item: ' +_scrollController.position.maxScrollExtent.toString())
          );
    }

    Global.editNote = false;

    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: MyClipper(),
            child: Container(
              height: 350.0,
              decoration: BoxDecoration(
                color: Color(0xffFACEC1),
                // borderRadius: BorderRadius.only(bottomRight: Radius.circular(50),),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Brood',
                  style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
                ),
                CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: NetworkImage(
                      _userRecord.imageUrl != null ? _userRecord.imageUrl : '',
                    ),
                    child: isAdmin
                        ? _selectAdminPopup(context)
                        : _selectPopup(context)),
              ],
            ),
          ),
          Positioned(
            top: 115,
            left: 20,
            child: Text(
              itemCount == 0
                  ? "You haven't added any word yet"
                  : 'Words to brood on',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 150, bottom: 100),
              child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: pageController,
                  itemCount: itemCount,
                  itemBuilder: (BuildContext context, int index) {
                    dSnapshot = snapshot.data.documents[index];
                    return NoteTextContainer(
                      dSnapshot.data['chanelID'],
                      color: (index % 2 == 0 && index != null)
                          ? Color(0xff269FBF)
                          : Color(0xffFC9574),
                      myNoteText: dSnapshot.data['text'],
                      timestamp: dSnapshot.data['timestamp'],
                      
                    );
                  })

              // ListView.builder(
              //   controller: _scrollController,
              //   scrollDirection: Axis.horizontal,
              //   shrinkWrap: true,
              //   itemCount: itemCount,
              //   itemBuilder: (context, int index) {
              //     dSnapshot = snapshot.data.documents[index];
              //     return NoteTextContainer(
              //       color: (index % 2 == 0 && index != null)
              //           ? Color(0xff269FBF)
              //           : Color(0xffFC9574),
              //       myNoteText: dSnapshot.data['text'],
              //       timestamp: dSnapshot.data['timestamp'],
              //     );
              //   },
              // ),
              )
        ],
      ),
    );
  }

  updateUserData(DocumentSnapshot snapshot) async {
    debugPrint('update user data');
    _userRecord = User.fromSnapshot(snapshot);
    User user = new User();
    user.setUID(useruid);
    user.setname(_userRecord.name);
    user.setEmail(_userRecord.email);
    user.setChanelId(_userRecord.chanelid);
    if (_userRecord.imageUrl != null) user.setImageUrl(_userRecord.imageUrl);
  }

  Widget _selectPopup(BuildContext context) => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text("Signout"),
          ),
        ],
        initialValue: 2,
        onCanceled: () {
          print("You have canceled the menu.");
        },
        onSelected: (value) {
          print("value:$value");
          _signOut(context);
        },
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.transparent,
        ),
      );

  Widget _selectAdminPopup(BuildContext context) => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text("Admin"),
          ),
          PopupMenuItem(
            value: 2,
            child: Text("Signout"),
          ),
        ],
        // initialValue: 2,
        onCanceled: () {
          print("You have canceled the menu.");
        },
        onSelected: (value) {
          print("value:$value");
          if (value == 2) {
            _signOut(context);
          } else if (value == 1) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return SetNotification();
              },
            ));
          }
        },
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.transparent,
        ),
      );

  Future<void> _signOut(BuildContext context) async {
    try {
      final BaseAuth auth = AuthProvider.of(context).auth;
      await auth.signOut();

      // //clear user data so when another user login with same phone, no unexpected data open
      // _userData.clearUserData();

      //due to some issue, i will navigate to login page manually
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return WelcomeScreen();
        },
      ));
    } catch (e) {
      print(e);
    }
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      ClampingScrollPhysics();

  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;
}

class NoteTextContainer extends StatelessWidget {
  final Color color;
  final myNoteText;
  final timestamp;
  final chanelid;
  NoteTextContainer(
    this.chanelid, {this.color, this.myNoteText, this.timestamp});

  //MediaQuery
  MediaQueryData _mediaQuery;
  //custom firestore
  CustomFirestore _customFirestore = new CustomFirestore();
  //local notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    _mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: GestureDetector(
        onTap: () {
          navigateToEditPage(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 35, horizontal: 20),
          width: _mediaQuery.size.width / 1.4,
          // height: _mediaQuery.size.height / 5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    MyUtils.getNoteDate(int.parse(timestamp)),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                      onTap: () {
                        _showDialog(context);
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      )),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: Text(
                  myNoteText,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Delete"),
          content: new Text("Are you sure you want to delete this note"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("Delete"),
              onPressed: () {
                _customFirestore.deleteNote(timestamp);
                //stop notification which is schedule if any
                _cancelNotification(chanelid);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void navigateToEditPage(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NoteEditScreen(
              chanelid, noteText: myNoteText, timestamp: timestamp)),
    );
  }

  Future<void> _cancelNotification(chanelid) async {
    await flutterLocalNotificationsPlugin.cancel(chanelid);
  }
}
