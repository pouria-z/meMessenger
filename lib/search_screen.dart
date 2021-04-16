import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memessenger/chat_screen.dart';
import 'package:memessenger/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
QuerySnapshot searchSnapshot;

class SearchScreen extends StatefulWidget {

  static String route = "search_screen";

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  bool isLoading = false;
  String search;

  void getUsername(value) async {
    setState(() {
      isLoading = true;
    });
    await _firestore.collection('users').where('username',isEqualTo: value).get()
        .then((value) {
          setState(() {
            searchSnapshot=value;
          });
        },
    );
    setState(() {
      isLoading = false;
    });
  }

  Widget searchList() {
    return searchSnapshot!= null ? ListView.builder(
      shrinkWrap: true,
      itemCount: searchSnapshot.docs.length,
      itemBuilder: (context, index) {
        return SearchTile(
          userName: searchSnapshot.docs[index].get('username'),
        );
      },
    ) :
    Expanded(
      child: Hero(
        tag: "search",
        child: Material(
          color: Colors.transparent,
          child: Icon(
            Icons.search_rounded,
            size: 200,
            color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    ///don't cache the searchSnapshot
    searchSnapshot=null;
    ///print the loggedInUser
    print(_auth.currentUser.email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              onSubmitted: getUsername,
              onChanged: (value) {
                search = value;
                setState(() {
                  getUsername(search);
                });
              },
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: messageInputDecoration.copyWith(
                hintText: "Search",
                hintStyle: TextStyle(
                  color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white54 : Colors.black45,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white54 : Colors.black54,
                  )
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white38 : Colors.black38,
                  ),
                  borderRadius: BorderRadius.zero,
                ),
                suffixIcon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white54 : Colors.black54,
                ),
              ),
              cursorColor: Colors.blueAccent,
              cursorHeight: 18,
              cursorWidth: 1.5,
            ),
            isLoading==true ? Column(
              children: [
                SizedBox(height: 10,),
                CircularProgressIndicator(strokeWidth: 1,),
              ],
            ) : Container(),
            searchList(),
          ],
        ),
      ),
    );
  }
}

class SearchTile extends StatelessWidget {

  final String userName;

  void createChatRoom(context) {
    if(_auth.currentUser.email!=searchSnapshot.docs[0].get('email')) {
      try {
        List<String> users = [
          searchSnapshot.docs[0].get('email'),
          _auth.currentUser.email
        ];
        Map<String, dynamic> chatRoomMap = {
          'users': users,
          'chatroomId' : getChatRoomId(_auth.currentUser.email, searchSnapshot.docs[0].get('email')),
          'lastMessage': "",
          'lastMessageSender': "",
          'lastMessageTime': "",
        };
        _firestore.collection('chatRoom')
            .doc("${getChatRoomId(
            _auth.currentUser.email,
            searchSnapshot.docs[0].get('email'))}")
            .set(chatRoomMap);
        Navigator.pushReplacement(context, CupertinoPageRoute(
          builder: (context) => ChatScreen(
            getChatRoomId(
                _auth.currentUser.email,
                searchSnapshot.docs[0].get('email')
            ),
          ),
        ),);
      }
      catch (e) {
        print(e);
      }
    }
    else if(_auth.currentUser.email==searchSnapshot.docs[0].get('email')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "You can't chat with yourself :)"
          ),
        ),
      );
    }
  }

  const SearchTile({Key key, this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            userName,
            style: myTextStyleBold.copyWith(
              color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white : Colors.black,
            ),
          ),
          trailing: GestureDetector(
            onTap: () {
              createChatRoom(context);
            },
            child: Container(
              width: MediaQuery.of(context).size.width/5,
              height: MediaQuery.of(context).size.height/22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[900],
                    Colors.blueAccent,
                  ],
                  begin: Alignment.bottomRight,
                  end: Alignment.centerLeft,
                ),
              ),
              child: Center(
                child: Text(
                  "Message",
                  style: myTextStyle.copyWith(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }

}

getChatRoomId(String a, String b) {
  if(a.substring(0,1).codeUnitAt(0) > b.substring(0,1).codeUnitAt(0)){
    return "$b\_$a";
  }
  else {
    return "$a\_$b";
  }
}

