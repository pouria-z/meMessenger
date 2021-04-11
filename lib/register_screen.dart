import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:memessenger/login_screen.dart';
import 'package:memessenger/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterScreen extends StatefulWidget {

  static String route = "register_screen";

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String username;
  String email;
  String password;
  String confirmpassword;
  bool isLoading = false;


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
                username = value;
              },
              validator: (value) {
                if(value.isEmpty || value.length<3){
                  return "Username Should be At Least 3 Characters!";
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.center,
              decoration: myInputDecoration.copyWith(
                hintText: "ENTER YOUR USERNAME",
                labelText: "USERNAME",
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/80,),
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
              validator: (value) {
                if(value.isEmpty || value.length<6){
                  return "Password Should be At Least 6 Characters!";
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.center,
              obscureText: true,
              decoration: myInputDecoration.copyWith(
                hintText: "ENTER YOUR PASSWORD",
                labelText: "PASSWORD",
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/80,),
            TextFormField(
              onChanged: (value) {
                confirmpassword = value;
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
              decoration: myInputDecoration.copyWith(
                hintText: "ENTER YOUR PASSWORD AGAIN",
                labelText: "CONFIRM PASSWORD",
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/50,),
            Hero(
              tag: "register",
              child: MyButton(
                title: isLoading==false ? "REGISTER" : "",
                color: Colors.blue[900],
                onPressed: () async {
                  try{
                    if (email.isNotEmpty && password.isNotEmpty && password==confirmpassword && username.isNotEmpty){
                      setState(() {
                        isLoading = true;
                      });
                      var newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                      newUser.user.sendEmailVerification();
                      _firestore.collection("users").add(
                        {
                          "username" : username,
                          "email" : email,
                          "password" : password,
                        },
                      );
                      showDialog(context: context, builder: (context) {
                          return AlertDialog(
                            title: Text("VERIFY YOUR EMAIL"),
                            content: Text("We have sent you a verification link to your email address."
                                " Please check your email and verify your email and then you can login to your account."),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                Navigator.pushReplacementNamed(context, LoginScreen.route);
                                }, child: Text("OK")),
                            ],
                          );
                        },
                      );
                    }
                    else if(password!=confirmpassword){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Passwords don't match!"),
                        ),
                      );
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill out all the fields!"),
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
