import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:memessenger/login_screen.dart';
import 'package:memessenger/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//TODO: toLowerCase the username to compare the users in database

class RegisterScreen extends StatefulWidget {

  static String route = "register_screen";

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  QuerySnapshot snapshot;
  String username;
  String email;
  String password;
  String confirmPassword;
  bool isLoading = false;
  String validateEmail(String value) {
    Pattern pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value) || value == null)
      return 'Please Enter a Valid Email Address!';
    else
      return null;
  }
  String validateUsername(String value) {
    Pattern pattern = r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value) || value == null)
      return 'Please Enter a Valid Username!';
    else if (value.length < 3) {
      return 'Username Should be At Least 3 Characters!';
    }
    else
      return null;
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
            ///Username Field
            TextFormField(
              onChanged: (value) {
                username = value;
              },
              validator: validateUsername,
              cursorColor: Colors.blueAccent,
              cursorHeight: 18,
              cursorWidth: 1.5,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.center,
              decoration: myInputDecoration.copyWith(
                hintText: "Enter Your Username",
                labelText: "Username",
                hintStyle: myTextStyle.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white54 : Colors.black54,
                ),
                labelStyle: myTextStyle.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/80,),
            ///Email Field
            TextFormField(
              onChanged: (value) {
                email = value;
              },
              validator: validateEmail,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.emailAddress,
              cursorColor: Colors.blueAccent,
              cursorHeight: 18,
              cursorWidth: 1.5,
              decoration: myInputDecoration.copyWith(
                hintText: "Enter Your Email Address",
                labelText: "Email",
                hintStyle: myTextStyle.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white54 : Colors.black54,
                ),
                labelStyle: myTextStyle.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white54 : Colors.black54,
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
                if(value.isEmpty || value.length<6){
                  return "Password Should be At Least 6 Characters!";
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.center,
              obscureText: true,
              cursorColor: Colors.blueAccent,
              cursorHeight: 18,
              cursorWidth: 1.5,
              decoration: myInputDecoration.copyWith(
                hintText: "Enter Your Password",
                labelText: "Password",
                hintStyle: myTextStyle.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white54 : Colors.black54,
                ),
                labelStyle: myTextStyle.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/80,),
            ///Confirm Password Field
            TextFormField(
              onChanged: (value) {
                confirmPassword = value;
              },
              validator: (value) {
                if(value.isEmpty || value.characters!=password.characters){
                  return "Passwords Don't Match!";
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.center,
              obscureText: true,
              cursorColor: Colors.blueAccent,
              cursorHeight: 18,
              cursorWidth: 1.5,
              decoration: myInputDecoration.copyWith(
                hintText: "Enter Your Password Again",
                labelText: "Confirm Password",
                hintStyle: myTextStyle.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white54 : Colors.black54,
                ),
                labelStyle: myTextStyle.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor == Color(0xFF222222) ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/50,),
            ///Register Button
            Hero(
              tag: "register",
              child: MyButton(
                title: isLoading==false ? "REGISTER" : "",
                color: Colors.blue[900],
                onPressed: () async {
                  try{
                    setState(() {
                      isLoading = true;
                    });
                    await _firestore.collection('users')
                        .where('username', isEqualTo: username)
                        .get()
                        .then((value) {
                      setState(() {
                        snapshot=value;
                      });
                      },
                    );
                    ///Check if every field is fine
                    if (email.isNotEmpty
                        && password.isNotEmpty
                        && password==confirmPassword
                        && username.isNotEmpty
                        && snapshot.docs[0].get('username')!=username){
                      var newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                      newUser.user.sendEmailVerification();
                      newUser.user.updateProfile(displayName: username);
                      _firestore.collection("users").doc(email).set(
                        {
                          "username" : username,
                          "email" : email,
                        },
                      );
                      showDialog(context: context, builder: (context) {
                          return AlertDialog(
                            title: Text(
                              "Verify Your Email",
                              style: myTextStyleBold.copyWith(
                                color: Colors.black,
                              ),
                            ),
                            content: Text(
                              "We have sent you a verification link to your email address."
                                " Please check your email and verify your email and then you can login to your account.",
                              style: myTextStyle.copyWith(
                                  color: Colors.black54
                              ),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                Navigator.pushReplacementNamed(context, LoginScreen.route);
                                },
                                child: Text(
                                  "OK",
                                  style: myTextStyleBold.copyWith(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    else if (email.isEmpty
                        || password.isEmpty
                        || confirmPassword.isEmpty
                        || username.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill out all the fields!"),
                        ),
                      );
                    }
                    ///Username already taken error
                    else if(snapshot.docs[0].get('username')==username){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Username already taken!"),
                        ),
                      );
                    }
                    ///Passwords matching error
                    else if(password!=confirmPassword){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Passwords don't match!"),
                        ),
                      );
                    }
                  }
                  catch (e) {
                    print(e);
                    if(e.toString()=="[firebase_auth/email-already-in-use] The"
                        " email address is already in use by another account."){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("The email address is already in use!"),
                        ),
                      );
                    }
                    else if(e.toString()=="[firebase_auth/invalid-email] "
                        "The email address is badly formatted."){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Invalid email address!"),
                        ),
                      );
                    }
                    else if(e.toString()=="[firebase_auth/weak-password] "
                        "Password should be at least 6 characters"){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Password should be at least 6 characters!"),
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
                widget: isLoading==false ? SizedBox(height: 0,) : SizedBox(
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
