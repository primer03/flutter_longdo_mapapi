import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/Fabtab.dart';
import 'package:getgeo/page/authgui.dart';
import 'package:provider/provider.dart';

class splash extends StatefulWidget {
  const splash({super.key});

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  double _opacity = 0.0; // Initial opacity value
  String _text = ''; // Initial text

  @override
  void initState() {
    super.initState();

    // Add a delay before starting the animation
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Set opacity to 1.0 for fade-in effect
      });

      // Start the text animation
      _animateText();
    });
  }

  void _animateText() {
    const String targetText = 'GetGeo';

    Timer.periodic(
      Duration(milliseconds: 300),
      (timer) {
        int length = _text.length;

        if (length < targetText.length) {
          setState(() {
            _text = targetText.substring(0, length + 1);
          });
        } else {
          timer.cancel(); // Stop the animation when complete
          FirebaseAuth.instance.authStateChanges().listen(
            (User? user) {
              if (user != null) {
                UserModel userModel = Provider.of<UserModel>(context,
                    listen:
                        false); // Assuming you're using Provider to get the UserModel.
                if (userModel != null) {
                  userModel.set_img = user.photoURL!;
                  userModel.set_user = user.displayName!;
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => fabtab(),
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Authgui(
                      title: '',
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Nighttime.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _opacity,
                duration: Duration(seconds: 1), // Duration of the animation
                child: Image.asset(
                  'assets/images/luffy.png',
                  width: 200,
                  height: 200,
                ),
              ),
              Text(
                _text,
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
