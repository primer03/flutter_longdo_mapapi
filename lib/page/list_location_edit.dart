import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/model/TripModel.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/Fabtab.dart';
import 'package:getgeo/page/select_map.dart';
import 'package:getgeo/page/select_map_edit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationListEdit extends StatefulWidget {
  const LocationListEdit({Key? key, required this.trip_id}) : super(key: key);
  final String trip_id;

  @override
  State<LocationListEdit> createState() => _LocationListEditState();
}

class _LocationListEditState extends State<LocationListEdit> {
  List<DateTime?> dates = [];
  List<TimeOfDay> times = [];
  List<int> _countLocation = [];
  var db = FirebaseFirestore.instance;

  Future getDatatrip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _dates = await prefs.getStringList('trip_dates_edit');
    var _times = await prefs.getStringList('trip_times_edit');
    String str_activities_time =
        await prefs.getString('activities_time') ?? '[]';
    String str_location = await prefs.getString('locations') ?? '[]';
    print(str_activities_time);
    dates = _dates!.map((e) => DateTime.parse(e)).toList();
    times = _times!.map((stringTime) {
      final parts = stringTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1].substring(0, 2));
      bool isPm = parts[1].contains("PM");
      if (isPm && hour < 12) {
        hour += 12;
      } else if (!isPm && hour == 12) {
        hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    }).toList();
    print(dates);
    print(times);
    setState(() {});
    TripModel trip = Provider.of<TripModel>(context, listen: false);
    // print(trip.trip[0]['locations']);
    print(trip.trip[0]['activities_time'].length);

    trip.trip[0]['locations'] = List.generate(dates.length, (index) {
      return [];
    });
    trip.trip[0]['activities_time'] = List.generate(dates.length, (index) {
      return [];
    });
    for (int i = 0; i < json.decode(str_activities_time).length; i++) {
      trip.trip[0]['activities_time'][i] = json.decode(str_activities_time)[i];
    }
    for (int i = 0; i < json.decode(str_location).length; i++) {
      trip.trip[0]['locations'][i] = json.decode(str_location)[i];
    }
    // print(str_location);
    print(trip.trip[0]['locations']);
    _countLocation.clear();
    _countLocation = List<int>.filled(dates.length, 0);
    for (int i = 0; i < trip.trip[0]['locations'].length; i++) {
      _countLocation[i] = trip.trip[0]['locations'][i].length;
    }
    print(_countLocation);
  }

  void updateCount() {
    TripModel trip = Provider.of<TripModel>(context, listen: false);
    _countLocation = List<int>.filled(dates.length, 0);
    for (int i = 0; i < trip.trip[0]['locations'].length; i++) {
      _countLocation[i] = trip.trip[0]['locations'][i].length;
    }
    print(_countLocation);
    setState(() {
      _countLocation = _countLocation;
    });
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }

  @override
  void initState() {
    super.initState();
    getDatatrip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขสถานที่ที่ต้องการไป'),
        backgroundColor: Color(0xFFFC70039),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'รายการสถานที่ที่ต้องการไป',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF141E46),
              ),
            ),
            SizedBox(height: 20),
            //เลือกวันที่ที่ต้องการเพิ่มสถานที่
            Text(
              'เลือกวันที่ที่ต้องการเพิ่มสถานที่',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF141E46),
              ),
            ),
            Divider(
              color: Color(0xFF141E46),
              thickness: 1,
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      splashColor: Color(0xFFFC70039).withAlpha(30),
                      splashFactory: InkRipple.splashFactory,
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MapSelectEdit(
                              idx: index, callback: updateCount);
                        }));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF141E46),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 3,
                                offset: Offset(0, 0),
                              ),
                            ],
                            // gradient: LinearGradient(
                            //   begin: Alignment.topRight,
                            //   end: Alignment.bottomLeft,
                            //   colors: [Color(0xFFFC70039), Color(0xFFFFAFBD)],
                            // ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 48,
                                    color: Color(0xFFFFF5E0),
                                  ),
                                  Text(
                                    'วันที่ ${dates[index]!.day}/${dates[index]!.month}/${dates[index]!.year}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFF5E0),
                                    ),
                                  ),
                                  Text(
                                    'เวลา ${formatTimeOfDay(times[index])}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFFFF5E0),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              //จำนวนสถานที่ที่ต้องการไป
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    '${_countLocation[index]}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return MapSelect(idx: dates.length, callback: updateCount);
          // }));
          try {
            UserModel user = Provider.of<UserModel>(context, listen: false);
            TripModel trip = Provider.of<TripModel>(context, listen: false);
            trip.trip[0]['locations'].forEach((element) {
              if (element.length == 0) {
                throw 'กรุณาเพิ่มสถานที่ที่ต้องการไปให้ครบ';
              }
            });
            var userData = await db
                .collection('user_setting')
                .where('user_email', isEqualTo: user.email)
                .get();
            var user_email = userData.docs[0].data()['user_email'];
            print(user_email);
            //add trip to firestore

            await db.collection('trip').doc(widget.trip_id).update({
              'locations': json.encode(trip.trip[0]['locations']),
              'activities_time': json.encode(trip.trip[0]['activities_time']),
              'trip_dates':
                  dates.map((date) => date!.toIso8601String()).toList(),
              'trip_times': times.map((time) => time.format(context)).toList(),
              'friends': trip.trip[0]['friend_email'],
              'trip_name': trip.trip[0]['name'],
              'is_public': trip.trip[0]['is_public'],
              'trip_type': trip.trip[0]['trip_type'],
            });
            // await db
            //     .collection('user_setting')
            //     .doc(userData.docs[0].id)
            //     .update({
            //   'trip_id': FieldValue.arrayUnion([sstrId])
            // });
            trip.clear_trip();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.remove('trip_dates_edit');
            prefs.remove('trip_times_edit');
            prefs.remove('activities_time');
            prefs.remove('locations');
            prefs.remove('trip_type_edit');

            _showmsgQuickAlert('แก้ไขสถานที่สำเร็จ', 'แก้ไขสถานที่สำเร็จ',
                QuickAlertType.success);
            Future.delayed(Duration(seconds: 4), () {
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) {
                return fabtab();
              }), (route) => false);
            });
          } catch (e) {
            print(e);
            _showmsgQuickAlert(
                'เกิดข้อผิดพลาด', e.toString(), QuickAlertType.error);
          }
        },
        child: Icon(Icons.check),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  String generateRandomId(int length) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
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
}
