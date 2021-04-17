import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:memessenger/chat_list.dart';
import 'package:memessenger/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adaptive_theme/adaptive_theme.dart';


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
  bool emailIsValid = false;
  bool passwordIsValid = false;
  bool hidePassword = true;

  String validateEmail(String value) {
    Pattern pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value == null) {
      Future.delayed(Duration.zero).then((_){
        setState((){
          emailIsValid = false;
        });
      });
      return 'Please Enter a Valid Email Address!';
    } else {
      Future.delayed(Duration.zero).then((_){
        setState((){
          emailIsValid = true;
        });
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Hero(
                tag: "icon",
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: MediaQuery.of(context).size.width/2,
                  height: MediaQuery.of(context).size.height/5,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/80,),
            ///Email Field
            TextFormField(
              onChanged: (value) {
                email = value;
              },
              cursorHeight: 18,
              cursorWidth: 1.5,
              validator: validateEmail,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.emailAddress,
              decoration: myInputDecoration.copyWith(
                hintText: "Enter Your Email Address",
                hintStyle: myTextStyle.copyWith(
                  fontSize: 14,
                  color: AdaptiveTheme.of(context).mode.isDark ? Colors.white54 : Colors.black54,
                ),
                labelText: "Email",
                labelStyle: myTextStyle.copyWith(
                  fontSize: 14,
                  color: AdaptiveTheme.of(context).mode.isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/80,),
            ///Password Field
            TextFormField(
              onChanged: (value) {
                password = value;
              },
              validator: (value) {
                if (password.isEmpty){
                  Future.delayed(Duration.zero).then((_){
                    setState((){
                      passwordIsValid = false;
                    });
                  });
                  return 'Password Cannot be Empty!';
                }
                else {
                  Future.delayed(Duration.zero).then((_){
                    setState((){
                      passwordIsValid = true;
                    });
                  });
                  return null;
                }
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              cursorHeight: 18,
              cursorWidth: 1.5,
              obscureText: hidePassword,
              decoration: myInputDecoration.copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword == true ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: hidePassword == false && AdaptiveTheme.of(context).mode.isLight ? Color(0xFF524C97)
                        : hidePassword == false && AdaptiveTheme.of(context).mode.isDark ? Color(0xFF5EE3C3)
                        : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword=!hidePassword;
                    });
                  },
                ),
                hintText: "Enter Your Password",
                hintStyle: myTextStyle.copyWith(
                  fontSize: 14,
                  color: AdaptiveTheme.of(context).mode.isDark ? Colors.white54 : Colors.black54,
                ),
                labelText: "Password",
                labelStyle: myTextStyle.copyWith(
                  fontSize: 14,
                  color: AdaptiveTheme.of(context).mode.isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/50,),
            Hero(
              tag: "login",
              child: MyButton(
                title: isLoading==false ? "LOGIN" : "",
                color:
                emailIsValid == false
                || passwordIsValid == false
                    ? Colors.grey
                    : Colors.blue[500],
                onPressed:
                emailIsValid == false
                || passwordIsValid == false
                    ? null
                    : () async {
                  try{
                      setState(() {
                        isLoading = true;
                      });
                      var user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                      user.user.emailVerified
                      ? Navigator.pushNamedAndRemoveUntil(context, ChatList.route, (route) => false)
                      : ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Email has not been verified yet!"),
                        ),
                      );
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
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
                widget: isLoading==false ? Container() : SizedBox(
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
