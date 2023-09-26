import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/page/login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authgui extends StatefulWidget {
  const Authgui({super.key, required String title});

  @override
  State<Authgui> createState() => _AuthguiState();
}

class _AuthguiState extends State<Authgui> {
  var img_url =
      "https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-suite-everything-you-need-know-about-google-newest-0.png";
  var img_photp = "https://i.imgur.com/l3ZLG5q.jpg";
  Future<void> signInWithGoogle() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final UserCredential authResult =
        await auth.signInWithCredential(credential);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                decoration: BoxDecoration(
                    // color: Colors.blue,
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.circular(200),
                    //   bottomRight: Radius.circular(0),
                    // ),
                    // border: Border.all(color: Colors.deepPurple)),
                    ),
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
                        child: Text("Wellcome to GetGeo",
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
                          GoogleSignInAccount? googleSignInAccount =
                              await GoogleSignIn().signIn();
                          if (googleSignInAccount != null) {
                            setState(() {
                              img_photp = googleSignInAccount.photoUrl!;
                            });
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Firexd(title: "test"),
                            ),
                          );
                          // Navigator.pushNamed(context, Ma);
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
                                child: ClipOval(child: Image.network(img_url)),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Sign in with Google",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ]),
              )
            ],
          ),
        ),
      )),
    ));
  }
}
