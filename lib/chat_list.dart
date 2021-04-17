import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memessenger/chat_screen.dart';
import 'package:memessenger/search_screen.dart';
import 'package:memessenger/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memessenger/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ChatList extends StatefulWidget {

  static String route = "chat_list";

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  String _chosenValue;

  @override
  void initState() {
    super.initState();
    getThemeValue();
  }

  getThemeValue() async {
    _chosenValue = await getThemeState();
  }

  Future<String> saveThemeValue(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("themeValue", value);
    print('Theme mode saved $value');
  }

  Future<String> getThemeState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString("themeValue");
    print(stringValue);
    return stringValue;
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
      drawer: Drawer(
        child: SafeArea(
          child: ListTile(
            title: Text(
              "Theme",
              style: myTextStyle.copyWith(
                color: AdaptiveTheme.of(context).mode.isDark ? Colors.white
                    : Colors.black,
              ),
            ),
            trailing: DropdownButton<String>(
              icon: Icon(Icons.arrow_drop_down_rounded),
              value: _chosenValue,
              onChanged: (String value) {
                setState(() {
                  _chosenValue = value;
                  saveThemeValue(_chosenValue);
                  _chosenValue=='Light' && AdaptiveTheme.of(context).mode.isDark
                      ? AdaptiveTheme.of(context).setLight()
                  : _chosenValue=='Light' && AdaptiveTheme.of(context).mode.isLight
                      ? null
                  : _chosenValue=='Dark' && AdaptiveTheme.of(context).mode.isLight
                      ? AdaptiveTheme.of(context).setDark()
                  : null;
                });
              },
              items: <String>[
                'Light',
                'Dark',
              ]
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
      body: ChatStreamer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _auth.signOut();
          Navigator.pushReplacementNamed(context, WelcomeScreen.route);
        },
        child: Icon(
          Icons.logout,
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        heroTag: "floating",
      ),
    );
  }
}

class ChatStreamer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chatRoom')
          .where("users", arrayContains: _auth.currentUser.email)
          .snapshots(),
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
            ),
          );
        }
        if(snapshot.data.docs.isEmpty){
          return Center(
            child: Text(
              "No Chat Yet!",
              style: myTextStyle.copyWith(
                  fontSize: 24,color: Colors.black38
              ),
            ),
          );
        }
        final chats = snapshot.data.docs;
        List<ChatTile> chatsTiles = [];
        for(var chat in chats){
          final title = chat.get('chatroomId').toString().replaceAll("_", "")
              .replaceAll(_auth.currentUser.email, "");
          final roomId = chat.get('chatroomId');
          final lastMessage = chat.get('lastMessage');
          final lastMessageSender = chat.get('lastMessageSender');
          final lastMessageTime = chat.get('lastMessageTime');
          final chatTile = ChatTile(
            title: title,
            chatRoomId: roomId,
            lastMessage: lastMessage,
            lastMessageSender: lastMessageSender,
            lastMessageTime: lastMessageTime,
          );
          chatsTiles.add(chatTile);
        }
        return ListView(
          children: chatsTiles,
        );
      },
    );
  }
}

class ChatTile extends StatelessWidget {

  final String title;
  final String chatRoomId;
  final String lastMessage;
  final String lastMessageSender;
  final String lastMessageTime;

  const ChatTile({Key key, this.title, this.chatRoomId, this.lastMessage,
    this.lastMessageSender, this.lastMessageTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
              color: AdaptiveTheme.of(context).mode.isDark ? Colors.white : Colors.black,
              fontSize: 15,
            ),
          ),
          subtitle: lastMessageSender==_auth.currentUser.displayName ? Row(
            children: [
              Text(
                "You: ",
                style: myTextStyle.copyWith(
                    color: AdaptiveTheme.of(context).mode.isDark ? Colors.white54 : Colors.black45,
                    fontSize: 14,
                ),
              ),
              Text(
                lastMessage.length > 30 ? lastMessage.substring(0,30) + "..." : lastMessage,
                style: myTextStyle.copyWith(
                    color: AdaptiveTheme.of(context).mode.isDark ? Colors.white54 : Colors.black45,
                    fontSize: 14,
                ),
              ),
            ],
          ) :
          Text(
            lastMessage.length > 35 ? lastMessage.substring(0,35) + "..." : lastMessage,
            style: myTextStyle.copyWith(
              color: AdaptiveTheme.of(context).mode.isDark ? Colors.white54 : Colors.black45,
              fontSize: 14,
            ),
          ),
          trailing: Text(
            lastMessageTime,
            style: myTextStyle.copyWith(
              color: AdaptiveTheme.of(context).mode.isDark ? Colors.white54 : Colors.black45,
              fontSize: 14,
            ),
          ),
          onTap: () {
            Navigator.push(context, CupertinoPageRoute(
              builder: (context) => ChatScreen(chatRoomId),
            ));
          }
        ),
      ],
    );
  }
}


