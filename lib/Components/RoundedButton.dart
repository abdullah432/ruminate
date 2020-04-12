import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({this.color, this.buttonTitle, this.onPressed});
  final Color color;
  final String buttonTitle;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 300.0,
          height: 55.0,
          child: Text(
            buttonTitle,
            style: TextStyle(color: Colors.white, fontSize: 15.0),
          ),
        ),
      ),
    );
  }
}
