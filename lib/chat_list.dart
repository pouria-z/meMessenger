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
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:memessenger/my_icon.dart';

final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ChatList extends StatefulWidget {

  static String route = "chat_list";

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  bool isDark = false;

  @override
  void initState() {
    super.initState();
    getThemeValue();
  }

  getThemeValue() async {
    isDark = await getThemeState();
  }

  Future<bool> saveThemeValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("themeValue", value);
    print('Is theme dark? $value');
  }

  Future<bool> getThemeState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool stringValue = prefs.getBool("themeValue");
    print(stringValue);
    return isDark;
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
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_arrow,
        curve: Curves.bounceIn,
        heroTag: 'floating',
        tooltip: 'Menu',
        elevation: 5,
        backgroundColor: Color(0xFF524C97),
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        activeBackgroundColor: Colors.red,
        overlayColor: AdaptiveTheme.of(context).mode.isDark ? Colors.black12 : Colors.white12,
        children: [
          SpeedDialChild(
            child: Icon(Icons.logout),
            backgroundColor: Color(0xFF524C97),
              foregroundColor: Theme.of(context).scaffoldBackgroundColor,
            onTap: () {
              _auth.signOut();
              Navigator.pushReplacementNamed(context, WelcomeScreen.route);
            }
          ),
          SpeedDialChild(
            child: AdaptiveTheme.of(context).mode.isDark
                ? Icon(Icons.wb_sunny_outlined)
                : Icon(MyIcons.moon),
            backgroundColor: Color(0xFF524C97),
            foregroundColor: Theme.of(context).scaffoldBackgroundColor,
            onTap: () {
              setState(() {
                isDark=!isDark;
                saveThemeValue(isDark);
                AdaptiveTheme.of(context).mode.isLight
                    ? AdaptiveTheme.of(context).setDark()
                    : AdaptiveTheme.of(context).setLight();
              });
            }
          ),
        ],
      )
    );
  }
}

class ChatStreamer extends StatefulWidget {
  @override
  _ChatStreamerState createState() => _ChatStreamerState();
}
class _ChatStreamerState extends State<ChatStreamer> {
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
                  fontSize: 24,
                  color: AdaptiveTheme.of(context).mode.isDark ? Colors.white38 : Colors.black38,
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
          },
        ),
      ],
    );
  }
}


