import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:memessenger/chat_list.dart';
import 'package:memessenger/welcome_screen.dart';
import 'package:memessenger/chat_screen.dart';
import 'package:memessenger/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';



class LoginScreen extends StatefulWidget {

  static String route = "login_screen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool isLoading = false;

  @override
  void initState() {
    //_auth.currentUser.reload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: "icon",
              child: Image.asset(
                'assets/icon/icon.png',
                width: MediaQuery.of(context).size.width/2,
                height: MediaQuery.of(context).size.height/6,
              ),
            ),
            TextFormField(
              onChanged: (value) {
                email = value;
              },
              validator: (value) {
                if(value.isEmpty || !value.contains("@") || !value.endsWith(".com")){
                  return "Please Enter a Valid Email Address!";
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.emailAddress,
              decoration: myInputDecoration.copyWith(
                hintText: "ENTER YOUR EMAIL ADDRESS",
                labelText: "EMAIL",
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/80,),
            TextFormField(
              onChanged: (value) {
                password = value;
              },
              textAlign: TextAlign.center,
              obscureText: true,
              decoration: myInputDecoration.copyWith(
                hintText: "ENTER YOUR PASSWORD",
                labelText: "PASSWORD",
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/50,),
            Hero(
              tag: "login",
              child: MyButton(
                title: isLoading==false ? "LOGIN" : "",
                color: Colors.blue[500],
                onPressed: () async {
                  try{
                    if (email.isNotEmpty && password.isNotEmpty){
                      setState(() {
                        isLoading = true;
                      });
                      var newUser = await _auth.signInWithEmailAndPassword(email: email, password: password);
                      newUser.user.emailVerified ?
                      Navigator.pushReplacementNamed(context, ChatList.route) : ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Email has not been verified yet!"),
                        ),
                      );
                    }
                  }
                  catch (e) {
                    print(e);
                    if(e.toString()=="[firebase_auth/wrong-password] The password"
                        " is invalid or the user does not have a password."){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("The password is incorrect!"),
                        ),
                      );
                    }
                    else if(e.toString()=="[firebase_auth/invalid-email] The "
                        "email address is badly formatted."){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Invalid email address!"),
                        ),
                      );
                    }
                    else if(e.toString()=="[firebase_auth/user-not-found] There is no user record corresponding"
                        " to this identifier. The user may have been deleted."){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("User not found!"),
                        ),
                      );
                    }
                    else if(e.toString()=="[firebase_auth/too-many-requests] We have blocked all requests"
                        " from this device due to unusual activity. Try again later."){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Too many requests! Try again later."),
                        ),
                      );
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error 403 (Forbidden)"),
                        ),
                      );
                    }
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
                widget: isLoading==false ? SizedBox(width: 0,) : SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    strokeWidth: 1,
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
