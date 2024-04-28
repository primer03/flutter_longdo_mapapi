import 'dart:convert';
import 'dart:math';

import 'package:background_location/background_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/Image_show.dart';
import 'package:getgeo/page/edit_trip_list.dart';
import 'package:getgeo/page/rotingtrip.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTravelList extends StatefulWidget {
  const MyTravelList({super.key});

  @override
  State<MyTravelList> createState() => _MyTravelListState();
}

class _MyTravelListState extends State<MyTravelList> {
  var db = FirebaseFirestore.instance;
  var location_data = [];
  var trip_name = [];
  var trip_id = [];
  var friends_img = [];
  String my_email = '';
  double containerWidth = 200;

  double calculateContainerWidth() {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 400) {
      containerWidth = 200;
    } else if (screenWidth < 600) {
      containerWidth = 200;
    } else if (screenWidth < 800) {
      containerWidth = 400;
    } else if (screenWidth < 1000) {
      containerWidth = 500;
    } else {
      containerWidth = 600;
    }
    print('screenWidth: $containerWidth');
    return containerWidth;
  }

  Future<void> deleteTrip(String trip_id) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'คุณต้องการลบทริปนี้?',
      text: 'คุณต้องการลบทริปนี้?',
      cancelBtnText: 'ยกเลิก',
      confirmBtnText: 'ลบทริปนี้',
      confirmBtnColor: Color(0xFFFC70039),
      onConfirmBtnTap: () async {
        print('trip_id: $trip_id');
        db.collection('trip').doc(trip_id).delete();
        Navigator.pop(context);
      },
      onCancelBtnTap: () => Navigator.pop(context),
    );
    // await db.collection('trip').doc(trip_id).delete();
    // loadTripData();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getMyEmail
    User? user = FirebaseAuth.instance.currentUser;
    my_email = user!.email!;
  }

  Future<String> getImage(String email) async {
    var snapshot = await db
        .collection('user_setting')
        .where('user_email', isEqualTo: email)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs[0]['user_img'];
    } else {
      return '';
    }
  }

  Future<void> deleteTripAtfriends(String trip_id) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'ยกเลิกการเข้าร่วมทริปนี้?',
      text: 'คุณต้องการยกเลิกการเข้าร่วมทริปนี้?',
      cancelBtnText: 'ยกเลิก',
      confirmBtnText: 'ยืนยัน',
      confirmBtnColor: Color(0xFFFC70039),
      onConfirmBtnTap: () async {
        var snapshot = await db.collection('trip').doc(trip_id).get();
        var friends = snapshot['friends'];
        db.collection('trip').doc(trip_id).update({
          'friends': FieldValue.arrayRemove([my_email])
        });
        Navigator.pop(context);
      },
      onCancelBtnTap: () => Navigator.pop(context),
    );
  }

  void showDialogLocationList(String data, String activities_time) {
    var location = json.decode(data);
    // print(location.length);
    var dataList = json.decode(activities_time);
    Duration totalDuration = Duration();
    int totalMoney = 0;
    int totalMoneyAtday = 0;
    String str_time = '';
    String str_time_atday = '';
    List<int> money = [];
    int idx = 0;
    int dayselect = 0;
    List<Duration> time = [];
    List<String> str_time_list = [];
    for (int i = 0; i < dataList.length; i++) {
      for (int j = 0; j < dataList[i].length; j++) {
        totalDuration += Duration(
            hours: int.parse(dataList[i][j]['time'].substring(0, 2)),
            minutes: int.parse(dataList[i][j]['time'].substring(3)));
        totalMoney += int.parse(dataList[i][j]['money']);
      }
    }
    print(totalDuration.inMinutes);
    print(totalMoney);
    if (totalDuration.inMinutes > 60) {
      str_time =
          '${totalDuration.inHours} ชั่วโมง ${totalDuration.inMinutes - (totalDuration.inHours * 60)} นาที';
    } else if (totalDuration.inMinutes == 60) {
      str_time = '${totalDuration.inHours + 1} ชั่วโมง';
    } else {
      str_time = '${totalDuration.inMinutes} นาที';
    }
    print(str_time);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (stfContext, stfSetState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(5),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  // height: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "รายการสถานที่",
                        style: TextStyle(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      //tab menu date trip
                      Container(
                        padding: EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (int i = 0; i < location.length; i++)
                                Container(
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      stfSetState(() {
                                        idx = i;
                                        dayselect = i + 1;
                                        money = [];
                                        time = [];
                                        totalMoneyAtday = 0;
                                        str_time_list = [];
                                        str_time_atday = '';
                                        for (int j = 0;
                                            j < dataList[i].length;
                                            j++) {
                                          money.add(int.parse(
                                              dataList[i][j]['money']));
                                          time.add(Duration(
                                              hours: int.parse(dataList[i][j]
                                                      ['time']
                                                  .substring(0, 2)),
                                              minutes: int.parse(dataList[i][j]
                                                      ['time']
                                                  .substring(3))));
                                        }
                                        Duration totalDurationAtday =
                                            Duration();
                                        time.forEach((element) {
                                          totalDurationAtday += element;
                                          if (element.inMinutes > 60) {
                                            str_time_list.add(
                                                '${element.inHours} ชั่วโมง ${element.inMinutes - (element.inHours * 60)} นาที');
                                          } else if (element.inMinutes == 60) {
                                            str_time_list.add(
                                                '${element.inHours} ชั่วโมง');
                                          } else {
                                            str_time_list.add(
                                                '${element.inMinutes} นาที');
                                          }
                                        });
                                        if (totalDurationAtday.inMinutes > 60) {
                                          str_time_atday =
                                              '${totalDurationAtday.inHours} ชั่วโมง ${totalDurationAtday.inMinutes - (totalDurationAtday.inHours * 60)} นาที';
                                        } else if (totalDurationAtday
                                                .inMinutes ==
                                            60) {
                                          str_time_atday =
                                              '${totalDurationAtday.inHours} ชั่วโมง';
                                        } else {
                                          str_time_atday =
                                              '${totalDurationAtday.inMinutes} นาที';
                                        }
                                        money.forEach((element) {
                                          totalMoneyAtday += element;
                                        });
                                        print(money);
                                        // print(time);
                                        totalMoneyAtday = totalMoneyAtday;
                                        print(str_time_list);
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.date_range,
                                          color: Colors.red.shade900,
                                        ),
                                        Text(
                                          "วันที่ ${i + 1}",
                                          style: TextStyle(
                                            color: Colors.red.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      //รายค่าใช้จ่ายและเวลา
                      Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.attach_money,
                                      color: Colors.green,
                                    ),
                                    Text(
                                      "รายการค่าใช้จ่าย",
                                      style: TextStyle(),
                                    ),
                                  ],
                                ),
                                Text(
                                  "ราคาทั้งหมด $totalMoney บาท",
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      color: Colors.blue,
                                    ),
                                    Text(
                                      "เวลาที่ใช่ในการท่องเที่ยว",
                                      style: TextStyle(),
                                    ),
                                  ],
                                ),
                                Text(
                                  "รวม $str_time",
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                            money.length > 0
                                ? SizedBox(height: 10)
                                : Container(),
                            money.length > 0
                                ? Text(
                                    "รายการค่าใช้จ่ายและเวลาของวันที่ $dayselect",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: 10),
                            //รายการค่าใช้จ่ายและเวลาทั้งหมดของแต่ละวัน
                            money.length > 0
                                ? Container(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.attach_money,
                                              color: Colors.green,
                                            ),
                                            Text(
                                              "รวมค่าใช้จ่ายทั้งหมด $totalMoneyAtday บาท",
                                              style: TextStyle(),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.timer,
                                              color: Colors.blue,
                                            ),
                                            Text(
                                              "รวมเวลาทั้งหมด $str_time_atday",
                                              style: TextStyle(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: 10),
                            //location list
                            money.length > 0
                                ? Container(
                                    height: 300,
                                    child: ListView.builder(
                                      itemCount: location[idx].length,
                                      itemBuilder:
                                          (BuildContext context, int i) {
                                        return CustomPaint(
                                          painter: EntryLinePainter(
                                              i, location[idx].length),
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              bottom: 20,
                                              left: 50,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.pink.shade100,
                                                width: 3,
                                              ),
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 9,
                                                  offset: Offset(2, 3),
                                                  // blurStyle: BlurStyle.outer,
                                                ),
                                              ],
                                            ),
                                            child: ListTile(
                                              leading: Icon(
                                                Icons.location_on,
                                                color: Colors.pinkAccent,
                                              ), // กำหนดสีไอคอนเป็นสี red
                                              title: Text(
                                                location[idx][i]['name'],
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors
                                                      .deepPurple, // กำหนดสีข้อความเป็นสี deep orange
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    location[idx][i]['address'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors
                                                          .purple, // กำหนดสีข้อความเป็นสี deep orange accent
                                                    ),
                                                  ),
                                                  Text(
                                                    "${money[i]} บาท ใช้เวลา ${str_time_list[i]}",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors
                                                          .purple, // กำหนดสีข้อความเป็นสี deep orange accent
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -90,
                  child: Image.asset("assets/images/loginlogo.png",
                      width: 150, height: 150),
                )
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการทริปของฉัน'),
        backgroundColor: Color(0xFFFC70039),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('trip')
            .where(Filter.or(Filter('user_email', isEqualTo: my_email),
                Filter('friends', arrayContains: my_email)))
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade900),
                strokeWidth: 10, // เพิ่มความหนาของวงกลม
                backgroundColor: Colors.white,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
            );
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('ไม่พบข้อมูลทริป'),
            );
          }
          final List<DocumentSnapshot> trips = snapshot.data!.docs;
          return Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(20.0),
                  child: InkWell(
                    onTap: () {
                      // Action on tap
                      print('trip_id: ${trip.id}');
                      showDialogLocationList(
                          trip['locations'], trip['activities_time']);
                    },
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.grey[200],
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 3.0,
                        ),
                        // gradient: LinearGradient(
                        //   colors: [
                        //     Color(0xFFFFF6969),
                        //     Color(0xFFFFFF5E0),
                        //   ],
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        // ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        var snapshot = await db
                                            .collection('trip')
                                            .doc(trip.id)
                                            .get();
                                        if (snapshot
                                            .data()!
                                            .containsKey('status')) {
                                          if (snapshot['status'] == 'success') {
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.info,
                                              title: 'ไม่สามารถแก้ไขทริปได้',
                                              text:
                                                  'การเดินทางนี้เสร็จสิ้นแล้ว',
                                              confirmBtnText: 'ตกลง',
                                              confirmBtnColor:
                                                  Color(0xFFFC70039),
                                              onConfirmBtnTap: () =>
                                                  Navigator.pop(context),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditListTrip(
                                                  trip_id: trip.id,
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditListTrip(
                                                trip_id: trip.id,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    //icon photo
                                    SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ImageShowTrip(
                                              trip_id: trip.id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.photo,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              my_email == trip['user_email']
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        deleteTrip(trip.id);
                                      },
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        // deleteTrip(trip.id);
                                        deleteTripAtfriends(trip.id);
                                      },
                                    ),
                            ],
                          ),
                          Text(
                            trip['trip_name'],
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            height: 4.0,
                            width: 60.0,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          ),
                          Container(
                            height: 50.0,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(),
                            child: Stack(
                              children: [
                                Container(
                                  height: 50.0,
                                  width: calculateContainerWidth(),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20.0),
                                      bottomRight: Radius.circular(20.0),
                                    ),
                                  ),
                                ),
                                trip['friends'].length > 0
                                    ? Positioned(
                                        bottom: 0,
                                        right: 8,
                                        child: Container(
                                          height: 30,
                                          width: 100,
                                          padding: EdgeInsets.all(3.0),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withAlpha(150),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20.0),
                                            ),
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: trip['friends'].length,
                                              itemBuilder: (context, idx) {
                                                return Container(
                                                  width: 24.0,
                                                  height: 24.0,
                                                  margin: EdgeInsets.only(
                                                      right: 5.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(100),
                                                    ),
                                                    border: Border.all(
                                                      color:
                                                          Colors.red.shade900,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(100),
                                                    ),
                                                    child:
                                                        FutureBuilder<String>(
                                                      future: getImage(
                                                          trip['friends'][idx]),
                                                      builder:
                                                          (context, snapshotx) {
                                                        if (snapshotx
                                                                .connectionState ==
                                                            ConnectionState
                                                                .done) {
                                                          if (snapshotx
                                                              .hasData) {
                                                            return Image
                                                                .network(
                                                              snapshotx.data ??
                                                                  '',
                                                              fit: BoxFit.cover,
                                                            );
                                                          } else {
                                                            return Icon(
                                                              Icons
                                                                  .account_circle,
                                                              color: Colors
                                                                  .red.shade900,
                                                            );
                                                          }
                                                        } else {
                                                          return CircularProgressIndicator(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            valueColor:
                                                                AlwaysStoppedAnimation(
                                                                    Colors
                                                                        .white),
                                                            strokeWidth: 2.0,
                                                          ); // Placeholder for loading state
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                //play trip btn
                                Positioned(
                                  bottom: -3,
                                  left: -10,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await BackgroundLocation
                                          .stopLocationService();
                                      var snapshot = await db
                                          .collection('trip')
                                          .doc(trip.id)
                                          .get();
                                      if (snapshot
                                          .data()!
                                          .containsKey('status')) {
                                        if (snapshot['status'] == 'success') {
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.confirm,
                                            title: 'การเดินทางนี้เสร็จสิ้นแล้ว',
                                            text:
                                                'คุณต้องการเริ่มการเดินทางใหม่?',
                                            confirmBtnText: 'ตกลง',
                                            cancelBtnText: 'ยกเลิก',
                                            confirmBtnColor: Color(0xFFFC70039),
                                            onConfirmBtnTap: () async {
                                              var trip_id = trip.id;
                                              var datax = await db
                                                  .collection('trip')
                                                  .doc(trip_id)
                                                  .get();
                                              db
                                                  .collection('trip')
                                                  .doc(trip_id)
                                                  .update({
                                                'status': 'notsuccess',
                                                'additional_expense': 0,
                                                'image': [],
                                                'activities_time':
                                                    datax['activities_time']
                                                        .replaceAll(
                                                  'true',
                                                  'false',
                                                ),
                                              });
                                              final SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setBool('isPlay', false);
                                              prefs.setString(
                                                  'trip_id', trip.id);
                                              print('trip_id: ${trip.id}');
                                              Navigator.of(context).pop();
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                builder: (context) {
                                                  return routingtrip(
                                                      trip_id: trip.id);
                                                },
                                              ));
                                            },
                                            onCancelBtnTap: () =>
                                                Navigator.pop(context),
                                          );
                                        } else {
                                          print('trip_id: ${trip.id}');
                                          final SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          bool? isPlay =
                                              prefs.getBool('isPlay');
                                          if (isPlay == null) {
                                            prefs.setBool('isPlay', false);
                                            prefs.setString('trip_id', trip.id);
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                              builder: (context) {
                                                return routingtrip(
                                                    trip_id: trip.id);
                                              },
                                            ));
                                          } else {
                                            var trip_id =
                                                prefs.getString('trip_id');
                                            var isPlay =
                                                prefs.getBool('isPlay');
                                            if (isPlay == true &&
                                                trip_id != trip.id) {
                                              QuickAlert.show(
                                                context: context,
                                                type: QuickAlertType.confirm,
                                                title: 'คุณต้องการเปลี่ยนทริป?',
                                                text: 'คุณต้องการเปลี่ยนทริป?',
                                                cancelBtnText: 'ยกเลิก',
                                                confirmBtnText: 'เปลี่ยนทริป',
                                                confirmBtnColor:
                                                    Color(0xFFFC70039),
                                                onConfirmBtnTap: () async {
                                                  prefs.setBool(
                                                      'isPlay', false);
                                                  prefs.setString(
                                                      'trip_id', trip.id);
                                                  Navigator.of(context).pop();
                                                  Future.delayed(
                                                    Duration(milliseconds: 500),
                                                    () {
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                        builder: (context) {
                                                          return routingtrip(
                                                              trip_id: trip.id);
                                                        },
                                                      ));
                                                    },
                                                  );
                                                },
                                                onCancelBtnTap: () =>
                                                    Navigator.of(context).pop(),
                                              );
                                            } else {
                                              // prefs.setBool('isPlay', false);
                                              prefs.setString(
                                                  'trip_id', trip.id);
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                builder: (context) {
                                                  return routingtrip(
                                                      trip_id: trip.id);
                                                },
                                              ));
                                            }
                                          }
                                        }
                                      } else {
                                        final SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        bool? isPlay = prefs.getBool('isPlay');
                                        if (isPlay == null) {
                                          prefs.setBool('isPlay', false);
                                          prefs.setString('trip_id', trip.id);
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                            builder: (context) {
                                              return routingtrip(
                                                  trip_id: trip.id);
                                            },
                                          ));
                                        } else {
                                          var trip_id =
                                              prefs.getString('trip_id');
                                          var isPlay = prefs.getBool('isPlay');
                                          if (isPlay == true &&
                                              trip_id != trip.id) {
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.confirm,
                                              title: 'คุณต้องการเปลี่ยนทริป?',
                                              text: 'คุณต้องการเปลี่ยนทริป?',
                                              cancelBtnText: 'ยกเลิก',
                                              confirmBtnText: 'เปลี่ยนทริป',
                                              confirmBtnColor:
                                                  Color(0xFFFC70039),
                                              onConfirmBtnTap: () async {
                                                prefs.setBool('isPlay', false);
                                                prefs.setString(
                                                    'trip_id', trip.id);
                                                Navigator.of(context).pop();
                                                Future.delayed(
                                                  Duration(milliseconds: 500),
                                                  () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                      builder: (context) {
                                                        return routingtrip(
                                                            trip_id: trip.id);
                                                      },
                                                    ));
                                                  },
                                                );
                                              },
                                              onCancelBtnTap: () =>
                                                  Navigator.of(context).pop(),
                                            );
                                          } else {
                                            // prefs.setBool('isPlay', false);
                                            prefs.setString('trip_id', trip.id);
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                              builder: (context) {
                                                return routingtrip(
                                                    trip_id: trip.id);
                                              },
                                            ));
                                          }
                                        }
                                      }
                                    },
                                    child: Icon(Icons.play_arrow),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 6, 187, 0),
                                      foregroundColor: Colors.white,
                                      shape: CircleBorder(),
                                      splashFactory: InkRipple.splashFactory,
                                    ),
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
              },
            ),
          );
        },
      ),
    );
  }
}

