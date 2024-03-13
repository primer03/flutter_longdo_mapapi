import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/Fabtab.dart';
import 'package:getgeo/page/authgui.dart';
import 'package:getgeo/page/selectCar.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class splash extends StatefulWidget {
  const splash({super.key});

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  double _opacity = 0.0; // Initial opacity value
  String _text = ''; // Initial text
  late StreamSubscription subscription;
  @override
  void initState() {
    super.initState();
    // CheckInternetConnect();
    // Add a delay before starting the animation
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Set opacity to 1.0 for fade-in effect
      });
      // Start the text animation
      _animateText();
    });
  }

  Future<bool> CheckInternetConnect() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }

  void _animateText() async {
    const String targetText = 'GetGeo';

    Timer.periodic(
      Duration(milliseconds: 300),
      (timer) async {
        int length = _text.length;

        if (length < targetText.length) {
          setState(() {
            _text = targetText.substring(0, length + 1);
          });
        } else {
          timer.cancel(); // Stop the animation when complete
          var checkConnect = await CheckInternetConnect();
          if (checkConnect == true) {
            FirebaseAuth.instance.authStateChanges().listen(
              (User? user) async {
                if (user != null) {
                  UserModel userModel = Provider.of<UserModel>(context,
                      listen:
                          false); // Assuming you're using Provider to get the UserModel.
                  if (userModel != null) {
                    // userModel.set_img = user.photoURL!;
                    // userModel.set_user = user.displayName!;
                    // userModel.set_email = user.email!;
                  }
                  var db = FirebaseFirestore.instance;
                  var Userdata = await db
                      .collection('user_setting')
                      .where('user_email', isEqualTo: user.email)
                      .get();
                  if (Userdata.docs.length > 0) {
                    print(Userdata.docs[0]['car_brand']);
                    userModel.set_img = Userdata.docs[0]['user_img'];
                    userModel.set_user = Userdata.docs[0]['user_name'];
                    userModel.set_email = Userdata.docs[0]['user_email'];
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
                        builder: (context) => selectCar(login_type: 'google'),
                      ),
                    );
                  }
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
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  'ไม่มีการเชื่อมต่ออินเตอร์เน็ต',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                content: Text(
                  'กรุณาเชื่อมต่ออินเตอร์เน็ตแล้วลองใหม่อีกครั้ง',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      exit(0);
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
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
