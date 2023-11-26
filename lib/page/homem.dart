import 'package:flutter/material.dart';
import 'package:getgeo/page/map.dart';
import 'package:card_swiper/card_swiper.dart';

class Homexd extends StatefulWidget {
  const Homexd({super.key, required this.img_url, required this.username});
  final String img_url;
  final String username;
  @override
  State<Homexd> createState() => _HomexdState();
}

class _HomexdState extends State<Homexd> {
  var cardcheck = [false, false, false, false, false, false];
  var iconlist = [
    Icons.location_pin,
    Icons.add_a_photo,
    Icons.add_a_photo,
    Icons.add_a_photo,
    Icons.add_a_photo,
    Icons.add_a_photo
  ];
  var labellist = [
    "Location",
    "Photo",
    "Photo",
    "Photo",
    "Photo",
    "Photo",
  ];
  var imagelist = [
    "https://i.imgur.com/QN6jDwt.png",
    "https://i.imgur.com/XDzJICa.jpg",
    "https://i.imgur.com/SHlO0qG.jpg",
    "https://i.imgur.com/xW7A0Ig.jpg",
  ];
  var pagelist = [
    Mymap(title: "Map"),
    Mymap(title: "Map"),
    Mymap(title: "Map"),
    Mymap(title: "Map"),
    Mymap(title: "Map"),
    Mymap(title: "Map"),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          // gradient: LinearGradient(
          //     colors: [Colors.blue, Colors.red],
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight)),
          // border: Border.all(color: Colors.deepPurple, width: 2),
          ),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFFFC70039), Color(0xFFFF6969)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 74,
                      width: 74,
                      decoration: BoxDecoration(
                        border: Border.all(width: 3, color: Color(0xFFFFF5E0)),
                        borderRadius: BorderRadius.circular(100), //<-- SEE HERE
                      ),
                      child: ClipOval(
                        child: Image.network(widget.img_url,
                            fit: BoxFit.fill, width: 75, height: 75),
                      ),
                    ),
                    Text(
                      "${widget.username}",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 0,
                left: 8,
                right: 8,
                bottom: 0,
              ),
              child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < 3; i++)
                          GestureDetector(
                            onLongPress: () {
                              setState(() {
                                cardcheck[i] = !cardcheck[i];
                              });
                            },
                            onLongPressEnd: (value) {
                              setState(() {
                                cardcheck[i] = !cardcheck[i];
                              });
                            },
                            onTap: () {
                              setState(() {
                                cardcheck[i] = !cardcheck[i];
                              });
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => pagelist[i]),
                              // );
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xFFC70039), width: 2),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFFF5E0),
                                      Color(0xFFFF6969)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                                boxShadow: [
                                  BoxShadow(
                                    color: cardcheck[i]
                                        ? Color(0xFFFF6969)
                                        : Colors.grey.withOpacity(0.5),
                                    blurRadius: cardcheck[i]
                                        ? 10
                                        : 2, // เปลี่ยนค่า blurRadius
                                    spreadRadius: cardcheck[i]
                                        ? 3
                                        : 1, // เปลี่ยนค่า spreadRadius
                                    offset: Offset(5, 5),
                                  ),
                                ],
                              ),
                              width: 120,
                              height: 100,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    iconlist[i],
                                    size: 50,
                                    color: Color(0xFF141E46),
                                  ),
                                  Text(
                                    labellist[i],
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF141E46)),
                                  ),
                                ],
                              )),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 3; i < 6; i++)
                          GestureDetector(
                            onLongPress: () {
                              setState(() {
                                cardcheck[i] = !cardcheck[i];
                              });
                            },
                            onLongPressEnd: (value) {
                              setState(() {
                                cardcheck[i] = !cardcheck[i];
                              });
                            },
                            onTap: () {
                              setState(() {
                                cardcheck[i] = !cardcheck[i];
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xFFC70039), width: 2),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFFF5E0),
                                      Color(0xFFFF6969)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                                boxShadow: [
                                  BoxShadow(
                                    color: cardcheck[i]
                                        ? Color(0xFFFF6969)
                                        : Colors.grey.withOpacity(0.5),
                                    blurRadius: cardcheck[i]
                                        ? 10
                                        : 2, // เปลี่ยนค่า blurRadius
                                    spreadRadius: cardcheck[i]
                                        ? 3
                                        : 1, // เปลี่ยนค่า spreadRadius
                                    offset: Offset(5, 5),
                                  ),
                                ],
                              ),
                              width: 120,
                              height: 100,
                              child: Center(
                                child: Icon(
                                  iconlist[i],
                                  size: 50,
                                  color: Color(0xFF141E46),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFF6969),
                          blurRadius: 5, // เปลี่ยนค่า blurRadius
                          spreadRadius: 2, // เปลี่ยนค่า spreadRadius
                          offset: Offset(7, 5),
                        ),
                      ],
                      gradient: LinearGradient(
                          colors: [Color(0xFFFC70039), Color(0xFFFF6969)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recommend",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF141E46)),
                        ),
                        Icon(
                          Icons.menu,
                          color: Color(0xFF141E46),
                        )
                      ],
                    ),
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 200, // Set the desired height here
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return Image.network(
                        imagelist[index],
                        fit: BoxFit.contain,
                      );
                    },
                    duration: 1000,
                    autoplay: true,
                    itemCount: 4,
                    viewportFraction: 0.35,
                    scale: 0.6,
                    pagination: const SwiperPagination(
                      builder: DotSwiperPaginationBuilder(
                          color: Colors.red, activeColor: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5, // เปลี่ยนค่า blurRadius
                      spreadRadius: 2, // เปลี่ยนค่า spreadRadius
                      offset: Offset(4, 5),
                    ),
                  ],
                ),
                width: double.infinity,
                height: 140, // Set the desired height here
                child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on_rounded,
                        size: 100,
                        color: Colors.green,
                      ),
                      Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "จำนวนเงิน",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Text(
                            "เวลาที่เหลือ",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 120,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "20,000 บาท",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Text(
                            "50 นาที",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      ),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
