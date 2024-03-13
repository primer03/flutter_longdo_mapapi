import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/page/authgui.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Newpassword extends StatefulWidget {
  const Newpassword({super.key});

  @override
  State<Newpassword> createState() => _NewpasswordState();
}

class _NewpasswordState extends State<Newpassword> {
  late String otp;
  late String email;
  TextEditingController _otpController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  bool _isOTPValid = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadOTP();
  }

  Future<void> updatePassword(String password) async {
    //set email to Firebase
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .then((value) {
      _showmsgQuickAlert('ส่งอีเมล์สำเร็จ', 'กรุณาตรวจสอบอีเมล์ของคุณ',
          QuickAlertType.success);
    }).catchError((error) {
      _showmsgQuickAlert(
          'ส่งอีเมล์ไม่สำเร็จ', error.message, QuickAlertType.error);
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void loadOTP() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    otp = prefs.getString('otp') ?? '';
    email = prefs.getString('email') ?? '';
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

  void _validateOTP() {
    if (_otpController.text == otp) {
      setState(() {
        _isOTPValid = true;
      });
    } else {
      _showmsgQuickAlert('รหัส otp ไม่ถูกต้อง', 'กรุณากรอกรหัส otp ใหม่',
          QuickAlertType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รหัสผ่านใหม่'),
        backgroundColor: Color(0xFFFC70039),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/otp.png', width: 200, height: 200),
              Text(
                'รหัสผ่านใหม่',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF141E46),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'กรุณากรอกรหัส otp ที่ได้รับทางอีเมล์เพื่อรีเซ็ตรหัสผ่าน',
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Added
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      // Added
                      child: TextFormField(
                        enabled: _isOTPValid == false ? true : false,
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'otp',
                          hintText: 'กรอกรหัส otp ที่ได้รับทางอีเมล์',
                          floatingLabelStyle: TextStyle(
                            color: Color(0xFF141E46),
                            fontSize: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF141E46),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isOTPValid == false ? _validateOTP : null,
                      child: Icon(Icons.check),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFC70039),
                        foregroundColor: Colors.white,
                        minimumSize: Size(60, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.all(20),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _isOTPValid == true
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _newPasswordController,
                            decoration: InputDecoration(
                              labelText: 'รหัสผ่านใหม่',
                              hintText: 'กรอกรหัสผ่านใหม่',
                              floatingLabelStyle: TextStyle(
                                color: Color(0xFF141E46),
                                fontSize: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF141E46),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_newPasswordController.text != '') {
                                updatePassword(_newPasswordController.text);
                              } else {
                                _showmsgQuickAlert(
                                    'กรุณากรอกรหัสผ่านใหม่',
                                    'กรุณากรอกรหัสผ่านใหม่',
                                    QuickAlertType.error);
                              }
                            },
                            child: Text('ยืนยัน'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFC70039),
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(20),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
