import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memessenger/chat_screen.dart';
import 'package:memessenger/widgets.dart';
import 'package:memessenger/chat_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
String search;
QuerySnapshot searchSnapshot;
QuerySnapshot snapshot;
final loggedInUser = _auth.currentUser.email;

class SearchScreen extends StatefulWidget {

  static final currentUser = _auth.currentUser.email;
  static final otherUser = searchSnapshot.docs[0].get('email');
  static final docName = getChatRoomId(SearchScreen.currentUser, SearchScreen.otherUser);
  static String route = "search_screen";

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  bool isLoading = false;


  void getusername(search) async {
    setState(() {
      isLoading = true;
    });
    await _firestore.collection('users').where('username',isEqualTo: search).get()
        .then((search) {
          setState(() {
            searchSnapshot=search;
          });
        },
    );
    setState(() {
      isLoading = false;
    });

  }

  Widget searchList(){

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
          child: Icon(Icons.search_rounded, size: 200, color: Colors.black12,),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Column(
          children: [
            TextField(
              onSubmitted: getusername,
              onChanged: (value) {
                search = value;
                getusername(search);
              },
              textInputAction: TextInputAction.search,
              decoration: messageInputDecoration.copyWith(
                hintText: "Search",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12),
                ),
                suffixIcon: Material(
                  color: Colors.transparent,
                  child: Icon(Icons.search_rounded),
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
            ) : SizedBox(height: 0,),
            searchList(),
          ],
        ),
      ),

    );
  }
}

class SearchTile extends StatelessWidget {

  final String userName;

  const SearchTile({Key key, this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            userName,
            style: myTextStyleBold.copyWith(
              color: Colors.black
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
                  tileMode: TileMode.mirror,
                  begin: Alignment.bottomRight,
                  end: Alignment.centerLeft,
                ),
              ),
              child: Center(
                child: Text(
                  "Message",
                  style: myTextStyle.copyWith(
                    fontSize: 12
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

  void createChatRoom(context) {

    if(SearchScreen.currentUser!=SearchScreen.otherUser) {
      try {
        _firestore.collection('chatRoom').doc("${SearchScreen.docName}").set({
          "chatroomId": SearchScreen.docName,
          "users": {
            "username": SearchScreen.currentUser,
            "username2": SearchScreen.otherUser,
          }
        });
        Navigator.pushNamed(context, ChatScreen.route);
      } catch (e) {
        print(e);
      }
    }
    else if(SearchScreen.currentUser==SearchScreen.otherUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "You can't chat with yourself :)"
          ),
        ),
      );
    }

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




