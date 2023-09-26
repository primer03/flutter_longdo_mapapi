import 'package:flutter/material.dart';
import 'package:getgeo/page/authgui.dart';
// import 'package:getgeo/page/home.dart';
import 'package:getgeo/page/map.dart';
import 'package:getgeo/page/map_search.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'page/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check if Firebase is initialized
  if (Firebase.apps.length == 0) {
    print('Firebase not initialized');
  } else {
    print('Firebase initialized');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(

      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      //   useMaterial3: true,

      // ),
      home: const Authgui(title: 'Flutter Demo Home Page'),
    );
  }
}
