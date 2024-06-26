import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/change_password.dart';
import 'package:getgeo/page/edit_profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  var db = FirebaseFirestore.instance;
  String Imageurl = '';
  String name = '';
  String email = '';
  String login_type = '';
  bool notification = false;
  bool notificationsound = false;
  int count_trip = 0;
  int count_bookmark = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    getsetttingnoti();
    getstatistics();
  }

  Future<void> getstatistics() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    var trip_count = await db
        .collection('trip')
        .where('user_email', isEqualTo: userModel.email)
        .get();
    print('trip_count = ${trip_count.docs.length}');
    var bookmaker_count = await db
        .collection('trip')
        .where('bookmark', arrayContains: userModel.email)
        .get();
    print('bookmaker_count = ${bookmaker_count.docs.length}');

    setState(() {
      count_trip = trip_count.docs.length;
      count_bookmark = bookmaker_count.docs.length;
    });
  }

  Future<void> getsetttingnoti() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    notification = prefs.getBool('notification') ?? false;
    notificationsound = prefs.getBool('notificationsound') ?? false;
    setState(() {
      notification = notification;
      notificationsound = notificationsound;
    });
  }

  getdata() async {
    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    var userData = await db
        .collection('user_setting')
        .where('user_email', isEqualTo: userModel.email)
        .get();
    print('userData = ${userData.docs[0].data()}');
    setState(() {
      Imageurl = userModel.imgPhoto;
      name = userModel.username;
      email = userModel.email;
      login_type = userData.docs[0].data()['login_type'];
      print('Imageurl = $Imageurl');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        // margin: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 280,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/profilebaner.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    left: 0,
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: 145,
                      child: Stack(
                        children: [
                          Material(
                            elevation: 8, //คือการเงา
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            //สีเงา
                            shadowColor: Colors.red.withOpacity(0.5),
                            shape: CircleBorder(),
                            child: InkWell(
                              splashColor: Colors.black26,
                              splashFactory: InkSplash.splashFactory,
                              onTap: () {},
                              child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,

                                    //border gardient
                                    border: Border.all(
                                      color: Color.fromARGB(255, 197, 13, 0),
                                      width: 4,
                                    ),
                                  ),
                                  child: Imageurl != ''
                                      ? Ink.image(
                                          image: NetworkImage(Imageurl)
                                              as ImageProvider<Object>,
                                          fit: BoxFit.cover,
                                          width: 140,
                                          height: 140,
                                        )
                                      : Ink.image(
                                          image: NetworkImage(
                                                  "https://i.imgur.com/ozwLlvB.png")
                                              as ImageProvider<Object>,
                                          fit: BoxFit.cover,
                                          width: 140,
                                          height: 140,
                                        )),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 197, 13, 0),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              name,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              email,
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      count_trip.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ทริปของฉัน',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey,
                ),
                Column(
                  children: [
                    Text(
                      count_bookmark.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ทริปที่บันทึกไว้',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  InkWell(
                    splashColor: Color(0xFFFC70039),
                    splashFactory: InkSplash.splashFactory,
                    onTap: () {
                      // Define what happens when you tap on the 'Edit Profile'
                      // print('Edit Profile Tapped');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return EditProfile();
                      })).then((value) => getdata());
                    },
                    child: ListTile(
                      title: Text('แก้ไขข้อมูลส่วนตัว'),
                      leading: Icon(Icons.person),
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                  login_type == 'email'
                      ? InkWell(
                          splashColor: Color(0xFFFC70039),
                          splashFactory: InkSplash.splashFactory,
                          onTap: () {
                            // Define what happens when you tap on the 'Change Password'
                            print('Change Password Tapped');
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ChangePasswordPage();
                            }));
                          },
                          child: ListTile(
                            title: Text('เปลี่ยนรหัสผ่าน'),
                            leading: Icon(Icons.lock),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        )
                      : Container(),
                  InkWell(
                    splashColor: Color(0xFFFC70039),
                    splashFactory: InkSplash.splashFactory,
                    onTap: () {
                      // Define what happens when you tap on the 'Change Password'
                      print('Change Password Tapped');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ChangePasswordPage();
                      }));
                    },
                    child: ListTile(
                      title: Text('ตั้งค่าการแจ้งเตือน'),
                      leading: Icon(Icons.notifications),
                      trailing: Switch(
                        value: notification,
                        onChanged: (value) async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool('notification', value);
                          setState(() {
                            notification = value;
                          });
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    splashColor: Color(0xFFFC70039),
                    splashFactory: InkSplash.splashFactory,
                    onTap: () {
                      // Define what happens when you tap on the 'Change Password'
                      print('Change Password Tapped');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ChangePasswordPage();
                      }));
                    },
                    child: ListTile(
                      title: Text('ตั้งค่าเสียงการแจ้งเตือน'),
                      leading: Icon(Icons.notifications),
                      trailing: Switch(
                        value: notificationsound,
                        onChanged: (value) async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool('notificationsound', value);
                          setState(() {
                            notificationsound = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
