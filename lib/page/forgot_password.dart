import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:getgeo/page/new_password.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/page/authgui.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  var db = FirebaseFirestore.instance;

  void _showmsgQuickAlert(String title, String msg, QuickAlertType type) {
    QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: msg,
      confirmBtnText: 'ตกลง',
    );
  }

  Future<void> updatePassword() async {
    //set email to Firebase
    if (_emailController.text.isEmpty) {
      _showmsgQuickAlert(
          'กรุณากรอกอีเมล์', 'กรุณากรอกอีเมล์ของคุณ', QuickAlertType.error);
      return;
    }
    var userData = await db
        .collection('user_setting')
        .where('user_email', isEqualTo: _emailController.text)
        .get();
    if (userData.docs.isEmpty) {
      _showmsgQuickAlert(
          'ไม่พบอีเมล์', 'ไม่พบอีเมล์ของคุณ', QuickAlertType.error);
      return;
    }
    if (userData.docs[0].data()['login_type'] == 'google') {
      _showmsgQuickAlert(
          'ไม่สามารถรีเซ็ตรหัสผ่านได้',
          'กรุณาใช้อีเมล์ที่ไม่ได้เข้าสู่ระบบผ่าน Google Sign-In',
          QuickAlertType.error);
      return;
    }
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text)
          .then((value) {
        _showmsgQuickAlert('ส่งอีเมล์สำเร็จ', 'กรุณาตรวจสอบอีเมล์ของคุณ',
            QuickAlertType.success);
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return Authgui(
              title: '',
            );
          }));
        });
      }).catchError((error) {
        _showmsgQuickAlert(
            'ส่งอีเมล์ไม่สำเร็จ', error.message, QuickAlertType.error);
      });
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  // Future<void> sendEmail() async {
  //   _showmsgQuickAlert(
  //       'ส่งอีเมล์', 'กำลังส่งอีเมล์รีเซ็ตรหัสผ่าน', QuickAlertType.loading);
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final serviceId = 'service_c0ycp58';
  //   final templateId = 'template_lj3fw1r';
  //   final userId = '2mlcUD3AKHhLnIRBe';
  //   int min = 100000;
  //   int max = 999999;
  //   String otp = (min + Random().nextInt(max - min)).toString();
  //   final email = _emailController.text;
  //   final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'origin': 'http://localhost',
  //       },
  //       body: json.encode({
  //         'service_id': serviceId,
  //         'template_id': templateId,
  //         'user_id': userId,
  //         'template_params': {
  //           'user_email': email,
  //           'user_subject': 'Reset password request',
  //           'user_otp': otp,
  //         },
  //       }),
  //     );
  //     if (response.statusCode == 200) {
  //       print('Email sent');
  //       prefs.setString('otp', otp);
  //       prefs.setString('email', email);
  //       Navigator.pop(context);
  //       _showmsgQuickAlert('ส่งอีเมล์', 'ส่งอีเมล์รีเซ็ตรหัสผ่านสำเร็จแล้ว',
  //           QuickAlertType.success);
  //       Future.delayed(Duration(seconds: 3), () {
  //         //กลับไปหน้าเข้าสู่ระบบ แล้วลบหน้าเก่าทิ้งทั้งหมด
  //         // Navigator.pushAndRemoveUntil(
  //         //     context,
  //         //     MaterialPageRoute(builder: (context) => Newpassword()),
  //         //     (route) => false);
  //         Navigator.push(context, MaterialPageRoute(builder: (context) {
  //           return Newpassword();
  //         }));
  //       });
  //     } else {
  //       _showmsgQuickAlert('ส่งอีเมล์', 'ส่งอีเมล์รีเซ็ตรหัสผ่านไม่สำเร็จ',
  //           QuickAlertType.error);
  //       print('Failed to send email. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error sending email: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ลืมรหัสผ่าน'),
        centerTitle: true,
        backgroundColor: Color(0xFFFC70039),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/sendx.png', width: 200, height: 200),
              Text(
                'ลืมรหัสผ่าน',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF141E46),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'กรุณากรอกอีเมล์ที่คุณใช้สมัครสมาชิกเพื่อรีเซ็ตรหัสผ่าน',
                  textAlign: TextAlign.center,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        cursorColor: Color(0xFF141E46),
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'อีเมล์',
                          hintText: ' กรอกอีเมล์ที่ใช้สมัครสมาชิก',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                          floatingLabelStyle: TextStyle(
                            color: Color(0xFF141E46),
                            fontSize: 20,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF141E46),
                              width: 2,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your old password';
                          }
                          return null;
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          print('Reset password');
                          updatePassword();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.send),
                          SizedBox(width: 10),
                          Text('ส่งอีเมล์รีเซ็ตรหัสผ่าน'),
                        ],
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}
