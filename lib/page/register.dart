import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/Fabtab.dart';
import 'package:getgeo/page/authgui.dart';
import 'package:getgeo/page/selectCar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({Key? key}) : super(key: key);

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  final Color customColorTextField = Color(0xFF141E46); // Define custom color
  var img_url =
      "https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-suite-everything-you-need-know-about-google-newest-0.png";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  var db = FirebaseFirestore.instance;

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
        if (_usermodel is UserModel && _usermodel != null) {
          _usermodel.set_img = currentUser.photoURL!;
          _usermodel.set_user = currentUser.displayName!;
          _usermodel.set_email = currentUser.email!;
        }
      });
    }
  }

  void _showmsgQuickAlert(String title, String msg, QuickAlertType type) {
    QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: msg,
      confirmBtnText: 'ตกลง',
    );
  }

  Future<bool> CheckUser(String email) async {
    var Userdata = await db
        .collection('user_setting')
        .where('user_email', isEqualTo: email)
        .get();
    if (Userdata.docs.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  void CheckRegister() async {
    var RegExpEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    var RegExpPassword = RegExp(r'^[a-zA-Z0-9]{6,}$'); // ต้องมี 6 ตัวขึ้นไป
    var RegExpName = RegExp(r'^(\w+)\s+(\w+)$');
    if (emailController.text.isEmpty) {
      _showmsgQuickAlert('แจ้งเตือน', 'กรุณากรอกอีเมล', QuickAlertType.error);
    } else if (!RegExpEmail.hasMatch(emailController.text)) {
      _showmsgQuickAlert(
          'แจ้งเตือน', 'กรุณากรอกอีเมลให้ถูกต้อง', QuickAlertType.error);
    } else if (nameController.text.isEmpty) {
      _showmsgQuickAlert(
          'แจ้งเตือน', 'กรุณากรอกชื่อ-สกุล', QuickAlertType.error);
    } else if (!RegExpName.hasMatch(nameController.text)) {
      _showmsgQuickAlert(
          'แจ้งเตือน', 'กรุณากรอกชื่อ-สกุลให้ถูกต้อง', QuickAlertType.error);
    } else if (passwordController.text.isEmpty) {
      _showmsgQuickAlert(
          'แจ้งเตือน', 'กรุณากรอกรหัสผ่าน', QuickAlertType.error);
    } else if (!RegExpPassword.hasMatch(passwordController.text)) {
      _showmsgQuickAlert(
          'แจ้งเตือน',
          'กรุณากรอกรหัสผ่านให้ถูกต้อง ความยาว 6 ตัวขึ้นไป',
          QuickAlertType.error);
    } else if (confirmpasswordController.text.isEmpty) {
      _showmsgQuickAlert(
          'แจ้งเตือน', 'กรุณากรอกยืนยันรหัสผ่าน', QuickAlertType.error);
    } else if (passwordController.text != confirmpasswordController.text) {
      _showmsgQuickAlert(
          'แจ้งเตือน', 'กรุณากรอกรหัสผ่านให้ตรงกัน', QuickAlertType.error);
    } else if (await CheckUser(emailController.text)) {
      _showmsgQuickAlert(
          'แจ้งเตือน', 'อีเมลนี้มีบัญชีอยู่แล้ว', QuickAlertType.error);
    } else {
      _showmsgQuickAlert(
          'สำเร็จ', 'ตรวจสอบข้อมูลสำเร็จ', QuickAlertType.success);
      // var user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //     email: emailController.text,
      //     password: passwordController.text); // สร้างบัญชี
      // if (user.user != null) {
      // await db.collection('user_setting').add({
      //   'user_email': emailController.text,
      //   'user_name': nameController.text,
      //   'user_img': "",
      //   'car_brand': "",
      //   'login_type': "email",
      //   'car_oil': ""
      // });
      UserModel userModel = Provider.of<UserModel>(context, listen: false);
      userModel.set_img = "";
      userModel.set_user = nameController.text;
      userModel.set_email = emailController.text;
      userModel.set_password = passwordController.text;
      Future.delayed(const Duration(milliseconds: 4000), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => selectCar(login_type: 'email'),
          ),
        );
      });
      // UserModel userModel = Provider.of<UserModel>(context, listen: false);
      // userModel.set_img = "";
      // userModel.set_user = nameController.text;
      // userModel.set_email = emailController.text;
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => selectCar(login_type: 'email'),
      //   ),
      // );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, usermode, child) => MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.topCenter,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/register.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Image.asset(
                    'assets/images/logo_app.png',
                    width: 170,
                    height: 170,
                  ),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.77,
                minChildSize: 0.77,
                maxChildSize: 1,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'สมัครสมาชิก',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 197, 13, 0),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: emailController,
                              cursorColor: customColorTextField,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(15),
                                labelText: 'อีเมล',
                                hintText: 'กรุณากรอกอีเมล',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                floatingLabelStyle: const TextStyle(
                                  color: Color(0xFF141E46),
                                  fontSize: 20,
                                ),
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.center,
                                focusColor: customColorTextField,
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF141E46),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF141E46),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextField(
                              controller: nameController,
                              cursorColor: customColorTextField,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 15.0),
                                labelText: 'ชื่อ-สกุล',
                                hintText: 'กรุณากรอกชื่อ-สกุล',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                floatingLabelStyle: const TextStyle(
                                  color: Color(0xFF141E46),
                                  fontSize: 20,
                                ),
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.center,
                                focusColor: customColorTextField,
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF141E46),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF141E46),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextField(
                              controller: passwordController,
                              cursorColor: customColorTextField,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 15.0),
                                labelText: 'รหัสผ่าน',
                                hintText: 'กรุณากรอกรหัสผ่าน',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                floatingLabelStyle: const TextStyle(
                                  color: Color(0xFF141E46),
                                  fontSize: 20,
                                ),
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.center,
                                focusColor: customColorTextField,
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF141E46),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF141E46),
                                    width: 2,
                                  ),
                                ),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 30),
                            TextField(
                              controller: confirmpasswordController,
                              cursorColor: customColorTextField,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 15.0),
                                labelText: 'ยืนยันรหัสผ่าน',
                                hintText: 'กรุณากรอกยืนยันรหัสผ่าน',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                floatingLabelStyle: const TextStyle(
                                  color: Color(0xFF141E46),
                                  fontSize: 20,
                                ),
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.center,
                                focusColor: customColorTextField,
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF141E46),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF141E46),
                                    width: 2,
                                  ),
                                ),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                CheckRegister();
                              },
                              child: const Text(
                                'สมัครสมาชิก',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 197, 13, 0),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('มีบัญชีอยู่แล้ว?'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Authgui(
                                          title: '',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'เข้าสู่ระบบ',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 197, 13, 0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text('หรือ'),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
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
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
