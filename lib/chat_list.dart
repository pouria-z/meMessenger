import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memessenger/chat_screen.dart';
import 'package:memessenger/search_screen.dart';
import 'package:memessenger/widgets.dart';
import 'package:memessenger/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memessenger/welcome_screen.dart';

final _auth = FirebaseAuth.instance;

class ChatList extends StatefulWidget {

  static String route = "chat_list";

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "meMessenger",
          style: myTextStyleBold,
        ),
        elevation: 5,
        actions: [
          Hero(
            tag: "search",
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(Icons.search_rounded),
                onPressed: () {
                  Navigator.pushNamed(context, SearchScreen.route);
                },
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          "No Chat Found!",
          style: myTextStyle.copyWith(
            color: Colors.black38
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _auth.signOut();
          Navigator.pushNamed(context, WelcomeScreen.route);
        },
        child: Icon(Icons.logout),
      ),
    );
  }
}
