import 'package:flutter/material.dart';
import 'package:getgeo/model/mapModel.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/Roting.dart';
import 'package:getgeo/page/authgui.dart';
import 'package:getgeo/page/gmap.dart';
import 'package:getgeo/page/homePage.dart';
import 'package:getgeo/page/homem.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:getgeo/page/homexd.dart';
import 'package:getgeo/page/login.dart';
import 'package:getgeo/page/map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:getgeo/page/mapage.dart';
import 'package:getgeo/page/mapageModel.dart';
import 'package:getgeo/page/profile.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class fabtab extends StatefulWidget {
  @override
  State<fabtab> createState() => _fabtabState();
}

class _fabtabState extends State<fabtab> {
  int _page = 0;
  var currentidx = 0;
  var t_name;
  var t_img;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    UserModel usermode = Provider.of<UserModel>(context, listen: false);
    t_name = usermode.username;
    t_img = usermode.imgPhoto;
  }

  void set_currentidx(int idx) {
    print(idx);
    setState(() {
      currentidx = idx;
      _page = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _showPage = currentidx == 0
        ? HomepageBU()
        : currentidx == 1
            ? Profilepage()
            : false as Widget;
    return Consumer<UserModel>(
      builder: (context, usermode, child) => Scaffold(
        body: _showPage,
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: currentidx,
          height: 60.0,
          items: <Widget>[
            Icon(
              Icons.home_sharp,
              size: 30,
              color: Color(0xFFFFF5E0),
            ),
            // Icon(Icons.location_on, size: 30, color: Color(0xFFFFF5E0)),
            Icon(Icons.person_3_sharp, size: 30, color: Color(0xFFFFF5E0)),
            // Icon(Icons.call_split, size: 30, color: Color(0xFFFFF5E0)),
            Icon(Icons.logout, size: 30, color: Color(0xFFFFF5E0)),
          ],
          color: Color(0xFFFC70039)!,
          buttonBackgroundColor: Color(0xFF141E46),
          backgroundColor: Color(0xFFFF6969)!,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
          onTap: (index) async {
            setState(() {
              _page = index;
              currentidx = index;
            });
            if (_page == 2) {
              setState(() {
                _page = 0;
                currentidx = 0;
              });
              final GoogleSignIn googleSign = GoogleSignIn();
              await googleSign.signOut();
              await FirebaseAuth.instance.signOut();

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
          letIndexChange: (index) => true,
        ),
      ),
    );
  }
}
