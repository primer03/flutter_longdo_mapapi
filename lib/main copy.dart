// import 'package:flutter/material.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:getgeo/model/TripModel.dart';
// import 'package:getgeo/model/mapModel.dart';
// import 'package:getgeo/model/userModel.dart';
// // import 'package:getgeo/page/home.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:getgeo/page/splash.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_isolate/flutter_isolate.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:socket_io_client/socket_io_client.dart';

// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   const InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);

//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   var status = await Permission.notification.request();
//   if (status.isGranted) {
//     print('Permission is granted');
//   } else {
//     print('Permission is not granted');
//     await Permission.notification.request();
//     await Permission.accessNotificationPolicy.request();
//   }

//   await Firebase.initializeApp();
//   WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
//   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
//   Future.delayed(Duration(seconds: 3), () {
//     print('This line is execute after 3 seconds.');
//   });
//   FlutterNativeSplash.remove();
//   // Check if Firebase is initialized
//   if (Firebase.apps.length == 0) {
//     print('Firebase not initialized');
//   } else {
//     print('Firebase initialized');
//   }
//   _startBackgroundService();
//   initializeDateFormatting('th', null).then((_) => runApp(MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         Provider<UserModel>(create: (_) => UserModel()),
//         ChangeNotifierProvider<mapModel>(create: (_) => mapModel()),
//         ChangeNotifierProvider<TripModel>(create: (_) => TripModel()),
//       ],
//       child: MaterialApp(
//           title: 'GetGeo',
//           home: const splash(),
//           theme: ThemeData(
//             primarySwatch: Colors.red,
//           )),
//     );
//   }
// }

// void _startBackgroundService() async {
//   FlutterIsolate.spawn(_backgroundTask, "Hello from background!");
// }

// void _backgroundTask(String message) {
//   print("Background Service started: $message");
//   IO.Socket socket = IO.io('https://msg-server-msle.onrender.com/',
//       OptionBuilder().setTransports(['websocket']).build());

//   socket.onConnect((_) {
//     print('connect');
//     socket.on('message', (data) {
//       print(data);
//       _showLocalNotification(data);
//     });
//   });
//   //ถ้าเชื่อมต่อกับ Server ไม่ได้
//   socket.onConnectError((data) => print("Connect Error: $data"));
//   // รับข้อมูลจาก Server
// }

// void _showLocalNotification(String message) async {
//   const String channelId = "HEE";
//   const String channelName = "HEEYAI";
//   final Person person = const Person(name: 'Heeyai', key: '1');
//   final AndroidNotificationDetails androidNotificationDetails =
//       AndroidNotificationDetails(
//     channelId,
//     channelName,
//     channelDescription: 'KUY',
//     importance: Importance.max,
//     priority: Priority.high,
//     ticker: 'ticker',
//     styleInformation: MessagingStyleInformation(
//       person,
//       conversationTitle: 'แจ้งเตือนจาก HEE',
//       groupConversation: true,
//       messages: [
//         Message(
//           message,
//           DateTime.now(),
//           person,
//         )
//       ],
//     ),
//   );

//   final NotificationDetails notificationDetails =
//       NotificationDetails(android: androidNotificationDetails);

//   flutterLocalNotificationsPlugin.show(
//     0,
//     'HEEXD',
//     'HEEYAIMAK',
//     notificationDetails,
//     payload: 'XDXD',
//   );
// }
