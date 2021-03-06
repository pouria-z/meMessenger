import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:memessenger/login_screen.dart';
import 'package:memessenger/register_screen.dart';
import 'package:memessenger/widgets.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:adaptive_theme/adaptive_theme.dart';



class WelcomeScreen extends StatefulWidget {

  static String route = "welcome_screen";


  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {

  AnimationController controller;
  Animation animation;
  Animation animationDark;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    animation = ColorTween(begin: Colors.grey, end: Colors.white).animate(controller);
    animationDark = ColorTween(begin: Color(0xFF121212), end: Color(0xFF2E2E2E)).animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });

  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdaptiveTheme.of(context).mode.isDark ? animationDark.value : animation.value,
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: "icon",
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: MediaQuery.of(context).size.width/8,
                    height: MediaQuery.of(context).size.height/20,
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText("meMessenger",
                      textStyle: myTextStyleBold.copyWith(
                        color: AdaptiveTheme.of(context).mode.isDark ? Colors.white54 : Colors.black54,
                        fontSize: 28,
                      ),
                      speed: Duration(milliseconds: 100),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height/30,),
            Hero(
              tag: "login",
              child: MyButton(
                title: "LOGIN",
                color: Colors.blue[500],
                widget: SizedBox(height: 0,),
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.route);
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/50,),
            Hero(
              tag: "register",
              child: MyButton(
                title: "REGISTER",
                color: Colors.blue[900],
                widget: SizedBox(height: 0,),
                onPressed: () {
                  Navigator.pushNamed(context, RegisterScreen.route);
                },
              ),
            ),
          ],
        ),
      ),

    );
  }
}

