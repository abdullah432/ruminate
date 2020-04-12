import 'package:cloud_firestore/cloud_firestore.dart';

class Notify {
  int _X;
  int _Y;
  DocumentReference reference;

  //singleton logic
  static final Notify user = Notify._internal();
  Notify._internal();
  factory Notify() {
    return user;
  }

  //assert mean these fields are manditory, other can be null
  Notify.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['X'] != null),
        assert(map['Y'] != null),
        _X = map['X'],
        _Y = map['Y'];

  Notify.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  get X {
    return _X;
  }

  get Y {
    return _Y;
  }

  void setX(int value) {
    this._X = value;
  }

  void setY(int value) {
    this._Y = value;
  }

}
