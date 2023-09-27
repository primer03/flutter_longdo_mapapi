import 'package:flutter/material.dart';
import 'package:getgeo/page/authgui.dart';
import 'package:getgeo/page/homem.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:getgeo/page/login.dart';
import 'package:getgeo/page/map.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class fabtab extends StatefulWidget {
  const fabtab(
      {super.key,
      required this.title,
      required this.img_photo,
      required this.username});
  final String title;
  final String img_photo;
  final String username;
  @override
  State<fabtab> createState() => _fabtabState();
}

class _fabtabState extends State<fabtab> {
  int _page = 0;
  var currentidx = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    Widget _showPage = currentidx == 0
        ? Homexd(
            img_url: widget.img_photo,
            username: widget.username,
          )
        : currentidx == 1
            ? Mymap(
                title: '',
              )
            : currentidx == 2
                ? Firexd(title: "")
                : false as Widget;
    return SafeArea(
      child: Scaffold(
        body: _showPage,
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
          height: 60.0,
          items: <Widget>[
            Icon(
              Icons.home_sharp,
              size: 30,
              color: Color(0xFFFFF5E0),
            ),
            Icon(Icons.location_on, size: 30, color: Color(0xFFFFF5E0)),
            Icon(Icons.person_3_sharp, size: 30, color: Color(0xFFFFF5E0)),
            Icon(Icons.call_split, size: 30, color: Color(0xFFFFF5E0)),
            Icon(Icons.logout, size: 30, color: Color(0xFFFFF5E0)),
          ],
          color: Color(0xFFC70039)!,
          buttonBackgroundColor: Color(0xFF141E46),
          backgroundColor: Color(0xFFFF6969)!,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
          onTap: (index) async {
            setState(() {
              _page = index;
              currentidx = index;
            });
            if (_page == 4) {
              final GoogleSignIn googleSign = GoogleSignIn();
              await googleSign.signOut();
              await FirebaseAuth.instance.signOut();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Authgui(
                          title: '',
                        )),
              );
            }
          },
          letIndexChange: (index) => true,
        ),
      ),
    );
  }
}
