import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/utils/firestore.dart';
import 'package:notesapp/utils/notify.dart';

class SetNotification extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotificationState();
  }
}

class NotificationState extends State<SetNotification> {
  //textboxes controllers
  TextEditingController xC = TextEditingController();
  TextEditingController yC = TextEditingController();

  MediaQueryData mediaQuery;
  double gapFromBorder;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //custom firestore
  CustomFirestore _customFirestore = new CustomFirestore();
  Notify _notify = new Notify();

  @override
  void initState() {
    xC.text = _notify.X.toString();
    yC.text = _notify.Y.toString();
    super.initState();
  }

  @override
  void dispose() {
    xC.dispose();
    yC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mediaQuery = MediaQuery.of(context);
    gapFromBorder = mediaQuery.size.width / 1.1;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
        body: Form(
      key: _formKey,
      child: Center(
        child:
        Container(
          child: 
          SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Text(
                'Admin Panel',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                    color: Color(0xff269FBF)),
              ),
            ),
            settingPanel(),
          ],
        ),
      ),
    ))));
  }

  settingPanel() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          width: gapFromBorder,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1.0,
                ),
              ]),
          child: Padding(
              padding:
                  const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              child: Column(
                children: <Widget>[title(), xTextBox(), yTextBox(), updateBtn()],
              ))),
    );
  }

  title() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 20),
      child: Text(
        'Update Notification Time',
        style: TextStyle(fontSize: 17),
      ),
    );
  }

  xTextBox() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 20, top: 3, bottom: 3, right: 14),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black12)]),
            child: TextFormField(
              keyboardType: TextInputType.text,
              validator: validate,
              controller: xC,
              decoration: InputDecoration(
                  hintText: 'Enter X value',
                  border: InputBorder.none,
                  fillColor: Colors.blue),
            ),
          )
        ],
      ),
    );
  }

  yTextBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20),
      child: Container(
        padding: EdgeInsets.only(left: 20, top: 3, bottom: 3, right: 14),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black12)]),
        child: TextFormField(
          keyboardType: TextInputType.text,
          validator: validate,
          controller: yC,
          decoration: InputDecoration(
              hintText: 'Enter Y value',
              border: InputBorder.none,
              fillColor: Colors.blue),
        ),
      ),
    );
  }

  String validate(String value) {
    if (value.isEmpty || !isNumeric(value)) {
      return "Enter Valid Number";
    } else
      return null;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  updateBtn() {
    return Container(
        width: double.infinity,
        child: RaisedButton(
          padding: EdgeInsets.all(13),
          color: Color(0xff269FBF),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          onPressed: () {
            updateNotificationTime();
          },
          child: Text(
            'Update',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
          ),
        ));
  }

  updateNotificationTime() {
    if (_formKey.currentState.validate()) {
      _customFirestore.updateNotificationTime(int.parse(xC.text),int.parse(yC.text));
      Navigator.pop(context);
    }
  }
}
