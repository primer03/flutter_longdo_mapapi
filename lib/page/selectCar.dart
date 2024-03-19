import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/model/CarService.dart';
import 'package:getgeo/model/oilService.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/Fabtab.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

class selectCar extends StatefulWidget {
  const selectCar({Key? key, required this.login_type}) : super(key: key);
  final String login_type;

  @override
  State<selectCar> createState() => _selectCarState();
}

class _selectCarState extends State<selectCar> {
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadController2 = TextEditingController();
  int? selectedValue = 1;
  String selectoil = '';
  bool isDropdownEnabled = true;
  List<String> Oilname = [];
  List<Map<String, dynamic>> carData = [];
  var db = FirebaseFirestore.instance;

  Future getOil() async {
    var oil = await OilService().getSuggestions();
    print(oil);
    oil.forEach((element) {
      Oilname.add(element['Product']);
    });
    print(Oilname);
    setState(() {
      Oilname = Oilname;
    });
  }

  Future<void> getEvData() async {
    var EvData = await db.collection('ev').get();
    // print(EvData.docs[0].data());
    EvData.docs.forEach((element) {
      carData.add(element.data());
    });
    setState(() {
      carData = carData;
      print(carData);
    });
  }

  Future<List<String>> getCarData(String name) async {
    List<String> carSearch = [];
    if (name == '') return carSearch;
    carData.forEach((element) {
      String strname = element['name'].toString().toUpperCase();
      if (strname.contains(name.toUpperCase())) {
        carSearch.add(element['name']);
      }
    });
    return carSearch;
  }

