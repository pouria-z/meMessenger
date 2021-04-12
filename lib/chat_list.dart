import 'dart:math';
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
final _firestore = FirebaseFirestore.instance;

class ChatList extends StatefulWidget {

  static String route = "chat_list";

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  @override
  void initState() {
    ChatStreamer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: "text",
          child: Material(
            color: Colors.transparent,
            child: Text(
              "meMessenger",
              style: myTextStyleBold.copyWith(
                fontSize: 21,
              ),
            ),
          ),
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
      body: ChatStreamer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _auth.signOut();
          Navigator.pushReplacementNamed(context, WelcomeScreen.route);
        },
        child: Icon(Icons.logout),
        heroTag: "floating",
      ),
    );
  }
}

class ChatStreamer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chatRoom').where("users",arrayContains: _auth.currentUser.email).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
            ),
          );
        }
        final chats = snapshot.data.docs.reversed;
        List<Widget> chatsTiles = [];
        for(var chat in chats){
          final title = chat.data().entries.last.value.toString().replaceAll("_", "").replaceAll(_auth.currentUser.email, "");
          final roomId = chat.data().entries.last.value.toString();
          final thing = ChatTile(
            title: title,
            chatRoomId: roomId,
          );
          chatsTiles.add(thing);
        }
        return ListView(
          padding: EdgeInsets.symmetric(vertical: 10),
          children: chatsTiles,
        );
      },
    );
  }
}

class ChatTile extends StatelessWidget {

  final String title;
  final String chatRoomId;

  const ChatTile({Key key, this.title, this.chatRoomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.primaries[Random().nextInt(Colors.primaries.length)],
            radius: 25,
            child: Text(
              title.substring(0,1).toUpperCase(),
              textAlign: TextAlign.center,
              style: myTextStyleBold.copyWith(
                fontSize: 24,
              ),
            ),
          ),
          title: Text(
            title,
            style: myTextStyleBold.copyWith(
              color: Colors.black,
            ),
          ),
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(builder: (context) => ChatScreen(chatRoomId),));
          }
        ),
        Divider(),
      ],
    );
  }
}


