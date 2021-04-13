import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:memessenger/chat_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memessenger/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memessenger/search_screen.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
String messageText;
final messageTextController = TextEditingController();

class ChatScreen extends StatefulWidget {

  final String chatRoomId;
  static String lastMessage;
  ChatScreen(this.chatRoomId);

  static String route = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  UserCredential loggedInUser;

  Stream<QuerySnapshot> chatStream;
  String path;

  @override
  void initState() {
    getCurrentUser();
    chatStream = _firestore.collection('chatRoom').doc("${widget.chatRoomId}").collection('messages').snapshots();
    path = widget.chatRoomId;
    super.initState();
  }

  void getCurrentUser() {
    final user = _auth.currentUser.email;
    if (user != null){
      print(user);
    }
  }

  void sendMessage() {

    if(messageTextController.text.isEmpty){
      return null;
    }
    else {
      messageTextController.clear();
      final DateTime now = DateTime.now();
      var hour = now.hour.toString();
      var min = now.minute.toString();
      var minuteplus0 = hour+":"+"0"+min;
      var time = min.length==2 ? hour+":"+min : minuteplus0;
      var chatdocname = now.toLocal();
      _firestore.collection('chatRoom').doc("${widget.chatRoomId}").collection('messages').doc("$chatdocname").set({
        'text': messageText,
        'sender': _auth.currentUser.displayName,
        'time': time,
        'id' : "$chatdocname",
      },);
      _firestore.collection('chatRoom').doc("${widget.chatRoomId}").update({
        'lastMessage': messageText,
        'lastMessageSender': _auth.currentUser.displayName,
        'lastMessageTime': time,
      });
    }
  }

  Future<bool> onWillPop() {
    Navigator.pop(context, ChatList.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: true,
        title: Hero(
          tag: "text",
          child: Material(
            color: Colors.transparent,
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(path.toString().replaceAll("_", "").replaceAll(_auth.currentUser.email, ""),
                  textStyle: myTextStyleBold,
                  speed: Duration(milliseconds: 12),
                ),
              ],
              totalRepeatCount: 1,
            ),
          ),
        ),
        leading: Hero(
          tag: "floating",
          child: Material(
            color: Colors.transparent,
            child: BackButton(
              onPressed: onWillPop,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        minimum: EdgeInsets.only(bottom: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: chatStream,
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
                      "No Message Yet!",
                      style: myTextStyle.copyWith(
                          fontSize: 20,color: Colors.black38
                      ),
                    ),
                  );
                }
                final messages = snapshot.data.docs.reversed;
                ChatScreen.lastMessage = snapshot.data.docs.last.get('text');
                List<Widget> messagesBubbles = [];
                for (var message in messages){
                  final messageText = message.get("text");
                  final messageSender = message.get("sender");
                  final messageTime = message.get("time");
                  final messageId = message.get("id");
                  final messageBubble = messageSender==_auth.currentUser.displayName ?
                  MessageBubble(sender: messageSender, text: messageText, time: messageTime, messageId: messageId, docName: path) :
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
            ),
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
    );
  }
}

class MessageBubble extends StatelessWidget {

  String text;
  final String sender;
  final String time;
  final String messageId;
  final String docName;

  MessageBubble({Key key, this.text, this.sender, this.time, this.messageId, this.docName});

  void updateMessage(context) {

    if(text.isEmpty){
      return null;
    }
    else {
      try{
        _firestore.collection("chatRoom").doc(docName).collection("messages").doc(messageId).update(
            {
              "text" : text,
            }
        );
        Navigator.pop(context);
        messageTextController.clear();
      }
      catch(e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(left: MediaQuery.of(context).size.width/4),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 7),
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
            GestureDetector(
              onLongPress: () {
                showModalBottomSheet(context: context,
                builder: (context) {
                  return Container(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: Icon(Icons.edit_rounded),
                          title: Text("Edit"),
                          onTap: () {
                            Navigator.pop(context);
                            showModalBottomSheet(context: context,
                              builder: (context) {
                                return TextFormField(
                                  autofocus: true,
                                  onChanged: (value) {
                                    text = value;
                                  },
                                  initialValue: text,
                                  decoration: messageInputDecoration.copyWith(
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.zero
                                    ),
                                    hintText: "Edit Message",
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.check),
                                      onPressed: () {
                                        updateMessage(context);
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.delete_rounded),
                          title: Text("Delete"),
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "Delete Message",
                                    style: myTextStyleBold.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  content: Text(
                                    "Are you sure you want to delete this message for both sides?",
                                    style: myTextStyle.copyWith(
                                      color: Colors.black54
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: myTextStyleBold.copyWith(
                                          color: Colors.black54,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        try{
                                          _firestore.collection("chatRoom").doc(docName).collection("messages").doc(messageId).delete();
                                        }
                                        catch(e) {
                                          print(e);
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Delete",
                                        style: myTextStyleBold.copyWith(
                                          color: Colors.red,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                 },
                );
              },
              child: Material(
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
      minimum: EdgeInsets.only(right: MediaQuery.of(context).size.width/4, bottom: 0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 7),
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