  @override
  void initState() {
    super.initState();
    getOil();
    getEvData();
    // var username = Provider.of<UserModel>(context, listen: false).get_user();
    // print("username: ${username['username']}");
    // var db = FirebaseFirestore.instance;
    // db
    //     .collection("user_setting")
    //     .where("user_name", isEqualTo: username['username'])
    //     .get()
    //     .then((value) {
    //   if (value.docs.length > 0) {
    //     print(value.docs[0].data());
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => fabtab(),
    //       ),
    //     );
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, Userdata, child) => SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              color: Color(0xFFF5E0), // Set background color to #FFF5E0
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFFC70039),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFF6969).withAlpha(150),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(5, 6),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Image.network('https://i.imgur.com/PdQJBZW.png',
                              width: 150, height: 150),
                          Text(
                            'กรอกข้อมูลรถของคุณ',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Impact',
                              color: Color(
                                  0xFF141E46), // Set text color to #141E46
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Radio(
                                value: 1,
                                groupValue: selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value;
                                    isDropdownEnabled = true;
                                    _typeAheadController.clear();
                                  });
                                },
                              ),
                              Text(
                                'ใช้น้ำมัน',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Impact',
                                  color: Color(
                                      0xFF141E46), // Set text color to #141E46
                                ),
                              ),
                              Radio(
                                value: 2,
                                groupValue: selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value;
                                    isDropdownEnabled = false;
                                    _typeAheadController.clear();
                                  });
                                },
                              ),
                              Text(
                                'ใช้ไฟฟ้า',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Impact',
                                  color: Color(
                                      0xFF141E46), // Set text color to #141E46
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          selectedValue == 2
                              ? TypeAheadField(
                                  noItemsFoundBuilder: (context) => Container(
                                    height: 20,
                                    child: Center(
                                      child: Text(
                                        'ไม่พบข้อมูลรถของคุณ',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Impact',
                                          color: Color(
                                              0xFF141E46), // Set text color to #141E46
                                        ),
                                      ),
                                    ),
                                  ),
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    controller: _typeAheadController,
                                    autofocus: false,
                                    decoration: const InputDecoration(
                                      hintText: 'เลือกแบรนด์รถของคุณ',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                      suffixIcon: Icon(Icons.search,
                                          color: Colors.black),
                                      contentPadding: EdgeInsets.all(5.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  suggestionsCallback: (pattern) {
                                    print(pattern);
                                    return getCarData(pattern);
                                  },
                                  itemBuilder: (context, String suggestion) {
                                    return Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                              suggestion,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Color(
                                                    0xFF141E46), // Set text color to #141E46
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                  itemSeparatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                  onSuggestionSelected: (String suggestion) {
                                    this._typeAheadController.text = suggestion;
                                  },
                                  suggestionsBoxDecoration:
                                      SuggestionsBoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    elevation: 8.0,
                                    color: Theme.of(context).cardColor,
                                  ),
                                )
                              : TypeAheadField(
                                  noItemsFoundBuilder: (context) => Container(
                                    height: 20,
                                    child: Center(
                                      child: Text(
                                        'No Data Found',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Impact',
                                          color: Color(
                                              0xFF141E46), // Set text color to #141E46
                                        ),
                                      ),
                                    ),
                                  ),
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    controller: _typeAheadController,
                                    autofocus: false,
                                    decoration: const InputDecoration(
                                      hintText: 'เลือกแบรนด์รถของคุณ',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                      suffixIcon: Icon(Icons.search,
                                          color: Colors.black),
                                      contentPadding: EdgeInsets.all(5.0),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  suggestionsCallback: (pattern) {
                                    print(pattern);
                                    return CarService.getSuggestions(pattern);
                                  },
                                  itemBuilder: (context, String suggestion) {
                                    return Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                              suggestion,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Color(
                                                    0xFF141E46), // Set text color to #141E46
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                  itemSeparatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                  onSuggestionSelected: (String suggestion) {
                                    this._typeAheadController.text = suggestion;
                                  },
                                  suggestionsBoxDecoration:
                                      SuggestionsBoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    elevation: 8.0,
                                    color: Theme.of(context).cardColor,
                                  ),
                                ),
                          SizedBox(
                            height: 20,
                          ),
                          selectedValue == 1
                              ? DropdownButtonFormField(
                                  value: selectoil == '' ? null : selectoil,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(5.0),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  onChanged: isDropdownEnabled
                                      ? (value) {
                                          setState(() {
                                            selectoil = value.toString();
                                          });
                                        }
                                      : null,
                                  items: Oilname.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                )
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFC70039),
                                // primary: Color(
                                //     0xFFC70039), // Set button color to #C70039
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                var db = FirebaseFirestore.instance;
                                var user = Userdata.get_user();
                                print(user['username']);
                                print(user['email']);
                                var cartype =
                                    selectedValue == 1 ? 'น้ำมัน' : 'ไฟฟ้า';
                                var caroil =
                                    selectedValue == 2 ? '' : selectoil;
                                if (widget.login_type == 'google') {
                                  db.collection("user_setting").add({
                                    "user_name": user['username'],
                                    'user_email': user['email'],
                                    'user_img': user['imgPhoto'],
                                    "car_brand": _typeAheadController.text,
                                    "car_type": cartype,
                                    "car_oil": caroil,
                                    "login_type": widget.login_type,
                                  });
                                } else {
                                  //update data
                                  var Userdata = await db
                                      .collection('user_setting')
                                      .where('user_email',
                                          isEqualTo: user['email'])
                                      .get();
                                  if (Userdata.docs.length > 0) {
                                    print(Userdata.docs[0].id);
                                    db
                                        .collection("user_setting")
                                        .doc(Userdata.docs[0].id)
                                        .update({
                                      "user_name": user['username'],
                                      'user_email': user['email'],
                                      'user_img': user['imgPhoto'],
                                      "car_brand": _typeAheadController.text,
                                      "car_type": cartype,
                                      "car_oil": caroil,
                                      "login_type": widget.login_type,
                                    });
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: user['email'],
                                            password: user['password']);
                                  } else {
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: user['email'],
                                            password: user['password']);
                                    db.collection("user_setting").add({
                                      "user_name": user['username'],
                                      'user_email': user['email'],
                                      'user_img': user['imgPhoto'],
                                      "car_brand": _typeAheadController.text,
                                      "car_type": cartype,
                                      "car_oil": caroil,
                                      "login_type": widget.login_type,
                                    });
                                  }
                                }
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => fabtab(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'บันทึกข้อมูล',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Impact',
                                    color: Color(0xFFFFF5E0),
                                    // backgroundColor: Color(
                                    //     0xFF141E46), // Set text color to #141E46
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
