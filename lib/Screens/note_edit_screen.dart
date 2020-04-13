import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notesapp/global.dart';
import 'package:notesapp/utils/User.dart';
import 'package:notesapp/utils/firestore.dart';
import 'package:notesapp/utils/important_methods.dart';
import 'package:intl/intl.dart';
import '../Components/RoundedButton.dart';
import 'package:notesapp/utils/notify.dart';

class NoteEditScreen extends StatefulWidget {
  final noteText;
  final timestamp;
  final chanelid;
  NoteEditScreen(this.chanelid, {this.noteText, this.timestamp, });
  @override
  State<StatefulWidget> createState() {
    return NoteEditScreenState(chanelid,noteText: noteText, timestamp: timestamp);
  }
}

class NoteEditScreenState extends State<NoteEditScreen> {
  var noteText;
  var timestamp;
  var chanelid;
  NoteEditScreenState(this.chanelid, {this.noteText, this.timestamp});

  //firestore
  CustomFirestore _customFirestore = new CustomFirestore();
  //TextField controller
  TextEditingController _noteTextController = new TextEditingController();
  //user data
  User _user = new User();
  Notify _notify = new Notify();

  //local notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    if (noteText != null) {
      _noteTextController.text = noteText;
    }
    if (timestamp == null) {
      chanelid = chanelid + 1;
    }
    print('chanel id: '+chanelid.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 70, bottom: 15),
            child: Text(
              timestamp != null
                  ? MyUtils.getNoteDate(int.parse(timestamp))
                  : MyUtils.formattedDate,
              style: TextStyle(
                fontSize: 38.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              child: SingleChildScrollView(
                child: TextFormField(
                  // initialValue: noteText != null ? noteText : null,
                  controller: _noteTextController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Your Text here',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  showCursor: true,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          RoundedButton(
            color: Color(0xff269FBF),
            buttonTitle: 'Save',
            onPressed: () {
              var ts = timestamp == null
                  ? DateTime.now().millisecondsSinceEpoch.toString()
                  : timestamp;
              //TODO
              _customFirestore.updateNote(
                  _user.uid, ts, _noteTextController.text, timestamp != null ? chanelid : chanelid);

              if (timestamp != null) {
                Global.editNote = true;
                Global.onLaunch = false;
              }

              _scheduleNotification(ts, _noteTextController.text, chanelid);

              Navigator.pop(context, true);
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => NotesScreen(''),
              //   ),
              // );
            },
          ),
          RoundedButton(
            color: Color(0xffFC9574),
            buttonTitle: 'Cancel',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  Future<void> _showNotification(timestamp, body) async {
    print('timestamp: ' + timestamp);
    print('X: '+_notify.X.toString());
    var date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    var formattedDate = DateFormat.yMMMd().format(date); //as a title

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, formattedDate, body, platformChannelSpecifics,
        payload: timestamp);
  }

  Future<void> _scheduleNotification(timestamp, body, chanelid) async {
    print('timestamp: ' + timestamp);
      print('X: '+_notify.X.toString());
    var date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    var formattedDate = DateFormat.yMMMd().format(date); //as a title

    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(days: _notify.X));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        priority: Priority.High,
        importance: Importance.Max);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics,);
    
    await flutterLocalNotificationsPlugin.schedule(
        chanelid,
        formattedDate,
        body,
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        payload: timestamp,
        androidAllowWhileIdle: true);
  }
}
