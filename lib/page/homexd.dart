import 'package:flutter/material.dart';
import 'package:getgeo/model/mapModel.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/map.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:getgeo/skeleton/SkeletionLoad.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_text/skeleton_text.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var icon = [
    "https://cdn.icon-icons.com/icons2/426/PNG/512/Map_1135px_1195280_42272.png",
    "https://cdn.icon-icons.com/icons2/567/PNG/512/car_icon-icons.com_54409.png",
    "https://icons.iconarchive.com/icons/gartoon-team/gartoon-apps/256/gtodo-todo-list-icon.png",
    "https://i.imgur.com/p2CILFY.png",
    "https://i.imgur.com/BWJml8N.png",
    "https://i.imgur.com/p2CILFY.png",
  ];
  var menulist = [
    "จัดทริป",
    "ราคาน้ำมัน",
    "รายการทริป",
    "รายการทริปอื่นๆ",
    "รายการที่บันทึก",
    ""
  ];

  var data_recommet = [];
  var c = 5;
  bool dataload = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
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
            Image.network(
              "https://i.imgur.com/fVdlpWV.png",
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

  // Future<void> get_userProfile
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, userData, child) => Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  color: Color(0xFFFC70039),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Align(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  child: ClipOval(
                                    child: buildImageWithSkeleton(
                                        userData.imgPhoto),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Hello ${userData.username}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        "Welcome to GetGeo",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Container(
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.map_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 153, 0, 43),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () => print("click"),
                                    icon: Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      width: double.infinity,
                      height: 50,
                    ),
                  ),
                  alignment: Alignment.topCenter,
                ),
              ),
            ],
          ),
          Positioned(
            top: 80,
            left: 11,
            child: Container(
              width: 390,
              // height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(1, 2),
                  ),
                ],
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < 3; i++)
                          GestureDetector(
                            child: Container(
                              width: 100,
                              child: Column(
                                children: [
                                  buildImageWithSkeleton(icon[i],
                                      width: 50, height: 50), // Icon
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    menulist[i],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () => print("click ${i + 1}"),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < 3; i++)
                          GestureDetector(
                            onTap: () => print("click ${i + 1}"),
                            child: Container(
                              width: 100,
                              child: Column(
                                children: [
                                  buildImageWithSkeleton(icon[i + 3],
                                      width: 50, height: 50), // Icon
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    menulist[i + 3],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 265.0,
            left: 11,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 390,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFFC70039),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 5,
                          bottom: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "สถานที่ใกล้เคียง",
                              style: TextStyle(
                                color: Color(0xFFFC70039),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                print(c);
                                print(dataload);
                              },
                              icon: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Color(0xFFFC70039),
                                size: 17,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          height: 120.0,
                          width: 300 * (c) +
                              250, // Adjust the width based on your needs
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
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
