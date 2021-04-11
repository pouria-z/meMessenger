import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:memessenger/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memessenger/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {

  static String route = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  String messageText;
  UserCredential loggedInUser;
  final messageTextController = TextEditingController();

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() {
    final user = _auth.currentUser.email;
    if (user != null){
      print(user);
    }
  }

  void sendMessage() {
    messageTextController.clear();
    final DateTime now = DateTime.now();
    var hour = now.hour.toString();
    var min = now.minute.toString();
    var minuteplus0 = hour+":"+"0"+min;
    var time = min.length==2 ? hour+":"+min : minuteplus0;
    var docname = now.toLocal();
    _firestore.collection('messages').doc("$docname").set({
      'text': messageText,
      'sender': _auth.currentUser.email,
      'time': time,
    },);
  }

  Future<bool> onWillPop () {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Chat"),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _auth.signOut();
                Navigator.pushNamed(context, WelcomeScreen.route);
              },
            ),
          ],
        ),
        body: SafeArea(
          minimum: EdgeInsets.only(bottom: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MessageStream(),
            ],
          ),
        ),
        bottomSheet: Material(
          color: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onChanged: (value) {
                    messageText = value;
                  },
                  controller: messageTextController,
                  decoration: messageInputDecoration.copyWith(
                    hintText: "Message",
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        sendMessage();
                      },
                    ),
                    suffixIconConstraints: BoxConstraints()
                  ),
                  cursorColor: Colors.blueAccent,
                  cursorHeight: 18,
                  cursorWidth: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
            ),
          );
        }
        final messages = snapshot.data.docs.reversed;
        List<Widget> messagesBubbles = [];
        for (var message in messages){
          final messageText = message.get("text");
          final messageSender = message.get("sender");
          final messageTime = message.get("time");
          final messageBubble = messageSender==_auth.currentUser.email ?
          MessageBubble(sender: messageSender, text: messageText, time: messageTime,) :
          MessageBubbleReceiver(sender: messageSender, text: messageText, time: messageTime,);
          messagesBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messagesBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {

  final String text;
  final String sender;
  final String time;

  const MessageBubble({Key key, this.text, this.sender, this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(left: MediaQuery.of(context).size.width/4),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              sender,
              style: myTextStyle.copyWith(
                color: Colors.black38,
                fontSize: 12,
              ),
            ),
            Material(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20), topLeft: Radius.circular(20),
              ),
              elevation: 5,
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      text,
                      style: myTextStyle.copyWith(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      time,
                      style: myTextStyle.copyWith(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubbleReceiver extends StatelessWidget {

  final String text;
  final String sender;
  final String time;

  const MessageBubbleReceiver({Key key, this.text, this.sender, this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(right: MediaQuery.of(context).size.width/4),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: myTextStyle.copyWith(
                color: Colors.black38,
                fontSize: 12,
              ),
            ),
            Material(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20), topRight: Radius.circular(20),
              ),
              elevation: 5,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      text,
                      style: myTextStyle.copyWith(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      time,
                      style: myTextStyle.copyWith(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
