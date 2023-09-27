import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:getgeo/page/home.dart';
import 'package:getgeo/page/map.dart';
import 'package:getgeo/page/map_search.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:getgeo/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class Firexd extends StatefulWidget {
  const Firexd({super.key, required String title});

  @override
  State<Firexd> createState() => _FirexdState();
}

class _FirexdState extends State<Firexd> {
  List<dynamic> datalist = [];
  var currentScreen = Mymap(title: "");
  int _page = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    get_anime();
    search_anime("Naruto");
  }

  Future<void> get_anime() async {
    datalist.clear();
    var db = FirebaseFirestore.instance;
    final data = await db.collection('Anime').get();
    final List<QueryDocumentSnapshot> documents = data.docs;
    // var dataId = documents[0].id;
    // print(dataId);
    if (documents.length > 0) {
      for (var i = 0; i < documents.length; i++) {
        datalist.add({
          "id": documents[i].id,
          "anime_id": documents[i]["anime_id"],
          "anime_name": documents[i]["anime_name"],
        });
      }
      setState(() {
        datalist = datalist;
      });
    } else {
      setState(() {
        datalist = [];
      });
      print("No Data");
    }
  }

  Random random = new Random();
  bool isEdit = false;

  Future<void> edit_anime_dialog(String id, String currentName) async {
    TextEditingController newNameController = TextEditingController();
    isEdit = false;
    newNameController.text = currentName;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                // shadowColor: Colors.red,
                title: Text('Edit Anime Name'),
                content: TextField(
                  controller: newNameController,
                  decoration: InputDecoration(
                    labelText: 'New Name',
                    errorText: isEdit ? 'Value Can\'t Be Empty' : null,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isEdit ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Save'),
                    onPressed: () async {
                      if (newNameController.text.isNotEmpty) {
                        var db = FirebaseFirestore.instance;
                        await db.collection("Anime").doc(id).update({
                          "anime_name": newNameController.text,
                        });
                        get_anime();
                        setState(() {
                          newNameController.text = "";
                        });
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          isEdit = true;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          );
        });
  }

  var TextFieldAdd = TextEditingController();

  Future<void> search_anime(String name) async {
    var db = FirebaseFirestore.instance;
    final data =
        await db.collection('Anime').where("anime_name", isEqualTo: name).get();
    final List<QueryDocumentSnapshot> documents = data.docs;
    documents.forEach((element) {
      print(
          "ID : ${element.id} , Name : ${element["anime_name"]} , ID : ${element["anime_id"]}");
    });
  }

  @override
  Widget build(BuildContext context) {
    print(datalist);
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextFieldAdd,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Add Anime',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          var db = FirebaseFirestore.instance;
                          db.collection("Anime").add({
                            "anime_id": random.nextInt(9000) + 1000,
                            "anime_name": TextFieldAdd.text,
                          });
                          get_anime();
                          setState(() {
                            TextFieldAdd.text = "";
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          child: Icon(Icons.add_box_outlined),
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.deepPurple),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    for (var i = 0; i < datalist.length; i++)
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            // borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              title: Text(
                                  "${i + 1}. ${datalist[i]["anime_name"]}"),
                              subtitle: Text("ID : ${datalist[i]["anime_id"]}"),
                              trailing: GestureDetector(
                                  onTap: () {},
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          edit_anime_dialog(datalist[i]["id"],
                                              datalist[i]["anime_name"]);
                                          print(datalist[i]["id"]);
                                        },
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.green,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          var db = FirebaseFirestore.instance;
                                          db
                                              .collection("Anime")
                                              .doc(datalist[i]["id"])
                                              .delete();
                                          get_anime();
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      )
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
