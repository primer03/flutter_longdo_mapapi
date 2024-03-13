import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/forgot_password.dart';
import 'package:getgeo/page/register.dart';
import 'package:getgeo/page/selectCar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/page/Fabtab.dart';
import 'package:getgeo/page/login.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
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
  var db = FirebaseFirestore.instance;
  bool _isShowPassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      var Userdata = await db
          .collection('user_setting')
          .where('user_email', isEqualTo: emailController.text)
          .get();
      if (Userdata.docs.length > 0) {
        var userModel = Provider.of<UserModel>(context, listen: false);
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
            builder: (context) => selectCar(login_type: 'email'),
          ),
        );
      }
    } catch (e) {
      print("เกิดข้อผิดพลาด: $e");
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'เกิดข้อผิดพลาด',
          text: 'อีเมล์หรือรหัสผ่านไม่ถูกต้อง',
          confirmBtnText: 'ตกลง',
          confirmBtnColor: Color.fromARGB(255, 197, 13, 0));
    }
  }

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
          print(authResult.user!.email!);
          var user_email = authResult.user!.email!;
          var db = FirebaseFirestore.instance;
          var Userdata = await db
              .collection('user_setting')
              .where('user_email', isEqualTo: user_email)
              .get();

          if (Userdata.docs.length > 0) {
            setState(() {
              img_photp = authResult.user!.photoURL!;
              Textwell = authResult.user!.displayName!;
              if (_usermodel is UserModel && _usermodel != null) {
                _usermodel.set_img = Userdata.docs[0]['user_img'];
                _usermodel.set_user = Userdata.docs[0]['user_name'];
                _usermodel.set_email = Userdata.docs[0]['user_email'];
              }
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => fabtab(),
              ),
            );
          } else {
            UserModel userModel =
                Provider.of<UserModel>(context, listen: false);
            userModel.set_img = authResult.user!.photoURL!;
            userModel.set_user = authResult.user!.displayName!;
            userModel.set_email = authResult.user!.email!;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => selectCar(login_type: 'google'),
              ),
            );
          }
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
          _usermodel.set_email = currentUser.email!;
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
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 620,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0.5,
                                    blurRadius: 15,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              width: 200,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/loginlogo.png',
                                  fit: BoxFit.fill,
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                Textwell,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 197, 13, 0),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              //login form
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      labelText: 'อีเมล์',
                                      hintText: 'อีเมล์',
                                      contentPadding: EdgeInsets.all(10),
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Colors.black,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color:
                                              Color.fromARGB(255, 197, 13, 0),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  TextFormField(
                                    controller: passwordController,
                                    obscureText: _isShowPassword,
                                    decoration: InputDecoration(
                                      labelText: 'รหัสผ่าน',
                                      hintText: 'รหัสผ่าน',
                                      contentPadding: EdgeInsets.all(10),
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.black,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isShowPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.black,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isShowPassword = !_isShowPassword;
                                          });
                                        },
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color:
                                              Color.fromARGB(255, 197, 13, 0),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Forgot(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'ลืมรหัสผ่าน?',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: 15,
                                  // ),
                                  ElevatedButton(
                                    onPressed: () {
                                      loginUser(context);
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => login(),
                                      //   ),
                                      // );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 197, 13, 0),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      minimumSize: Size(double.infinity, 50),
                                    ),
                                    child: Text(
                                      'เข้าสู่ระบบ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    //not account
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'ยังไม่มีบัญชีผู้ใช้?',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Registerpage(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'สมัครสมาชิก',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey,
                                          height: 30,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'หรือ',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey,
                                          height: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                signInWithGoogles(usermode);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Colors.red)),
                              child: Padding(
                                padding: const EdgeInsets.all(7),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      child: ClipOval(
                                          child: Image.network(img_url)),
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
      ),
    );
  }
}
