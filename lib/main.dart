import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:getgeo/model/TripModel.dart';
import 'package:getgeo/model/mapModel.dart';
import 'package:getgeo/model/userModel.dart';
// import 'package:getgeo/page/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:getgeo/page/splash.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Future.delayed(Duration(seconds: 3), () {
    print('This line is execute after 3 seconds.');
  });
  FlutterNativeSplash.remove();
  // Check if Firebase is initialized
  if (Firebase.apps.length == 0) {
    print('Firebase not initialized');
  } else {
    print('Firebase initialized');
  }
  initializeDateFormatting('th', null).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserModel>(create: (_) => UserModel()),
        ChangeNotifierProvider<mapModel>(create: (_) => mapModel()),
        ChangeNotifierProvider<TripModel>(create: (_) => TripModel()),
      ],
      child: MaterialApp(
          title: 'GetGeo',
          home: const splash(),
          theme: ThemeData(
            primarySwatch: Colors.red,
          )),
    );
  }
}
