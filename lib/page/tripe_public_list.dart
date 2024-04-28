import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:getgeo/page/Image_view.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class TripPublic extends StatefulWidget {
  const TripPublic({super.key});

  @override
  State<TripPublic> createState() => _TripPublicState();
}

class _TripPublicState extends State<TripPublic> {
  var db = FirebaseFirestore.instance;
  TextEditingController _tripNameController = TextEditingController();
  String _selectedTripType = 'ทั้งหมด';
  List<String> selectedType = [];
  User? user = FirebaseAuth.instance.currentUser;
  String my_email = FirebaseAuth.instance.currentUser!.email.toString();
  List<String> _trip_type = [
    "ทั้งหมด",
    "การเดินทางท่องเที่ยว",
    "การเดินทางทางธุรกิจ",
    "การเดินทางทางการศึกษา",
    "การเดินทางทางการแพทย์",
    "การเดินทางทางอนุรักษ์",
    "การเดินทางทางศาสนา",
    "การเดินทางทางกีฬา",
    "การเดินทางทางวัฒนธรรม",
    "การเดินทางทางธรรมชาติ",
  ];
  //icon _trip_type
  List<IconData> _trip_type_icon = [
    Icons.all_inclusive,
    Icons.location_on,
    Icons.business,
    Icons.school,
    Icons.medical_services,
    Icons.eco,
    Icons.trip_origin,
    Icons.sports,
    Icons.museum,
    Icons.nature,
  ];

