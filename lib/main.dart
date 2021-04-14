import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:memessenger/welcome_screen.dart';
import 'package:memessenger/register_screen.dart';
import 'package:memessenger/login_screen.dart';
import 'package:memessenger/chat_list.dart';
import 'package:memessenger/search_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    meMessenger(),
  );
}

class meMessenger extends StatefulWidget {
  @override
  _meMessengerState createState() => _meMessengerState();
}

class _meMessengerState extends State<meMessenger> {

  @override
  Widget build(BuildContext context) {

    FirebaseAuth _auth = FirebaseAuth.instance;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "meMessenger",
      initialRoute: _auth.currentUser != null && _auth.currentUser.emailVerified
          ? ChatList.route
          : WelcomeScreen.route,
      routes: {
        WelcomeScreen.route: (context) => WelcomeScreen(),
        RegisterScreen.route: (context) => RegisterScreen(),
        LoginScreen.route: (context) => LoginScreen(),
        ChatList.route: (context) => ChatList(),
        SearchScreen.route: (context) => SearchScreen(),
      },
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[100]
      ),
      //darkTheme: ThemeData.dark(),
    );
  }
}


