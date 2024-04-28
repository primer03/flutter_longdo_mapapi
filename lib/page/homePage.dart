import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/model/mapModel.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/Image_view.dart';
import 'package:getgeo/page/Oilpage.dart';
import 'package:getgeo/page/addtrip.dart';
import 'package:getgeo/page/edit_profile.dart';
import 'package:getgeo/page/map.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:getgeo/page/my_travel_list.dart';
import 'package:getgeo/page/trip_bookmark.dart';
import 'package:getgeo/page/tripe_public_list.dart';
import 'package:getgeo/skeleton/SkeletionLoad.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:card_swiper/card_swiper.dart';

class HomepageBU extends StatefulWidget {
  const HomepageBU({super.key});

  @override
  State<HomepageBU> createState() => _HomepageBUState();
}

class _HomepageBUState extends State<HomepageBU> {
  var icon = [
    "https://cdn.icon-icons.com/icons2/426/PNG/512/Map_1135px_1195280_42272.png",
    "https://cdn.icon-icons.com/icons2/567/PNG/512/car_icon-icons.com_54409.png",
    "https://icons.iconarchive.com/icons/gartoon-team/gartoon-apps/256/gtodo-todo-list-icon.png",
    "https://i.imgur.com/p2CILFY.png",
    "https://i.imgur.com/BWJml8N.png",
    "https://i.imgur.com/ioCT1hd.png",
  ];
  var menulist = [
    "จัดทริป",
    "ราคาน้ำมัน",
    "รายการทริป",
    "รายการทริปอื่นๆ",
    "รายการที่บันทึก",
    "ข้อมูลส่วนตัว"
  ];

