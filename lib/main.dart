import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:memessenger/welcome_screen.dart';
import 'package:memessenger/register_screen.dart';
import 'package:memessenger/login_screen.dart';
import 'package:memessenger/chat_screen.dart';
import 'package:memessenger/chat_list.dart';
import 'package:memessenger/search_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memessenger/chat_list.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(meMessenger());
}

class meMessenger extends StatefulWidget {
  @override
  _meMessengerState createState() => _meMessengerState();
}

class _meMessengerState extends State<meMessenger> {

  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    //initializeFlutterFire();
    // Firebase.initializeApp().whenComplete(() {
    //   print("completed");
    //   setState(() {});
    // });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    // if(_error) {
    //   print("SomethingWentWrong");
    // }
    //
    // // Show a loader until FlutterFire is initialized
    // if (!_initialized) {
    //   print("loading...");
    // }
    FirebaseAuth _auth = FirebaseAuth.instance;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "meMessenger",
      initialRoute: _auth.currentUser != null && _auth.currentUser.emailVerified ? ChatList.route : WelcomeScreen.route,
      routes: {
        WelcomeScreen.route: (context) => WelcomeScreen(),
        RegisterScreen.route: (context) => RegisterScreen(),
        LoginScreen.route: (context) => LoginScreen(),
        //ChatScreen.route: (context) => ChatScreen(),
        ChatList.route: (context) => ChatList(),
        SearchScreen.route: (context) => SearchScreen(),
      },
      theme: ThemeData.light(),
      //darkTheme: ThemeData.dark(),
    );
  }
}


