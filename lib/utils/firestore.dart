import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notesapp/utils/User.dart';
import 'package:notesapp/utils/notify.dart';

class CustomFirestore {
  User _user = new User();
  Notify _notify = new Notify();
  final db = Firestore.instance;

  Future<bool> updateNote(id, timestamp, String text, int chanelid) async {
    try {
      await db
          .collection("users")
          .document(id)
          .collection('notes')
          .document(timestamp)
          .setData({
        'timestamp': timestamp,
        'text': text,
        'id': id,
        'chanelID': chanelid
      }).whenComplete(() {
        return true;
      }).catchError((onError) {
        print('error during adding service: ' + onError.toString());
        return false;
      });
    } catch (e) {
      print('exception during adding service: ' + e.toString());
      return false;
    }
    return true;
  }

  Future<bool> deleteNote(timestamp) async {
    try {
      await db
          .collection("users")
          .document(_user.uid)
          .collection('notes')
          .document(timestamp)
          .delete()
          .whenComplete(() {
        return true;
      }).timeout(Duration(seconds: 10), onTimeout: () {
        // handle transaction timeout here
      }).catchError((onError) {
        print('error during adding service: ' + onError.toString());
        return false;
      });
    } catch (e) {
      print('exception during adding service: ' + e.toString());
      return false;
    }
    return true;
  }

  Future<User> loadUserData(useruid) async {
    var snapshot = await db.collection('users').document(useruid).get();
    User userRecord = User.fromSnapshot(snapshot);
    _user.setUID(useruid);
    _user.setname(userRecord.name);
    _user.setEmail(userRecord.email);
    _user.setImageUrl(userRecord.imageUrl);
    _user.setChanelId(userRecord.chanelid);
    if (_user.isAdmin != null) {
      _user.setIsAdmin(userRecord.isAdmin);
    } else {
      _user.setIsAdmin(false);
    }

    return userRecord;
  }

  loadNotifyData() async {
    var snapshot =
        await db.collection('notifytimming').document('timing').get();

    Notify notifyRecord = Notify.fromSnapshot(snapshot);
    _notify.setX(notifyRecord.X);
    _notify.setY(notifyRecord.Y);

    // return notifyRecord;
  }

  Future<bool> updateNotificationTime(int X, int Y) async {
    try {
      await db.collection("notifytimming").document('timing').setData({
        'X': X,
        'Y': Y,
      }).whenComplete(() {
        loadNotifyData();
        return true;
      }).catchError((onError) {
        print('error during adding service: ' + onError.toString());
        return false;
      });
    } catch (e) {
      print('exception during adding service: ' + e.toString());
      return false;
    }
    return true;
  }
}
