import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  var _timestamp;
  String _text;
  DocumentReference reference;

  //singleton logic
  static final Note note = Note._internal();
  Note._internal();
  factory Note() {
    return note;
  }

  //assert mean these fields are manditory, other can be null
  Note.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['date'] != null),
        assert(map['text'] != null),
        _timestamp = map['timestamp'],
        _text = map['text'];

  Note.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  get timestamp {
    return _timestamp;
  }

  get text {
    return _text;
  }

  void setTimestamp(Timestamp value) {
    this._timestamp = value;
  }

  void setText(String value) {
    this._text = value;
  }

}
