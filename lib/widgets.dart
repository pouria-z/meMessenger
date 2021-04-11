import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:memessenger/welcome_screen.dart';

TextStyle myTextStyle = TextStyle(
  color: Colors.white,
  fontFamily: "Roboto",
  fontSize: 18,
);
TextStyle myTextStyleBold = TextStyle(
  color: Colors.white,
  fontFamily: "Roboto",
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

InputDecoration myInputDecoration = InputDecoration(
  isDense: true,
  hintText: "value",
  hintStyle: myTextStyle.copyWith(
    fontSize: 14,
    color: Colors.black38,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(
      color: Colors.black54,
    ),
  ),
  labelText: "value",
  labelStyle: myTextStyle.copyWith(
    color: Colors.black38,
    fontSize: 14,
  ),
);

InputDecoration messageInputDecoration = InputDecoration(
  hintText: "value",
  hintStyle: myTextStyle.copyWith(
    fontSize: 14,
    color: Colors.black38,
  ),
  border: OutlineInputBorder(),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black54),
    borderRadius: BorderRadius.zero,
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent),
    borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
  ),

);

class MyButton extends StatelessWidget {

  final String title;
  final Widget widget;
  final Color color;
  final Function onPressed;

  const MyButton({Key key,@required this.title,@required this.color,@required this.onPressed,this.widget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(25),
      elevation: 5,
      child: MaterialButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$title",
              style: myTextStyleBold.copyWith(
                fontSize: 12,
              ),
            ),
            widget,
          ],
        ),
        height: MediaQuery.of(context).size.height/20,
        minWidth: MediaQuery.of(context).size.width,
      ),
    );
  }
}


