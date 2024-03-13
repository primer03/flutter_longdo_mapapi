import 'package:flutter/material.dart';
import 'package:getgeo/model/mapModel.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/map.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:getgeo/skeleton/SkeletionLoad.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_text/skeleton_text.dart';

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
      builder: (context, userData, child) => Container(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
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
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Color.fromARGB(255, 158, 0, 0),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: userData.imgPhoto != null
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  userData.username != null
                                      ? userData.username!
                                      : "username",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                margin: EdgeInsets.only(left: 13),
                                child: Text(
                                  "Welcome to GetGeo",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            width: MediaQuery.of(context).size.width * 0.3,
                            margin: EdgeInsets.only(left: 9),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
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
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 100),
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    child: Swiper(
                      itemCount: 6,
                      viewportFraction: 0.8,
                      scale: 0.9,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.only(top: 10),
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                width: MediaQuery.of(context).size.width,
                                height: 100,
                                child: Image.network(
                                  icon[index],
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                child: Text(
                                  menulist[index],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
