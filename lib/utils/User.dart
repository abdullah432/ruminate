import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String _name;
  String _email;
  String _imageUrl;
  var _uid;
  bool _isAdmin;
  int _chanelid;
  DocumentReference reference;

  //singleton logic
  static final User user = User._internal();
  User._internal();
  factory User() {
    return user;
  }

  //assert mean these fields are manditory, other can be null
  User.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['email'] != null),
        _name = map['name'],
        _email = map['email'],
        _isAdmin = map['admin'],
        _chanelid = map['chanelID'],
        _imageUrl = map['profileurl'];

  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  get name {
    return _name;
  }

  get email {
    return _email;
  }

  get imageUrl {
    return _imageUrl;
  }

  get uid {
    return _uid;
  }

  get isAdmin {
    return _isAdmin;
  }

  get chanelid {
    return _chanelid;
  }

  void setname(String value) {
    this._name = value;
  }

  void setEmail(String value) {
    this._email = value;
  }

  void setImageUrl(String value) {
    this._imageUrl = value;
  }

  void setUID(var value) {
    this._uid = value;
  }

  void setIsAdmin(value) {
    this._isAdmin = value;
  }

  void setChanelId(value) {
    this._chanelid = value;
  }

  void clearUserData() {
    _name = '';
    _email = '';
    _imageUrl = '';
    _uid = '';
  }
}