  var data_recommet = [];
  var c = 5;
  bool dataload = false;
  var db = FirebaseFirestore.instance;
  var my_email = FirebaseAuth.instance.currentUser!.email;
  dynamic snapshot;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    loadsnapshot();
  }

  Widget buildSkeletonAnimation({double width = 50, double height = 50}) {
    return SkeletonAnimation(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Future<void> loadsnapshot() async {
    //limit(5)
    snapshot = await db.collection('trip').orderBy('created_at').limit(5).get();
    print("snapshot: ${snapshot.docs.length}");
    snapshot.docs.forEach((element) {
      // print(element.data());
    });
    print("snapshot data: ${snapshot.docs[0].data()['trip_id']}");
    setState(() {
      snapshot = snapshot;
    });
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

  Widget buildContainer(int i) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            Image.network(
              "https://mmmap15.longdo.com/mmmap/images/icons_4x/${data_recommet[i]['icon']}",
              width: 50,
              height: 50,
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: 220,
                    child: Text(
                      data_recommet[i]['name'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: 220,
                    child: Text(
                      data_recommet[i]['address'],
                      style: TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  data_recommet[i]['distance'],
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  String generateRandomId(int length) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
  }

  Widget buildContainerLoader(int i) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            buildSkeletonAnimation(height: 50, width: 50),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                      width: 220,
                      child: buildSkeletonAnimation(width: 200, height: 10)),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                      width: 220,
                      child: buildSkeletonAnimation(width: 200, height: 10)),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                      width: 220,
                      child: buildSkeletonAnimation(width: 150, height: 10)),
                ),
                SizedBox(
                  height: 5,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                      width: 220,
                      child: buildSkeletonAnimation(width: 100, height: 10)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _fetchLocation() async {
    var location = await mapModel().get_geolocatio();
    print("location: ${location}");
    location.forEach((element) {
      setState(() {
        data_recommet.add({
          "name": element['name'],
          "address": element['address'],
          "tel": element['tel'],
          "distance": element['distance'],
          "tag": element['tag'],
          "icon": element['icon'],
        });
      });
    });
    setState(() {
      c = data_recommet.length != 0 ? data_recommet.length : 5;
      dataload = true;
    });
  }

  Widget buildImageWithSkeleton(String imageUrl,
      {double? width, double? height}) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return SkeletonAnimation(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          );
        }
      },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return Icon(Icons.error);
      },
    );
  }

  Future<String> _getUserName(String email) async {
    var user = await db
        .collection('user_setting')
        .where('user_email', isEqualTo: email)
        .get();
    return user.docs[0]['user_name'];
  }

  // Future<void> get_userProfile
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, userData, child) => Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 280,
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Color(0xFFFC70039),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(top: 24),
                        width: double.infinity,
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Color.fromARGB(255, 158, 0, 0),
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: userData.imgPhoto != ""
                                        ? buildImageWithSkeleton(
                                            userData.imgPhoto!,
                                            width: 50,
                                            height: 50,
                                          )
                                        : buildSkeletonAnimation(
                                            width: 50,
                                            height: 50,
                                          ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userData.username != null
                                          ? userData.username!
                                          : "Guest",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Welcome to GetGeo",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            // Spacer(), //
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      left: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width *
                              0.96, //คือความกว้าง ของ container
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 5,
                                spreadRadius: 2,
                                offset: Offset(1, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: List.generate(2, (row) {
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(
                                        3,
                                        (index) {
                                          int i = index + row * 3;
                                          return Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              splashFactory:
                                                  InkRipple.splashFactory,
                                              highlightColor:
                                                  Colors.transparent,
                                              splashColor: Color(0xFFFC70039)!
                                                  .withOpacity(0.7),
                                              radius: 50,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              onTap: () => {
                                                if (i == 1)
                                                  {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Oilpage(),
                                                      ),
                                                    ),
                                                  }
                                                else if (i == 0)
                                                  {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            TripPage(),
                                                      ),
                                                    ),
                                                  }
                                                else if (i == 2)
                                                  {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyTravelList(),
                                                      ),
                                                    ),
                                                  }
                                                else if (i == 3)
                                                  {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            TripPublic(),
                                                      ),
                                                    ),
                                                  }
                                                else if (i == 4)
                                                  {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            TripBookMark(),
                                                      ),
                                                    ),
                                                  }
                                                else if (i == 5)
                                                  {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditProfile(),
                                                      ),
                                                    ),
                                                  }
                                              },
                                              child: Container(
                                                width: 100,
                                                child: Column(
                                                  children: [
                                                    buildImageWithSkeleton(
                                                      icon[i],
                                                      width: 50,
                                                      height: 50,
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      menulist[i],
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                          // return GestureDetector(
                                          //   onTap: () => print("click ${i + 1}"),
                                          //   child: Container(
                                          //     width: 100,
                                          //     child: Column(
                                          //       children: [
                                          //         buildImageWithSkeleton(icon[i],
                                          //             width: 50, height: 50),
                                          //         SizedBox(height: 5),
                                          //         Text(
                                          //           menulist[i],
                                          //           style: TextStyle(
                                          //             fontSize: 10,
                                          //             fontWeight: FontWeight.bold,
                                          //           ),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // );
                                        },
                                      ),
                                    ),
                                    if (row == 0) SizedBox(height: 15),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFFC70039)!,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "สถานที่ใกล้เคียง",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFC70039)!,
                        ),
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFFFC70039)!,
                        ),
                        onTap: () => print("click"),
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: 10),
              Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 120.0,
                      width: 300 * (c) + 250,
                      child: Row(
                        children: [
                          for (var i = 0; i < c; i++)
                            dataload
                                ? buildContainer(i)
                                : buildContainerLoader(i),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                "ทริปที่น่าสนใจ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFC70039)!,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 600,
                margin: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: StreamBuilder(
                  stream: db
                      .collection('trip')
                      .where('is_public', isEqualTo: true)
                      // .orderBy('created_at', descending: true)
                      .limit(4)
                      .snapshots(),
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
                                    snapshot.data.docs[index]
                                        ['activities_time'],
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
                                        future: getImage(snapshot
                                            .data.docs[index]['user_email']),
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
                                              backgroundColor:
                                                  Colors.transparent,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
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
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                            ),
                                                          );
                                                        } else {
                                                          return Text(
                                                            '...',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
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
                                                    snapshot.data.docs[index][
                                                                'user_email'] !=
                                                            my_email
                                                        ? GestureDetector(
                                                            onTap: () async {
                                                              if (snapshot
                                                                  .data
                                                                  .docs[index][
                                                                      'bookmark']
                                                                  .contains(
                                                                      my_email)) {
                                                                QuickAlert.show(
                                                                  context:
                                                                      context,
                                                                  type: QuickAlertType
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
                                                                            .docs[index]
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
                                                                  onCancelBtnTap:
                                                                      () => Navigator
                                                                          .pop(
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
                                                                      .docs[
                                                                          index]
                                                                          [
                                                                          'bookmark']
                                                                      .contains(
                                                                          my_email)
                                                                  ? Icons
                                                                      .bookmark
                                                                  : Icons
                                                                      .bookmark_border,
                                                              color: snapshot
                                                                      .data
                                                                      .docs[
                                                                          index]
                                                                          [
                                                                          'bookmark']
                                                                      .contains(
                                                                          my_email)
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .white,
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                            generateRandomId(
                                                                10);
                                                        db
                                                            .collection('trip')
                                                            .add({
                                                          'is_public':
                                                              !aw.data()![
                                                                  'is_public'],
                                                          'trip_id': sstrId,
                                                          'trip_name':
                                                              aw.data()![
                                                                  'trip_name'],
                                                          'user_email':
                                                              my_email,
                                                          'trip_dates':
                                                              aw.data()![
                                                                  'trip_dates'],
                                                          'trip_times':
                                                              aw.data()![
                                                                  'trip_times'],
                                                          'locations':
                                                              aw.data()![
                                                                  'locations'],
                                                          //เปลี่ยน true เป็น false
                                                          'activities_time': aw
                                                              .data()![
                                                                  'activities_time']
                                                              .replaceAll(
                                                                  'true',
                                                                  'false'),

                                                          'friends': FieldValue
                                                              .arrayUnion([]),
                                                          'favorite': 0,
                                                          'bookmark': FieldValue
                                                              .arrayUnion([]),
                                                          'created_at': FieldValue
                                                              .serverTimestamp(),
                                                          'trip_type':
                                                              aw.data()![
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
                                    snapshot.data.docs[index]['friends']
                                                .length >
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(
                                                                100),
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
                                                            Radius.circular(
                                                                100),
                                                          ),
                                                          child: FutureBuilder<
                                                              String>(
                                                            future: getImage(snapshot
                                                                    .data
                                                                    .docs[index]
                                                                [
                                                                'friends'][idx]),
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
              SizedBox(height: 90),
            ],
          ),
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
