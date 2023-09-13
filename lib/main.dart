import 'package:flutter/material.dart';
// import 'package:getgeo/page/home.dart';
import 'package:getgeo/page/map.dart';
import 'package:getgeo/page/map_search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Mymap(title: 'Flutter Demo Home Page'),
    );
  }
}
