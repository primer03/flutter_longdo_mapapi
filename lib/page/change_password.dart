import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:getgeo/page/authgui.dart';
import 'package:quickalert/quickalert.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool shownewPassword = false;
  bool showoldPassword = false;

  Future<bool> reauthenticateUser(String email, String oldPassword) async {
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: oldPassword);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reauthenticateWithCredential(credential);
      return true; // Reauthentication successful
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return false; // Reauthentication failed
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

  Future<void> changePassword(String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      await user?.updatePassword(newPassword);
      _showmsgQuickAlert('เปลี่ยนรหัสผ่านสำเร็จ',
          'รหัสผ่านของคุณได้รับการเปลี่ยนแล้ว', QuickAlertType.success);
      await signOut();
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return Authgui(title: '');
        }));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showmsgQuickAlert('เปลี่ยนรหัสผ่านไม่สำเร็จ',
            'รหัสผ่านที่คุณใส่มีความยาวไม่เพียงพอ', QuickAlertType.error);
      } else if (e.code == 'requires-recent-login') {
        _showmsgQuickAlert('เปลี่ยนรหัสผ่านไม่สำเร็จ',
            'กรุณาล็อกอินใหม่เพื่อเปลี่ยนรหัสผ่าน', QuickAlertType.error);
      }
    }
  }

  Future<void> tryChangePassword() async {
    _showmsgQuickAlert(
        'เปลี่ยนรหัสผ่าน', 'กรุณารอสักครู่', QuickAlertType.loading);
    final email = _emailController.text.trim();
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    bool reauthenticated = await reauthenticateUser(email, oldPassword);
    if (reauthenticated) {
      Navigator.pop(context);
      await changePassword(newPassword);
    } else {
      Navigator.pop(context);
      _showmsgQuickAlert('เปลี่ยนรหัสผ่านไม่สำเร็จ',
          'กรุณาตรวจสอบรหัสผ่านเดิมของคุณ', QuickAlertType.error);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> getEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _emailController.text = user.email!;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เปลี่ยนรหัสผ่าน'),
        centerTitle: true,
        backgroundColor: Color(0xFFFC70039),
        foregroundColor: Colors.white,
      ),
      body: Container(
          alignment: Alignment.center,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/changepsw.png',
                      height: 200,
                    ),
                    Text(
                      'เปลี่ยนรหัสผ่าน',
                      style: TextStyle(
                        fontSize: 25,
                        color: Color(0xFF141E46),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      readOnly: true,
                      controller: _emailController,
                      cursorColor: Color(0xFF141E46),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email,
                          color: Color(0xFF141E46),
                        ),
                        labelText: 'อีเมล',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF141E46),
                          fontWeight: FontWeight.bold,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFF141E46),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกอีเมลของคุณ';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      cursorColor: Color(0xFF141E46),
                      controller: _oldPasswordController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Color(0xFF141E46),
                        ),
                        suffixIcon: IconButton(
                          icon: showoldPassword
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              showoldPassword = !showoldPassword;
                            });
                          },
                        ),
                        labelText: 'รหัสผ่านเดิม',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF141E46),
                          fontWeight: FontWeight.bold,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFF141E46),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      obscureText: !showoldPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your old password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      cursorColor: Color(0xFF141E46),
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Color(0xFF141E46),
                        ),
                        suffixIcon: IconButton(
                          icon: shownewPassword
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              shownewPassword = !shownewPassword;
                            });
                          },
                        ),
                        labelText: 'รหัสผ่านใหม่',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF141E46),
                          fontWeight: FontWeight.bold,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFF141E46),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      obscureText: !shownewPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          tryChangePassword();
                        }
                      },
                      child: Text('เปลี่ยนรหัสผ่าน'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFC70039),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