class EntryLinePainter extends CustomPainter {
  final int index;
  final int length;

  EntryLinePainter(this.index, this.length);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;
    print("custom painter");

    // Existing line drawing code remains unchanged
    if (index != 0) {
      // canvas.drawLine(Offset(-38, size.height / 2), Offset(-38, -38), paint);
      drawDottedLine(canvas, Offset(2, 0), Offset(2, size.height / 2),
          paint); // Draw a dotted line
    }
    if (index != length - 1) {
      final paintx = Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2;
      drawDottedLine(
          canvas, Offset(2, size.height / 2), Offset(2, size.height), paint);
      // canvas.drawLine(Offset(-38, size.height / 2), Offset(-38, 60.0), paint);
    }
    drawDottedLine(canvas, Offset(0, size.height / 2),
        Offset(50, size.height / 2), paint); // Draw a dotted line
    // canvas.drawLine(
    //     Offset(20, size.height / 2), Offset(40, size.height / 2), paint);

    // White background circle
    final paintCircleWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(2, size.height / 2), 10, paintCircleWhite);

    // Red border circle
    final paintCircleRed = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; // Adjust the border thickness here
    canvas.drawCircle(Offset(2, size.height / 2), 10, paintCircleRed);
  }

  void drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dotSize = 5.0; // Size of each dot
    const double space = 5.0; // Space between dots

    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    double distance = sqrt(dx * dx + dy * dy);
    double intervalLength = dotSize + space;

    // Calculate the number of dots
    int numDots = (distance / intervalLength).floor();

    for (int i = 0; i < numDots; i++) {
      // Calculate the x and y coordinates for each dot
      double x = start.dx + (dx / distance) * intervalLength * i;
      double y = start.dy + (dy / distance) * intervalLength * i;
      canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