  //icon color_text
  List<Color> _trip_type_color = [
    Colors.red.shade900,
    Colors.blue.shade900,
    Colors.green.shade900,
    Colors.yellow.shade900,
    Colors.purple.shade900,
    Colors.orange.shade900,
    Colors.pink.shade900,
    Colors.teal.shade900,
    Colors.indigo.shade900,
    Colors.amber.shade900,
  ];
  //icon background
  List<Color> _trip_type_background = [
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.yellow.shade100,
    Colors.purple.shade100,
    Colors.orange.shade100,
    Colors.pink.shade100,
    Colors.teal.shade100,
    Colors.indigo.shade100,
    Colors.amber.shade100,
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

  Future<String> _getUserName(String email) async {
    var user = await db
        .collection('user_setting')
        .where('user_email', isEqualTo: email)
        .get();
    return user.docs[0]['user_name'];
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

  Stream<QuerySnapshot<Object?>> selectTriptype(String query) {
    if (query == 'ทั้งหมด') {
      return db
          .collection('trip')
          .where('is_public', isEqualTo: true)
          .snapshots();
    } else {
      return db
          .collection('trip')
          .where(Filter.and(Filter('is_public', isEqualTo: true),
              Filter('trip_type', isEqualTo: query)))
          .snapshots();
    }
  }

  void showDialogLocationList(
      String data, String activities_time, String trip_id) {
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
                            //รูปการท่องเที่ยว
                            SizedBox(height: 10),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    print(trip_id);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageViewTrip(
                                          trip_id: trip_id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.purple,
                                  ),
                                ),
                                Text(
                                  "รูปภาพที่ถ่ายขณะเดินทาง",
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
        title: Text('รายการทริปสาธารณะ'),
        backgroundColor: Color(0xFFFC70039),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < _trip_type.length; i++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTripType = _trip_type[i];
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            color: _selectedTripType == _trip_type[i]
                                ? _trip_type_color[i]
                                : _trip_type_background[i],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _trip_type_icon[i],
                                color: _selectedTripType == _trip_type[i]
                                    ? Colors.white
                                    : _trip_type_color[i],
                              ),
                              Text(
                                _trip_type[i],
                                style: TextStyle(
                                  color: _selectedTripType == _trip_type[i]
                                      ? Colors.white
                                      : _trip_type_color[i],
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
            Expanded(
              child: StreamBuilder(
                stream: selectTriptype(_selectedTripType),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                      ),
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: EdgeInsets.all(5),
                          child: GestureDetector(
                            onTap: () {
                              showDialogLocationList(
                                  snapshot.data.docs[index]['locations'],
                                  snapshot.data.docs[index]['activities_time'],
                                  snapshot.data.docs[index].id);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                // image: DecorationImage(
                                //   image: NetworkImage(
                                //     "https://i.imgur.com/l0KNong.jpg",
                                //   ),
                                //   fit: BoxFit.cover,
                                // ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: FutureBuilder<String>(
                                      future: getImage(snapshot.data.docs[index]
                                          ['user_email']),
                                      builder: (context, snapshotx) {
                                        if (snapshotx.connectionState ==
                                            ConnectionState.done) {
                                          if (snapshotx.hasData) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    snapshotx.data ?? '',
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            );
                                          } else {
                                            return Placeholder();
                                          }
                                        } else {
                                          return CircularProgressIndicator(
                                            backgroundColor: Colors.transparent,
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white),
                                            strokeWidth: 2.0,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                  ),
                                                  FutureBuilder(
                                                    future: _getUserName(
                                                        snapshot.data
                                                                .docs[index]
                                                            ['user_email']),
                                                    builder:
                                                        (BuildContext context,
                                                            AsyncSnapshot
                                                                snapshot) {
                                                      if (snapshot.hasData) {
                                                        return Text(
                                                          snapshot.data,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        );
                                                      } else {
                                                        return Text(
                                                          '...',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  snapshot.data.docs[index]
                                                              ['user_email'] !=
                                                          my_email
                                                      ? GestureDetector(
                                                          onTap: () async {
                                                            if (snapshot
                                                                .data
                                                                .docs[index]
                                                                    ['bookmark']
                                                                .contains(
                                                                    my_email)) {
                                                              QuickAlert.show(
                                                                context:
                                                                    context,
                                                                type:
                                                                    QuickAlertType
                                                                        .confirm,
                                                                title:
                                                                    'ยกเลิกบุ๊กมาร์ค',
                                                                text:
                                                                    'คุณต้องการยกเลิกบุ๊กมาร์คใช่หรือไม่',
                                                                cancelBtnText:
                                                                    'ยกเลิก',
                                                                confirmBtnText:
                                                                    'ยืนยัน',
                                                                confirmBtnColor:
                                                                    Color(
                                                                        0xFFFC70039),
                                                                onConfirmBtnTap:
                                                                    () async {
                                                                  await db
                                                                      .collection(
                                                                          'trip')
                                                                      .doc(snapshot
                                                                          .data
                                                                          .docs[
                                                                              index]
                                                                          .id)
                                                                      .update({
                                                                    'bookmark':
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      my_email
                                                                    ])
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                onCancelBtnTap: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                              );
                                                            } else {
                                                              await db
                                                                  .collection(
                                                                      'trip')
                                                                  .doc(snapshot
                                                                      .data
                                                                      .docs[
                                                                          index]
                                                                      .id)
                                                                  .update({
                                                                'bookmark':
                                                                    FieldValue
                                                                        .arrayUnion([
                                                                  my_email
                                                                ])
                                                              });
                                                            }
                                                          },
                                                          child: Icon(
                                                            snapshot
                                                                    .data
                                                                    .docs[index]
                                                                        [
                                                                        'bookmark']
                                                                    .contains(
                                                                        my_email)
                                                                ? Icons.bookmark
                                                                : Icons
                                                                    .bookmark_border,
                                                            color: snapshot
                                                                    .data
                                                                    .docs[index]
                                                                        [
                                                                        'bookmark']
                                                                    .contains(
                                                                        my_email)
                                                                ? Colors.red
                                                                : Colors.white,
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: double.infinity,
                                            child: Column(
                                              children: [
                                                Text(
                                                  snapshot.data.docs[index]
                                                      ['trip_name'],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  snapshot.data.docs[index]
                                                      ['trip_type'],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      var aw = await db
                                                          .collection('trip')
                                                          .doc(snapshot.data
                                                              .docs[index].id)
                                                          .get();
                                                      print('${aw.data()}');
                                                      String sstrId =
                                                          generateRandomId(10);
                                                      db
                                                          .collection('trip')
                                                          .add({
                                                        'is_public':
                                                            !aw.data()![
                                                                'is_public'],
                                                        'trip_id': sstrId,
                                                        'trip_name': aw.data()![
                                                            'trip_name'],
                                                        'user_email': my_email,
                                                        'trip_dates':
                                                            aw.data()![
                                                                'trip_dates'],
                                                        'trip_times':
                                                            aw.data()![
                                                                'trip_times'],
                                                        'locations': aw.data()![
                                                            'locations'],
                                                        //เปลี่ยน true เป็น false
                                                        'activities_time': aw
                                                            .data()![
                                                                'activities_time']
                                                            .replaceAll('true',
                                                                'false'),

                                                        'friends': FieldValue
                                                            .arrayUnion([]),
                                                        'favorite': 0,
                                                        'bookmark': FieldValue
                                                            .arrayUnion([]),
                                                        'created_at': FieldValue
                                                            .serverTimestamp(),
                                                        'trip_type': aw.data()![
                                                            'trip_type'],
                                                      });
                                                      QuickAlert.show(
                                                        context: context,
                                                        type: QuickAlertType
                                                            .success,
                                                        title: 'สำเร็จ',
                                                        text:
                                                            'คุณสามารถนำไปใช้ได้',
                                                        onConfirmBtnTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.add_box_outlined,
                                                      color: Colors.yellow,
                                                    ),
                                                  ),
                                                  Text(
                                                    "นำไปใช้",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  snapshot.data.docs[index]['friends'].length >
                                          0
                                      ? Positioned(
                                          bottom: 5,
                                          right: 0,
                                          child: Container(
                                            height: 30,
                                            width: 80,
                                            padding: EdgeInsets.all(3),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(20.0),
                                              ),
                                              child: ListView.builder(
                                                reverse: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: snapshot
                                                    .data
                                                    .docs[index]['friends']
                                                    .length,
                                                itemBuilder: (context, idx) {
                                                  return ClipRRect(
                                                    child: Container(
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
                                                          color: Colors
                                                              .red.shade900,
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(100),
                                                        ),
                                                        child: FutureBuilder<
                                                            String>(
                                                          future: getImage(
                                                              snapshot.data.docs[
                                                                          index]
                                                                      ['friends']
                                                                  [idx]),
                                                          builder: (context,
                                                              snapshotx) {
                                                            if (snapshotx
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .done) {
                                                              if (snapshotx
                                                                  .hasData) {
                                                                return Image
                                                                    .network(
                                                                  snapshotx
                                                                          .data ??
                                                                      '',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                );
                                                              } else {
                                                                return Placeholder();
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
                                                                strokeWidth:
                                                                    2.0,
                                                              ); // Placeholder for loading state
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
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
