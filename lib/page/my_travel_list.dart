import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:provider/provider.dart';

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
  double containerWidth = 200;
  Future<void> loadTripData() async {
    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    var user_email = userModel.email;
    var snapshot = await db
        .collection('trip')
        .where('user_email', isEqualTo: user_email)
        .get();
    print('data: ${snapshot.docs.length}');
    if (snapshot.docs.isNotEmpty) {
      for (var i = 0; i < snapshot.docs.length; i++) {
        var data = snapshot.docs[i];
        trip_name.add(data['trip_name']);
        trip_id.add(data.id);
        location_data = json.decode(data['locations']);
        List<dynamic> friends_data = data['friends'];
        friends_img.insert(i, []);
        for (var j = 0; j < friends_data.length; j++) {
          var friend_email = friends_data[j];
          var friend_data = await db
              .collection('user_setting')
              .where('user_email', isEqualTo: friend_email)
              .get();
          if (friend_data.docs.isNotEmpty) {
            // var friend_img = friend_data.docs[0]['img'];
            // friends_img.add(friend_img);
            // print('friend_img: ${friend_data.docs[0]['user_img']}');
            friends_img[i].add(friend_data.docs[0]['user_img']);
          }
        }
      }
      // print('trip_name: $trip_name');
      // print('trip_id: $trip_id');
      print('location_data: ${location_data.length}');
      print('friends_img: $friends_img');
      //remove unique value friends_img
      // friends_img = friends_img.toSet().toList();
      setState(() {
        // location_data = location_data;
        trip_name = trip_name;
        trip_id = trip_id;
        // friends_img = friends_img;
      });
    } else {
      print('No data');
    }
  }

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadTripData();
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
        body: Container(
          padding: EdgeInsets.all(8.0), // Add padding around the grid
          decoration: BoxDecoration(
            color: Colors
                .grey[100], // Light background color for the whole container
          ),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: trip_name.length,
            itemBuilder: (context, index) {
              return Material(
                elevation: 5.0, // Add elevation for depth
                borderRadius: BorderRadius.circular(20.0), // Round corners
                child: InkWell(
                  onTap: () {
                    // Action on tap
                  },
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFFF6969),
                          Color(0xFFFFFF5E0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround, // Space items evenly
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.edit_location_outlined,
                                  color: Colors.white70),
                              Icon(Icons.delete, color: Colors.redAccent),
                            ],
                          ),
                        ),
                        Text(
                          trip_name[index],
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFC70039)),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          height: 4.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            color: Color(0xFFFC70039),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Icon(Icons.people,
                        //           color: Colors.white70, size: 20.0),
                        //       SizedBox(width: 4.0),
                        //       Text(
                        //         "5 participants",
                        //         style: TextStyle(
                        //           color: Colors.white70,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
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
                                  // color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 8,
                                child: Container(
                                  height: 30,
                                  width: 120,
                                  padding: EdgeInsets.all(5.0),
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
                                      itemCount: friends_img[index].length,
                                      itemBuilder: (context, idx) {
                                        return Container(
                                          height: 35.0,
                                          margin: EdgeInsets.only(right: 5.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(50.0),
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(50.0),
                                            ),
                                            child: Image.network(
                                              friends_img[index][idx],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
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
        ));
  }
}
