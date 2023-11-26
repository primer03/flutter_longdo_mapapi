import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/selectCar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/page/Fabtab.dart';
import 'package:getgeo/page/login.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Authgui extends StatefulWidget {
  const Authgui({super.key, required String title});

  @override
  State<Authgui> createState() => _AuthguiState();
}

class _AuthguiState extends State<Authgui> {
  var img_url =
      "https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-suite-everything-you-need-know-about-google-newest-0.png";
  var img_photp = "https://i.imgur.com/zvcbYTB.png";
  var Textwell = "Wellcome to GetGeo";
  Future<void> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await auth.signInWithCredential(credential);

      if (authResult.user != null) {
        setState(() {
          img_photp = authResult.user!.photoURL!;
          Textwell = authResult.user!.displayName!;
        });
      }
    }
  }

  Future<void> signInWithGoogles(Object _usermodel) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;

    if (currentUser == null) {
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult =
            await auth.signInWithCredential(credential);

        if (authResult.user != null) {
          print('Login success');
          setState(() {
            img_photp = authResult.user!.photoURL!;
            Textwell = authResult.user!.displayName!;
            if (_usermodel is UserModel && _usermodel != null) {
              _usermodel.set_img = authResult.user!.photoURL!;
              _usermodel.set_user = authResult.user!.displayName!;
            }
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => selectCar(),
            ),
          );
        }
      }
    } else {
      print('User is already logged in');
      setState(() {
        img_photp = currentUser.photoURL!;
        Textwell = currentUser.displayName!;
        if (_usermodel is UserModel && _usermodel != null) {
          _usermodel.set_img = currentUser.photoURL!;
          _usermodel.set_user = currentUser.displayName!;
        }
      });
    }
  }

  // String? name = null;

  Future<void> check_login() async {
    GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
    if (googleSignInAccount != null) {
      setState(() {
        img_photp = googleSignInAccount.photoUrl!;
        Textwell = googleSignInAccount.displayName!;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print("initState");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, usermode, child) => MaterialApp(
        home: SafeArea(
          child: Scaffold(
            body: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 500,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 200,
                              child: ClipOval(
                                child: Image.network(
                                  img_photp,
                                  fit: BoxFit.fill,
                                  width: 200,
                                  height: 200,
                                ),
                              )),
                          Container(
                            child: Text(Textwell,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                )),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              signInWithGoogles(usermode);
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                side: BorderSide(color: Colors.red)),
                            child: Padding(
                              padding: const EdgeInsets.all(7),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    child:
                                        ClipOval(child: Image.network(img_url)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Sign in with Google",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
