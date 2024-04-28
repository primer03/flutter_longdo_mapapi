import 'dart:convert';
import 'dart:async';
import 'dart:developer';
// import 'dart:ffi';
import 'dart:math';
import 'package:background_location/background_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:getgeo/model/CarService.dart';
import 'package:getgeo/model/NotificationModel.dart';
import 'package:getgeo/model/mapModel.dart';
import 'package:getgeo/model/oilService.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/select_map.dart';
import 'package:getgeo/page/success_trip.dart';
import 'package:intl/intl.dart';
import 'package:longdo_maps_api3_flutter/longdo_maps_api3_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class routingtrip extends StatefulWidget {
  const routingtrip({super.key, required this.trip_id});
  final String trip_id;

  @override
  State<routingtrip> createState() => _routingtripState();
}

class _routingtripState extends State<routingtrip> {
  final map = GlobalKey<LongdoMapState>();
  final GlobalKey<ScaffoldMessengerState> messenger =
      GlobalKey<ScaffoldMessengerState>();
  var db = FirebaseFirestore.instance;
  bool _isDialogVisible = false;
  late Map<String, dynamic> Data_trip = {};
  int? _selectedIndex;
  bool isDropdownEnabled = true;
  int? selectedValue;
  final TextEditingController _typeAheadController = TextEditingController();
  List<Map<String, dynamic>> carData = [];
  List<String> Oilname = [];
  String selectoil = '';
  TextEditingController _oilController = TextEditingController();
  TextEditingController _electricController = TextEditingController();
  bool xIsPlay = false;
  var dataSearch = [];
  var locations = [];
  var activities_time_data = [];
  int? idx_trip;
  List<Map<String, dynamic>> first_location = [];
  TextEditingController _controller = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();
  TextEditingController _controller4 = TextEditingController();
  TextEditingController _money = TextEditingController();

  FocusNode _focusNode = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();
  FocusNode _focusNode4 = FocusNode();
  NotificationModel notificationModel = NotificationModel();
  double totalkilo = 0;
  Map<String, dynamic> afterlocation = {};
  Map<String, dynamic> fuelConsumptionRateMap = {
    "ดีเซลพรีเมียม B7": 11.60,
    "ดีเซล": 11.60,
    "เบนซิน": 10.58,
    "เบนซินแก๊สโซฮอล์ 95": 10.27,
    "เบนซินแก๊สโซฮอล์ 91": 10.39,
    "เบนซินแก๊สโซฮอล์ E20": 9.88,
    "เบนซินแก๊สโซฮอล์ E85": 7.36,
    "ดีเซล B7": 11.60,
    "Super Power GSH95": 10.27,
  };
  int idx_rote = 0;
  void _toggleDialog() {
    setState(() {
      _isDialogVisible = !_isDialogVisible;
    });
  }

  bool isShowMsgRoute = false;

  @override
  void initState() {
    super.initState();
    getEvData();
    getOil();
    _loadDataTrip();
    _checkIsPlay();
    // _toggleDialog();
    getUserData();
  }

  Future<void> getOil() async {
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    var localtion = await Geolocator.getCurrentPosition();
    print("lat: ${localtion.latitude} lon: ${localtion.longitude}");
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _displayDraggableScrollableSheet(BuildContext context) async {
    mapModel maplist = Provider.of<mapModel>(context, listen: false);
    var datamark = maplist.get_map;
    print(datamark);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, //ความสูงเริ่มต้น
          minChildSize: 0.25, //ความสูงต่ำสุด
          maxChildSize: 0.95, //ความสูงสูงสุด
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: ListView.builder(
                controller: scrollController,
                itemCount: datamark.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0xFFC70039), width: 4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          // height: 50,
                          child: ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: Color(0xFF141E46),
                            ),
                            trailing: Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                            title: Text(
                              '${datamark[index]['name']}',
                              style: TextStyle(
                                color: Color(0xFF141E46),
                                fontSize: 17,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
    // load_maplist();
  }

  Future<void> _loadDataTrip() async {
    var my_trip_location =
        await db.collection('trip').doc(widget.trip_id).get();
    var trip_location = my_trip_location.data() ?? {};
    locations = json.decode(trip_location['locations']);
    activities_time_data = json.decode(trip_location['activities_time']);
    print("locations ${activities_time_data}");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // int idx = ?? 0;
    print("idx ${prefs.getInt('idx')}");
    if (prefs.getInt('idx') != null) {
      idx_trip = prefs.getInt('idx');
      activities_time_data[idx_trip!].forEach((element) {
        print("activities_list ${element}");
        if (element['success'] == true) {
          idx_rote++;
        }
      });
    }
    print("activities_time_data ${activities_time_data}");
    setState(() {
      Data_trip = trip_location;
      locations = locations;
      idx_trip = idx_trip;
      activities_time_data = activities_time_data;
      idx_rote = idx_rote;
    });
  }

  String formatDate(String inputDate) {
    List<String> parts = inputDate.split('T');
    List<String> dateParts = parts[0].split('-');
    String formattedDate = '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
    return formattedDate;
  }

  Future<void> getEvData() async {
    var EvData = await db.collection('ev').get();
    print(EvData.docs[0].data());
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
    print("carSearch ${carSearch}");
    return carSearch;
  }

  String formatTime(String inputTime) {
    // กำหนดรูปแบบของเวลา
    DateFormat inputFormat = DateFormat('h:mm a');
    // แปลง string ของเวลาเข้ามาให้เป็น DateTime object
    DateTime time = inputFormat.parse(inputTime);
    // กำหนดรูปแบบของเวลาตาม local timezone
    DateFormat outputFormat = DateFormat.jm();
    // ทำการฟอร์แมตและส่งค่ากลับ
    return outputFormat.format(time);
  }

  Future<void> _checkIsPlay() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isPlay = prefs.getBool('isPlay');
    if (isPlay != null) {
      if (!isPlay) {
        _toggleDialog();
      } else {
        int? idx = prefs.getInt('idx');
        print("idxxxx ${idx}");
        startRote(idx!);
        setState(() {
          xIsPlay = true;
        });
        // startRote(int.parse());
        // final SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setBool('isPlay', false);
      }
    }
  }

  Widget _buildCustomDialog() {
    var date = Data_trip['trip_dates'] ?? [];
    var time = Data_trip['trip_times'] ?? [];
    return Center(
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 550,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "เลือกวันที่ต้องการเดินทาง",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          // mainAxisSize: MainAxisSize.max,
                          children: [
                            for (var i = 0; i < date.length; i++)
                              Container(
                                margin: EdgeInsets.only(right: 10),
                                child: ElevatedButton(
                                  onPressed: () {
                                    print("date ${date[i]}");
                                    setState(() {
                                      _selectedIndex = i;
                                    });
                                    print("index ${_selectedIndex}");
                                  },
                                  child: Text(
                                    formatDate(date[i]),
                                    style: TextStyle(
                                      color: _selectedIndex == i
                                          ? Colors.white
                                          : Color(0xFFC70039),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedIndex == i
                                        ? Color(0xFFC70039)
                                        : Colors.white,
                                    side: BorderSide(
                                      color: _selectedIndex == i
                                          ? Color(0xFFC70039)
                                          : Color(0xFFC70039),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    //radio select type car
                    Text(
                      "เลือกประเภทรถ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio(
                          value: 1,
                          groupValue: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value;
                              isDropdownEnabled = true;
                              _typeAheadController.clear();
                              _oilController.clear();
                              _electricController.clear();
                            });
                            print("isDropdownEnabled ${isDropdownEnabled}");
                          },
                        ),
                        Text(
                          'ใช้น้ำมัน',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Impact',
                            color:
                                Color(0xFF141E46), // Set text color to #141E46
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
                              _oilController.clear();
                              _electricController.clear();
                            });
                            print("selectedValue ${selectedValue}");
                          },
                        ),
                        Text(
                          'ใช้ไฟฟ้า',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Impact',
                            color:
                                Color(0xFF141E46), // Set text color to #141E46
                          ),
                        ),
                      ],
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
                              contentPadding: EdgeInsets.all(20),
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
                              label: Text('เลือกน้ำมันที่ต้องการ'),
                            ),
                            onChanged: (value) {
                              setState(() {
                                selectoil = value.toString();
                              });
                            },
                            items: Oilname.map<DropdownMenuItem<String>>(
                                (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )
                        : selectedValue == 2
                            ? TypeAheadField(
                                noItemsFoundBuilder: (context) => Container(
                                  height: 40,
                                  child: Center(
                                    child: Text(
                                      'ไม่พบข้อมูลรถยนต์ที่คุณค้นหา',
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
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: _typeAheadController,
                                  autofocus: false,
                                  decoration: const InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.electric_car_rounded),
                                    hintText: 'เลือกแบรนด์รถของคุณ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFFFC70039),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    suffixIcon:
                                        Icon(Icons.search, color: Colors.black),
                                    contentPadding: EdgeInsets.all(20),
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
                            : Container(),
                    SizedBox(height: 10),
                    selectedValue == 1
                        ? Text(
                            "น้ำมันของคุณเหลือประมาณกี่ลิตร",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : selectedValue == 2
                            ? Text(
                                "แบตเตอรี่รถของคุณเหลือประมาณกี่เปอร์เซ็นต์",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Container(),

                    SizedBox(height: 10),
                    selectedValue == 1
                        ? TextFormField(
                            controller: _oilController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              contentPadding: EdgeInsets.all(20),
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
                              floatingLabelStyle: TextStyle(
                                color: Color(0xFF141E46),
                              ),
                              label: Text('กรุณากรอกจำนวนน้ำมันที่เหลือ'),
                            ),
                          )
                        : selectedValue == 2
                            ? TextFormField(
                                controller: _electricController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(20),
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
                                  floatingLabelStyle: TextStyle(
                                    color: Color(0xFF141E46),
                                  ),
                                  label: Text('กรุณากรอกเปอร์เซ็นต์แบตเตอรี่'),
                                ),
                              )
                            : Container(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // _toggleDialog();
                print("_selectedIndex ${_selectedIndex}");
                if (_selectedIndex == null) {
                  _showmsgQuickAlert("เกิดข้อผิดพลาด",
                      "กรุณาเลือกวันที่ต้องการเดินทาง", QuickAlertType.error);
                  return;
                }
                if (selectedValue == 1) {
                  if (selectoil == '') {
                    _showmsgQuickAlert("เกิดข้อผิดพลาด",
                        "กรุณาเลือกน้ำมันที่ต้องการ", QuickAlertType.error);
                    return;
                  } else {
                    // print("น้ำมัน");
                    if (_oilController.text == '') {
                      _showmsgQuickAlert("เกิดข้อผิดพลาด",
                          "กรุณากรอกจำนวนน้ำมันที่เหลือ", QuickAlertType.error);
                      return;
                    } else {
                      print("น้ำมัน");
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('isPlay', true);
                      prefs.setInt('idx', _selectedIndex!);
                      prefs.setString('car_oil', selectoil);
                      prefs.setString('oil', _oilController.text);
                      prefs.remove('car_electric');
                      prefs.remove('electric');
                      startRote(_selectedIndex!);
                      print(
                          "activities_time_data ${activities_time_data[_selectedIndex!]}");
                      setState(() {
                        _isDialogVisible = false;
                        xIsPlay = true;
                        idx_trip = _selectedIndex;
                      });
                    }
                  }
                } else if (selectedValue == 2) {
                  if (_typeAheadController.text == '') {
                    _showmsgQuickAlert("เกิดข้อผิดพลาด",
                        "กรุณากรอกแบรนด์รถของคุณ", QuickAlertType.error);
                    return;
                  } else {
                    // print("ไฟฟ้า");
                    if (_electricController.text == '') {
                      _showmsgQuickAlert(
                          "เกิดข้อผิดพลาด",
                          "กรุณากรอกเปอร์เซ็นต์แบตเตอรี่",
                          QuickAlertType.error);
                      return;
                    } else {
                      print("ไฟฟ้า");
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('isPlay', true);
                      prefs.setInt('idx', _selectedIndex!);
                      prefs.setString(
                          'car_electric', _typeAheadController.text);
                      prefs.setString('electric', _electricController.text);
                      prefs.remove('car_oil');
                      prefs.remove('oil');
                      startRote(_selectedIndex!);
                      print(
                          "activities_time_data ${activities_time_data[_selectedIndex!]}");
                      setState(() {
                        _isDialogVisible = false;
                        xIsPlay = true;
                        idx_trip = _selectedIndex;
                      });
                    }
                  }
                } else {
                  _showmsgQuickAlert("เกิดข้อผิดพลาด",
                      "กรุณาเลือกประเภทรถที่ต้องการ", QuickAlertType.error);
                  return;
                }
              },
              child: Text(
                "ยืนยัน",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC70039),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double calculateDistanceOil(double fuelAmount, double fuelConsumptionRate) {
    double distance = fuelAmount / fuelConsumptionRate;
    return distance;
  }

  double calculateElectricTrainRange(
      double batteryPercentage, double rangePerPercentage) {
    // คำนวณระยะทางที่เราสามารถวิ่งได้โดยการคูณร้อยละของแบตเตอรี่กับช่วงของรถ
    double range = (batteryPercentage / 100) * rangePerPercentage;
    return range;
  }

  Future<void> startRote(int idx) async {
    await backgroundLocationPermission((result) {
      if (result) {
        _showmsgQuickAlert(
            "เริ่มเดินทาง", "กำลังค้นหาเส้นทาง", QuickAlertType.loading);
        Future.delayed(Duration(seconds: 3), () async {
          var latlon = _determinePosition();
          var dlat = await latlon.then((value) => value.latitude);
          var dlon = await latlon.then((value) => value.longitude);
          first_location.add({
            'lat': dlat,
            'lon': dlon,
          });
          setState(() {
            first_location = first_location;
          });
          map.currentState?.call("Route.add", args: [
            {
              "lon": dlon,
              "lat": dlat,
            }
          ]);
          var my_trip_location =
              await db.collection('trip').doc(widget.trip_id).get();
          var trip_location = my_trip_location.data() ?? {};
          var locations = json.decode(trip_location['locations']);
          print("locations ${locations[idx]}");
          locations[idx].forEach((element) {
            print("maplist ${element}");
            map.currentState?.call("Route.add", args: [
              {
                "lon": element['lon'],
                "lat": element['lat'],
              }
            ]);
          });
          map.currentState
              ?.run('map.Route.enableRoute(longdo.RouteType.AllDrive, false);');
          map.currentState?.call("Route.search");
          map.currentState?.run('''
map.Route.auto(true);
''');
          Navigator.pop(context);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          bool? isPlay = prefs.getBool('isPlay');
          if (isPlay != null) {
            if (isPlay) {
              setState(() {
                _isDialogVisible = false;
              });
            }
          } else {
            setState(() {
              _isDialogVisible = false;
            });
          }
          await BackgroundLocation.startLocationService(distanceFilter: 0.0);
          await BackgroundLocation.isServiceRunning().then((value) {
            print('Service running: $value');
            // if (!value) {
            //   // backgroundLocation();
            // }
          });
          BackgroundLocation().getCurrentLocation().then((location) {
            print('Location: ${location.latitude}, ${location.longitude}');
          });
          //start location update
          // BackgroundLocation.stopLocationService();

          // notificationModel.shownotification(
          //   title: 'เริ่มเดินทาง',
          //   body: 'ทริป ${Data_trip['trip_name']} กำลังเริ่มเดินทาง',
          // );
          updateRote();
          // BackgroundLocation.getLocationUpdates((p0) => {
          //       print(
          //           'Location: ${p0.latitude}, ${p0.longitude} ${DateTime.now()}')
          //     });
        });
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: 'ตรวจสอบการเปิดใช้งาน Always At All Time',
          text: 'ถ้ากดอนุญาตแล้วให้ปิดหน้าต่างนี้แล้วกดเริ่มเดินทางอีกครั้ง',
          confirmBtnText: 'ตกลง',
          barrierDismissible: true,
          onConfirmBtnTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      }
    });
  }

  Future<void> updateRote() async {
    // print("updateRote ${locations[idx_trip!][0]}");
    // print("updateRote ${locations[idx_trip!][1]}");
    double? lat1;
    double? lon1;
    double? lat2;
    double? lon2;
    bool isPlayxd = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var isPlayx = prefs.getBool('isPlay');
    var car_oil = prefs.getString('car_oil') ?? '';
    var oil = prefs.getString('oil') ?? '';
    var car_electric = prefs.getString('car_electric') ?? '';
    var electric = prefs.getString('electric') ?? '';
    if (car_oil != '') {
      print("car_oil ${car_oil}");
      print("oil ${oil}");
      var distanceFuel = calculateDistanceOil(
          double.parse(oil), fuelConsumptionRateMap[car_oil]);
      print("distanceFuel ${distanceFuel}");
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: 'คำนวนการใช้น้ำมัน',
        // distanceFuel > 1 ให้แสดงเป็นกิโลเมตร ถ้าน้อยกว่า 1 ให้แสดงเมตร
        text: distanceFuel > 1
            ? 'คุณสามารถเดินทางได้ ${distanceFuel.toStringAsFixed(2)} กิโลเมตร'
            : 'คุณสามารถเดินทางได้ ${(distanceFuel * 1000).toStringAsFixed(2)} เมตร',
        confirmBtnText: 'ตกลง',
        barrierDismissible: true,
        onConfirmBtnTap: () {
          Navigator.pop(context);
        },
      );
    } else if (car_electric != '') {
      print("car_electric ${car_electric}");
      print("electric ${electric}");
      print("carData ${carData}");
      int range = 0;
      var car_ev =
          carData.where((element) => element['name'] == car_electric).toList();
      print("car_ev ${car_ev}");
      range = car_ev[0]['range'];
      print("rangxd ${range}");
      var distanceElectric =
          calculateElectricTrainRange(double.parse(electric), range.toDouble());
      print("distanceElectric ${distanceElectric}");
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: 'คำนวนการใช้ไฟฟ้า',
        // distanceElectric > 1 ให้แสดงเป็นกิโลเมตร ถ้าน้อยกว่า 1 ให้แสดงเมตร
        text: distanceElectric > 1
            ? 'คุณสามารถเดินทางได้ ${distanceElectric.toStringAsFixed(2)} กิโลเมตร'
            : 'คุณสามารถเดินทางได้ ${(distanceElectric * 1000).toStringAsFixed(2)} เมตร',
        confirmBtnText: 'ตกลง',
        barrierDismissible: true,
        onConfirmBtnTap: () {
          Navigator.pop(context);
        },
      );
    }
    BackgroundLocation.getLocationUpdates((p0) => {
          print('Location: ${p0.latitude}, ${p0.longitude} ${DateTime.now()}'),
          lat1 = p0.latitude,
          lon1 = p0.longitude,
          updateLocationRoute(lat1!, lon1!),
          // calculateDistanceRote(p0.latitude!, p0.longitude!, lat2!, lon2!),
          // print(
          //     'Location: ${p0.latitude}, ${p0.longitude} , ${lon2} ${lat2}'),
        });
  }

  void updateLocationRoute(double lat1, double lon1) async {
    double? lat2;
    double? lon2;
    if (idx_rote == locations[idx_trip!].length) {
      BackgroundLocation.stopLocationService();

      await BackgroundLocation.stopLocationService();
      var trip_data = await db.collection('trip').doc(widget.trip_id).get();
      var trip_location = trip_data.data() ?? {};
      var activities_time_data = json.decode(trip_location['activities_time']);
      int count_success = 0;
      int check_success = 0;
      int check_success_at_day = 0;
      activities_time_data.forEach((element) {
        element.forEach((element) {
          check_success++;
          if (element['success'] == true) {
            count_success++;
          }
        });
      });
      activities_time_data[idx_trip!].forEach((element) {
        if (element['success'] == true) {
          check_success_at_day++;
        }
      });
      print("count_success ${count_success}");
      if (count_success == check_success) {
        db.collection('trip').doc(widget.trip_id).update({
          'status': 'success',
        });
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isPlay', false);
        prefs.remove('idx');
        prefs.setString('trip_id', widget.trip_id);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'เสร็จสิ้นการเดินทาง',
          text: 'เสร็จสิ้นการเดินทาง',
          confirmBtnText: 'ตกลง',
          barrierDismissible: true,
          onConfirmBtnTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SuccessTrip(),
              ),
            );
          },
        );
      } else if (check_success_at_day ==
          activities_time_data[idx_trip!].length) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isPlay', false);
        prefs.remove('idx');
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'เสร็จสิ้นการเดินทาง',
          text: 'เสร็จสิ้นการเดินทางของวันนี้',
          confirmBtnText: 'ตกลง',
          barrierDismissible: true,
          onConfirmBtnTap: () async {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      } else {
        _showmsgQuickAlert("เสร็จสิ้นการเดินทาง", "เสร็จสิ้นการเดินทาง",
            QuickAlertType.success);
      }
      setState(() {
        xIsPlay = false;
      });
      return;
    }
    if (idx_rote == 0) {
      lat2 = locations[idx_trip!][idx_rote]['lat'];
      lon2 = locations[idx_trip!][idx_rote]['lon'];
      setState(() {
        isShowMsgRoute = true;
      });
    } else if (idx_rote == locations[idx_trip!].length - 1) {
      lat2 = locations[idx_trip!][idx_rote]['lat'];
      lon2 = locations[idx_trip!][idx_rote]['lon'];
      setState(() {
        isShowMsgRoute = true;
      });
    } else {
      lat2 = locations[idx_trip!][idx_rote]['lat'];
      lon2 = locations[idx_trip!][idx_rote]['lon'];
      setState(() {
        isShowMsgRoute = true;
      });
    }
    print("updateLocationRoute ${lat2} ${lon2}");
    calculateDistanceRotXD(lat2!, lon2!);
    // Duration duration = Duration(seconds: 5);
    // Timer.periodic(duration, (timer) {
    //   calculateDistanceRote(lat1, lon1, lat2!, lon2!);
    //   timer.cancel();
    // });
  }

  Future<void> backgroundLocationPermission(Function(bool) onResult) async {
    var status = await Permission.locationAlways
        .request(); // locationAlwaysคือ permission ที่ใช้ในการเปิด background location
    if (status.isGranted) {
      print('Permission granted');
      onResult(true);
      // backgroundLocation();
    } else if (status.isDenied) {
      await Permission.locationAlways.request();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
      //ถ้าเลือกแล้วให้ตรวจสอบอีกครั้งว่าเปิดหรือยัง
      var status = await Permission.locationAlways.status;
      if (status.isGranted) {
        print('Permission granted');
        onResult(true);
        // backgroundLocation();
      } else {
        onResult(false);
      }
    } else if (status.isRestricted) {
      print('Permission restricted');
    }
  }

  // Future<void> _locationRote() async {
  //   // backgroundLocationPermission();
  // }
  void calculateDistanceRotXD(double lat2, double lon2) async {
    var earthRadiusKm = 6371.0; // รัศมีของโลกเฉลี่ยในหน่วยกิโลเมตร
    var my_location = await _determinePosition();
    var lat1 = my_location.latitude;
    var lon1 = my_location.longitude;
    // แปลงพิกัดจาก degrees เป็น radians
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);

    lat1 = _toRadians(lat1);
    lat2 = _toRadians(lat2);

    // ใช้สูตร Haversine เพื่อคำนวณระยะห่าง
    var a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var distance = earthRadiusKm * c;
    //แสดงเมตร กับ กิโลเมตร
    var resulte = distance;
    if (resulte < 1) {
      print("${(resulte * 1000).toStringAsFixed(2)} เมตร");
      print("${resulte * 1000}");
      if ((resulte * 1000) < 200.0) {
        //
        print("รถใกล้เกินไป");

        if (isShowMsgRoute) {
          notificationModel.shownotification(
            title: 'คุณถึงสถานที่แล้ว',
            body:
                'คุณถึงสถานที่ ${locations[idx_trip!][idx_rote]['name']} แล้ว',
          );
          notificationModel.shownotification(
            title: 'เวลาที่คุณจะอยู่สถานที่',
            body:
                'คุณจะอยู่สถานที่ ${locations[idx_trip!][idx_rote]['name']} ประมาณ ${convertToMinutes(activities_time_data[idx_trip!][idx_rote]['time'])} นาที',
          );
          notificationModel.showNotificationAfterDelay(
            title: 'หมดเวลา',
            body: 'หมดเวลา ${locations[idx_trip!][idx_rote]['name']} แล้ว',
            delay: Duration(
                minutes: convertToMinutes(
                    activities_time_data[idx_trip!][idx_rote]['time'])),
          );
        }
        setState(() {
          activities_time_data[idx_trip!][idx_rote]['success'] = true;
          print("activities_time_data ${activities_time_data}");

          idx_rote++;
          isShowMsgRoute = false;
          updateactivities();
        });
      } else {
        print("รถอยู่ในระยะที่กำหนด");
      }
    } else {
      print("${resulte.toStringAsFixed(2)} กิโลเมตร");
    }
  }

  int convertToMinutes(String time) {
    List<String> parts = time.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    print("${hours * 60 + minutes}");
    return hours * 60 + minutes;
  }

  Future<void> updateactivities() async {
    var my_trip_location =
        await db.collection('trip').doc(widget.trip_id).update(
      {
        'activities_time': json.encode(activities_time_data),
      },
    );
  }

  void _showmsgQuickAlert(String title, String msg, QuickAlertType type) {
    QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: msg,
      confirmBtnText: 'ตกลง',
      barrierDismissible: type == QuickAlertType.loading ? false : true,
    );
  }

  Future<void> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var user_data = await db
          .collection('user_setting')
          .where('user_email', isEqualTo: user.email)
          .get();
      print("user_data ${user_data.docs[0].data()}");
      setState(() {
        if (user_data.docs[0].data()['car_type'] == "น้ำมัน") {
          selectedValue = 1;
          selectoil = user_data.docs[0].data()['car_oil'];
          isDropdownEnabled = true;
        } else {
          selectedValue = 2;
          isDropdownEnabled = false;
          _typeAheadController.text = user_data.docs[0].data()['car_brand'];
        }
      });
    }
  }

  Future<void> _showStation(String tag) async {
    _showmsgQuickAlert(
        "กำลังค้นหา", "กำลังค้นหา${tag}ใกล้เคียง", QuickAlertType.loading);
    var apiKey = "804903bb8f1b3b154a6f11b156adaf62";
    var my_location = await _determinePosition();
    var lat = my_location.latitude;
    var lon = my_location.longitude;
    var span = "20km";
    final url = Uri.parse(
        'https://api.longdo.com/POIService/json/search?key=${apiKey}&lon=${lon}&lat=${lat}&limit=50&tag=${tag}&span=${span}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      // ใช้ setState จาก StatefulBuilder เพื่ออัพเดท UI
      print(jsonData['data']);
      setState(() {
        dataSearch = jsonData['data'];
      });
    }
    if (dataSearch.length == 0) {
      _showmsgQuickAlert(
          "ไม่พบข้อมูล", "ไม่พบข้อมูล${tag}ใกล้เคียง", QuickAlertType.error);
    } else {
      Navigator.of(context).pop();
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.all(10),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 500,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.fromLTRB(10, 50, 10, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${tag}ใกล้เคียง",
                            style: TextStyle(fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          //อัพเดท จำนวน น้ำมันที่เติมใหม่
                          ElevatedButton(
                            onPressed: () {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.custom,
                                title: 'อัพเดมจำนวนน้ำมัน',
                                text: 'อัพเดมจำนวนน้ำมันที่ต้องการเติมใหม่',
                                confirmBtnText: 'ตกลง',
                                cancelBtnText: 'ยกเลิก',
                                widget: Container(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: tag == "ปั๊มน้ำมัน"
                                            ? _oilController
                                            : _electricController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.all(20),
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
                                          floatingLabelStyle: TextStyle(
                                            color: Color(0xFF141E46),
                                          ),
                                          label: tag == "ปั๊มน้ำมัน"
                                              ? Text(
                                                  'กรุณากรอกจำนวนน้ำมันที่ต้องการอัพเดท')
                                              : Text(
                                                  'กรุณากรอกเปอร์เซ็นต์แบตเตอรี่ที่ต้องการอัพเดท',
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onConfirmBtnTap: () async {
                                  if (tag == "ปั๊มน้ำมัน") {
                                    final SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    var car_oil =
                                        prefs.getString('car_oil') ?? '';
                                    if (car_oil != '') {
                                      if (_oilController.text == '') {
                                        _showmsgQuickAlert(
                                            "เกิดข้อผิดพลาด",
                                            "กรุณากรอกจำนวนน้ำมันที่เหลือ",
                                            QuickAlertType.error);
                                        return;
                                      } else {
                                        setState(() {
                                          _oilController.text =
                                              _oilController.text;
                                        });
                                        print("น้ำมัน");
                                        final SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();

                                        prefs.setString('car_oil', selectoil);
                                        var distanceFuel = calculateDistanceOil(
                                            double.parse(_oilController.text),
                                            fuelConsumptionRateMap[selectoil]);
                                        print("distanceFuel ${distanceFuel}");
                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.info,
                                          title: 'คำนวนการใช้น้ำมัน',
                                          // distanceFuel > 1 ให้แสดงเป็นกิโลเมตร ถ้าน้อยกว่า 1 ให้แสดงเมตร
                                          text: distanceFuel > 1
                                              ? 'คุณสามารถเดินทางได้ ${distanceFuel.toStringAsFixed(2)} กิโลเมตร'
                                              : 'คุณสามารถเดินทางได้ ${(distanceFuel * 1000).toStringAsFixed(2)} เมตร',
                                          confirmBtnText: 'ตกลง',
                                          barrierDismissible: true,
                                          onConfirmBtnTap: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                        );
                                      }
                                    } else {
                                      _showmsgQuickAlert(
                                          "เกิดข้อผิดพลาด",
                                          "โปรดตรวจสอบข้อมูลรถของคุณ",
                                          QuickAlertType.error);
                                      return;
                                    }
                                  } else {
                                    final SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    var car_electric =
                                        prefs.getString('car_electric') ?? '';
                                    if (car_electric != '') {
                                      if (_electricController.text == '') {
                                        _showmsgQuickAlert(
                                            "เกิดข้อผิดพลาด",
                                            "กรุณากรอกเปอร์เซ็นต์แบตเตอรี่",
                                            QuickAlertType.error);
                                        return;
                                      } else {
                                        setState(() {
                                          _electricController.text =
                                              _electricController.text;
                                        });
                                        print("ไฟฟ้า");
                                        final SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.setString('car_electric',
                                            _typeAheadController.text);
                                        var car_ev = carData
                                            .where((element) =>
                                                element['name'] ==
                                                _typeAheadController.text)
                                            .toList();
                                        print("car_ev ${car_ev}");
                                        int range = car_ev[0]['range'];
                                        print("rangxd ${range}");
                                        var distanceElectric =
                                            calculateElectricTrainRange(
                                                double.parse(
                                                    _electricController.text),
                                                range.toDouble());
                                        print(
                                            "distanceElectric ${distanceElectric}");
                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.info,
                                          title: 'คำนวนการใช้ไฟฟ้า',
                                          // distanceElectric > 1 ให้แสดงเป็นกิโลเมตร ถ้าน้อยกว่า 1 ให้แสดงเมตร
                                          text: distanceElectric > 1
                                              ? 'คุณสามารถเดินทางได้ ${distanceElectric.toStringAsFixed(2)} กิโลเมตร'
                                              : 'คุณสามารถเดินทางได้ ${(distanceElectric * 1000).toStringAsFixed(2)} เมตร',
                                          confirmBtnText: 'ตกลง',
                                          barrierDismissible: true,
                                          onConfirmBtnTap: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                        );
                                      }
                                    } else {
                                      _showmsgQuickAlert(
                                          "เกิดข้อผิดพลาด",
                                          "โปรดตรวจสอบข้อมูลรถของคุณ",
                                          QuickAlertType.error);
                                      return;
                                    }
                                  }
                                },
                                onCancelBtnTap: () {
                                  Navigator.pop(context);
                                },
                              );
                            },
                            child: Text(
                              tag == "ปั๊มน้ำมัน"
                                  ? "อัพเดทจำนวนน้ำมัน"
                                  : "อัพเดทเปอร์เซ็นต์แบตเตอรี่",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFC70039),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: dataSearch.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: 10,
                                    left: 10,
                                    right: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashFactory: InkRipple.splashFactory,
                                      highlightColor: Colors.transparent,
                                      splashColor:
                                          Color(0xFFFC70039)!.withOpacity(0.7),
                                      radius: 50,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      onTap: () {},
                                      child: ListTile(
                                        splashColor: Color(0xFFFC70039),
                                        title: Text(
                                          dataSearch[index]['name'],
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Text(dataSearch[index]['address']),
                                            Text(
                                              "ระยะทาง: ${formatDistance(double.parse(dataSearch[index]['distance'].substring(0, 4)))}",
                                              style: TextStyle(
                                                color: Colors
                                                    .blue, // กำหนดสีให้กับข้อความระยะทาง
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Image.network(
                                          "https://mmmap15.longdo.com/mmmap/images/icons_4x/${dataSearch[index]['icon']}",
                                          width: 50,
                                          height: 50,
                                        ),
                                        onTap: () {
                                          map.currentState
                                              ?.call("location", args: [
                                            {
                                              "lon": dataSearch[index]['lon'],
                                              "lat": dataSearch[index]['lat'],
                                            }
                                          ]);
                                          // Navigator.pop(context);
                                        },
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
                    Positioned(
                      top: -100,
                      child: Image.asset("assets/images/loginlogo.png",
                          width: 150, height: 150),
                    )
                  ],
                ));
          },
        );
      },
    );
  }

  Future<void> calculateDistanceRote(
      double lat1, double lon1, double lat2, double lon2) async {
    try {
      const apikey = "556e31e859f72e9ec99600ae7135f479";
      final url = Uri.parse(
          'https://api.longdo.com/RouteService/json/route/guide?flon=${lon1}&flat=${lat1}&tlon=${lon2}&tlat=${lat2}&mode=t&locale=th&key=${apikey}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // var distance = jsonData['distance'];
        // return formatDistance(distance);
        // print("jsonData ${jsonData['data'][0]['distance']}");
        var resulte = jsonData['data'][0]['distance'] * 0.001;
        if (resulte < 1) {
          print("${(resulte * 1000).toStringAsFixed(2)} เมตร");
          print("${resulte * 1000}");
          if ((resulte * 1000) < 200.0) {
            //
            print("รถใกล้เกินไป");

            if (isShowMsgRoute) {
              notificationModel.shownotification(
                title: 'คุณถึงสถานที่แล้ว',
                body:
                    'คุณถึงสถานที่ ${locations[idx_trip!][idx_rote]['name']} แล้ว',
              );
            }
            setState(() {
              idx_rote++;
              isShowMsgRoute = true;
            });
          } else {
            print("รถอยู่ในระยะที่กำหนด");
          }
        } else {
          print("${resulte.toStringAsFixed(2)} กิโลเมตร");
        }
        // return "${metersToKilometers(jsonData['data'][0]['distance'])}";
      } else {}
    } catch (e) {
      print(e);
    }
  }

  void calculateKilo(double lat2, double lon2) async {
    var earthRadiusKm = 6371.0; // รัศมีของโลกเฉลี่ยในหน่วยกิโลเมตร
    var my_location = await _determinePosition();
    var lat1 = 0.0;
    var lon1 = 0.0;
    if (afterlocation == null) {
      afterlocation.addAll({
        'lat': my_location.latitude,
        'lon': my_location.longitude,
      });
      lon1 = my_location.longitude;
      lat1 = my_location.latitude;
    } else {
      //check location ซ้ำ
      if (afterlocation['lat'] == my_location.latitude &&
          afterlocation['lon'] == my_location.longitude) {
        print("location ซ้ำ");
        return;
      } else {
        afterlocation['lat'] = my_location.latitude;
        afterlocation['lon'] = my_location.longitude;
        lon1 = my_location.longitude;
        lat1 = my_location.latitude;
      }
    }
    setState(() {
      afterlocation = afterlocation;
    });

    // แปลงพิกัดจาก degrees เป็น radians
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);

    lat1 = _toRadians(lat1);
    lat2 = _toRadians(lat2);

    // ใช้สูตร Haversine เพื่อคำนวณระยะห่าง
    var a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var distance = earthRadiusKm * c;
    //แสดงเมตร กับ กิโลเมตร
    var resulte = distance;
    setState(() {
      totalkilo += resulte;
    });
    if (resulte < 1) {
      print("${(resulte * 1000).toStringAsFixed(2)} เมตร");
      print("${resulte * 1000}");
    } else {
      print("${resulte.toStringAsFixed(2)} กิโลเมตร");
    }
  }

  Future<String> calculateDistance(double lat2, double lon2, int idxX) async {
    var earthRadiusKm = 6371.0; // รัศมีของโลกเฉลี่ยในหน่วยกิโลเมตร
    print("idx ${idxX}");
    var my_location = await _determinePosition();
    var lat1 = 0.0;
    var lon1 = 0.0;
    if (idxX == 0) {
      lat1 = my_location.latitude;
      lon1 = my_location.longitude;
    } else if (idxX < locations.length) {
      print("idx ${idxX}");
      lat1 = locations[idx_trip!]![idxX - 1]['lat'];
      lon1 = locations[idx_trip!]![idxX - 1]['lon'];
    } else {
      lat1 = locations[idx_trip!]![idxX - 1]['lat'];
      lon1 = locations[idx_trip!]![idxX - 1]['lon'];
    }
    try {
      const apikey = "556e31e859f72e9ec99600ae7135f479";
      final url = Uri.parse(
          'https://api.longdo.com/RouteService/json/route/guide?flon=${lon1}&flat=${lat1}&tlon=${lon2}&tlat=${lat2}&mode=t&locale=th&key=${apikey}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // var distance = jsonData['distance'];
        // return formatDistance(distance);
        print("jsonData ${jsonData['data'][0]['distance'].runtimeType}");
        return "${metersToKilometers(jsonData['data'][0]['distance'])}";
      } else {
        return "ไม่สามารถคำนวณระยะทางได้";
      }
    } catch (e) {
      print(e);
      return "ไม่สามารถคำนวณระยะทางได้ $e";
    }
  }

  String metersToKilometers(int meters) {
    // 1 เมตร = 0.001 กิโลเมตร
    var resulte = meters * 0.001;
    if (resulte < 1) {
      return "${(resulte * 1000).toStringAsFixed(2)} เมตร";
    } else {
      return "${resulte.toStringAsFixed(2)} กิโลเมตร";
    }
  }

  double _toRadians(double degree) {
    return degree * (pi / 180.0);
  }

  void confirmeditMark(int idx, Function(bool) onResult) {
    _controller.clear();
    _controller2.clear();
    _controller3.clear();
    _controller4.clear();
    _money.clear();
    String time = "";
    String money = "";
    var trip = json.decode(Data_trip['activities_time']);
    print(trip[idx_trip]);
    // print(trip.trip[0]['activities_time'][widget.idx][idx]['time']);
    time = trip[idx_trip][idx]['time']
        .replaceAll(new RegExp(r'[^0-9]'), ''); // ลบทุกอย่างที่ไม่ใช่ตัวเลข
    money = trip[idx_trip][idx]['money'];
    print("time ${time} money ${money}");
    List<String> timeList = time.split('');
    _controller.text = timeList[0];
    _controller2.text = timeList[1];
    _controller3.text = timeList[2];
    _controller4.text = timeList[3];
    _money.text = money;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.custom,
      title: 'เลือกเวลาและค่าใช้จ่าย',
      text: 'เลือกเวลาและค่าใช้จ่ายของสถานที่นี้',
      confirmBtnText: 'ยืนยัน',
      cancelBtnText: 'ยกเลิก',
      showCancelBtn: true,
      onCancelBtnTap: () {
        Navigator.of(context).pop();
        onResult(false);
      },
      cancelBtnTextStyle: TextStyle(
        color: Colors.red,
        fontSize: 15,
      ),
      confirmBtnTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      confirmBtnColor: Colors.green,
      customAsset: 'assets/images/giphy.gif',
      width: MediaQuery.of(context).size.width * 0.9,
      widget: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                child: Text(
                  "เลือกเวลา",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Form(
                child: Row(
                  // mainAxisSize: MainAxisSize.,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: TextFormField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          labelText: '',
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1) {
                            _focusNode2.requestFocus();
                          } else if (value.length == 0) {
                            _focusNode4.unfocus();
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: TextFormField(
                        controller: _controller2,
                        focusNode: _focusNode2,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '',
                          contentPadding: EdgeInsets.all(10),
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1) {
                            _focusNode3.requestFocus();
                          } else if (value.isEmpty) {
                            _focusNode.requestFocus();
                          }
                        },
                      ),
                    ),
                    Text(
                      ":",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: TextFormField(
                        controller: _controller3,
                        focusNode: _focusNode3,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp('[0-5]')), // อนุญาตให้ใส่ได้แค่ตัวเลข 0-5
                        ],
                        decoration: InputDecoration(
                          labelText: '',
                          contentPadding: EdgeInsets.all(10),
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1) {
                            _focusNode4.requestFocus();
                          } else if (value.length == 0) {
                            _focusNode2.requestFocus();
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: _controller4,
                        focusNode: _focusNode4,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '',
                          contentPadding: EdgeInsets.all(10),
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1) {
                            _focusNode4.unfocus();
                          } else if (value.length == 0) {
                            _focusNode3.requestFocus();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: Text(
                  "เลือกค่าใช้จ่าย",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _money,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  hintText: 'ค่าใช้จ่าย',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onConfirmBtnTap: () async {
        if (_controller.text == "" ||
            _controller2.text == "" ||
            _controller3.text == "" ||
            _controller4.text == "" ||
            _money.text == "") {
          _showmsgQuickAlert(
              "แจ้งเตือน", "กรุณากรอกข้อมูลให้ครบ", QuickAlertType.error);
        } else {
          var time = _controller.text +
              _controller2.text +
              ":" +
              _controller3.text +
              _controller4.text;
          var money = _money.text;
          print("time ${time} money ${money}");
          await db.collection('trip').doc(widget.trip_id).get().then((value) {
            var trip = value.data() ?? {};
            var activities_time = json.decode(trip['activities_time']);
            activities_time[idx_trip][idx]['time'] = time;
            activities_time[idx_trip][idx]['money'] = money;
            db.collection('trip').doc(widget.trip_id).update({
              'activities_time': json.encode(activities_time),
            });
          });
          trip[idx_trip][idx]['time'] = time;
          trip[idx_trip][idx]['money'] = money;
          print("idx ${trip}");
          setState(() {
            Data_trip['activities_time'] = json.encode(trip);
          });
          // print("idx ${Data_trip['activities_time']}");
          // var activities_time = await db
          //     .collection('trip')
          //     .doc(widget.trip_id)
          //     .get()
          //     .then((value) => value.data() ?? {});
          // print("activities_time ${activities_time['activities_time']}");
          // var tripx = json.decode(activities_time['activities_time']);

          onResult(true);
          Navigator.of(context).pop();
        }
      },
    );
  }

  Future<void> _showLocation() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                padding: EdgeInsets.fromLTRB(5, 50, 5, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "รายการสถานที่",
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: locations[idx_trip!].length,
                        itemBuilder: (context, index) {
                          return CustomPaint(
                            painter: EntryLinePainter(
                              index,
                              locations[idx_trip!].length,
                              activities_time_data[idx_trip!]![index]
                                  ['success'],
                            ),
                            child: Container(
                              margin: EdgeInsets.only(
                                bottom: 10,
                                left: 30,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashFactory: InkRipple.splashFactory,
                                      highlightColor: Colors.transparent,
                                      splashColor:
                                          Color(0xFFFC70039)!.withOpacity(0.7),
                                      radius: 50,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      onTap: () {},
                                      child: ListTile(
                                        splashColor: Color(0xFFFC70039),
                                        title: Text(
                                          locations[idx_trip!][index]['name'],
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        leading: GestureDetector(
                                          onTap: () {
                                            map.currentState
                                                ?.call("location", args: [
                                              {
                                                "lon": locations[idx_trip!]
                                                    [index]['lon'],
                                                "lat": locations[idx_trip!]
                                                    [index]['lat'],
                                              }
                                            ]);
                                          },
                                          child: Image.network(
                                            "https://mmmap15.longdo.com/mmmap/images/icons_4x/${locations[idx_trip!][index]['icon']}",
                                            width: 50,
                                            height: 50,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Text(dataSearch[index]['address']),
                                            FutureBuilder<String>(
                                              future: calculateDistance(
                                                locations[idx_trip!][index]
                                                    ['lat'],
                                                locations[idx_trip!][index]
                                                    ['lon'],
                                                index,
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Text(
                                                    "ระยะทาง: ${snapshot.data}",
                                                    style: TextStyle(
                                                      color: Colors
                                                          .blue, // กำหนดสีให้กับข้อความระยะทาง
                                                    ),
                                                  );
                                                } else {
                                                  return Text("กำลังคำนวณ...");
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        // trailing: Image.network(
                                        //   "https://mmmap15.longdo.com/mmmap/images/icons_4x/${locations[index]['icon']}",
                                        //   width: 50,
                                        //   height: 50,
                                        // ),
                                        onTap: () {
                                          print("index ${index}");
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -5,
                                    right: 0,
                                    child: TextButton(
                                      onPressed: () {
                                        confirmeditMark(index, (result) {
                                          if (result) {
                                            print("result ${result}");
                                          }
                                        });
                                      },
                                      child: Text(
                                        "แก้ไขกิจกรรม",
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -100,
                child: Image.asset("assets/images/loginlogo.png",
                    width: 150, height: 150),
              )
            ],
          ),
        );
      },
    );
  }

  String formatDistance(double distance) {
    if (distance >= 1) {
      return '${distance.toStringAsFixed(3)} กิโลเมตร';
    } else {
      double meters = distance * 1000;
      return '${meters.toStringAsFixed(2)} เมตร';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, value, child) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text("ค้นหาเส้นทาง"),
          backgroundColor: Color(0xFFC70039),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: Color(0xFFC70039),
        //   onPressed: () => _displayDraggableScrollableSheet(context),
        //   child: Icon(Icons.navigation),
        // ),
        body: Stack(
          children: [
            Expanded(
              flex: 2,
              child: LongdoMapWidget(
                apiKey: "556e31e859f72e9ec99600ae7135f479",
                key: map,
                eventName: [
                  JavascriptChannel(
                    name: "ready",
                    onMessageReceived: (JavascriptMessage message) async {
                      print("ready click");
                      var lay = map.currentState
                          ?.LongdoStatic("Layers", 'RASTER_POI');
                      if (lay != null) {
                        print("ready");
                        map.currentState?.call('Layers.setBase', args: [lay]);
                      }
                      var latlon = _determinePosition();
                      var dlat = await latlon.then((value) => value.latitude);
                      var dlon = await latlon.then((value) => value.longitude);
                      print(latlon);
                      latlon.then(
                        (value) => {
                          setState(
                            () {
                              map.currentState?.call("location", args: [
                                {
                                  "lon": value.longitude,
                                  "lat": value.latitude,
                                }
                              ]);
                            },
                          ),
                        },
                      );
                      // mapModel maplist =
                      //     Provider.of<mapModel>(context, listen: false);
                      // print("maplist");
                      print("dlat: ${dlat} dlon: ${dlon}");
                      // map.currentState?.call("Route.add", args: [
                      //   {
                      //     "lon": dlon,
                      //     "lat": dlat,
                      //   }
                      // ]);
                      // var my_trip_location =
                      //     await db.collection('trip').doc(widget.trip_id).get();
                      // var trip_location = my_trip_location.data() ?? {};
                      // var locations = json.decode(trip_location['locations']);
                      // locations.forEach((element) {
                      //   print("maplist ${element}");
                      //   element.forEach((el) {
                      //     print("el ${el['lat']} ${el['lon']}");
                      //     map.currentState?.call("Route.add", args: [
                      //       {
                      //         "lon": el['lon'],
                      //         "lat": el['lat'],
                      //       }
                      //     ]);
                      //   });
                      // });

                      // maplist.get_map.forEach((element) {
                      //   print("maplist ${element['name']}");
                      //   print("lat: ${element['lat']} lon: ${element['lon']}");
                      //   map.currentState?.call("Route.add", args: [
                      //     {
                      //       "lon": element['lon'],
                      //       "lat": element['lat'],
                      //     }
                      //   ]);
                      // });
                      // map.currentState?.run(
                      //     'map.Route.enableRoute(longdo.RouteType.AllDrive, false);');

                      // if (AllDrive != null) {
                      //   map.currentState
                      //       ?.call("Route.enableRoute", args: [AllDrive, false]);
                      // }
//                       map.currentState?.call("Route.search");
//                       map.currentState?.run('''
// map.Route.auto(true);
// ''');
                      // load_maplist();
                    },
                  ),
                  JavascriptChannel(
                    name: "click",
                    onMessageReceived: (message) async {
                      // print("click XD");
                      // print(jsonDecode(message.message)['data']);
                      var data = jsonDecode(message.message)['data'];
                      print("data ${data}");
                      var lat = data['lat'];
                      var lon = data['lon'];
                    },
                  ),
                ],
                options: {
                  // "ui": Longdo.LongdoStatic(
                  //   "UiComponent",
                  //   "None",
                  // )
                },
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton(
                backgroundColor: Color(0xFFC70039),
                onPressed: () async {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.confirm,
                    title: "ยืนยันการหยุดเดินทาง",
                    text: "คุณต้องการรีเซ็ตเส้นทางด้วยหรือไม่",
                    confirmBtnText: 'ยืนยัน',
                    cancelBtnText: 'ไม่ต้องรีเซ็ต',
                    onConfirmBtnTap: () async {
                      map.currentState?.call("Route.clear");
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove('isPlay');
                      prefs.remove('idx');
                      setState(() {
                        xIsPlay = false;
                      });
                      var my_trip_location =
                          await db.collection('trip').doc(widget.trip_id).get();
                      var trip_location = my_trip_location.data() ?? {};
                      var activity =
                          json.decode(trip_location['activities_time']);
                      activity[idx_trip!].forEach((element) {
                        element['success'] = false;
                      });
                      await db.collection('trip').doc(widget.trip_id).update({
                        'activities_time': json.encode(activity),
                      });
                      await db.collection('trip').doc(widget.trip_id).update({
                        'status': 'notsuccess',
                      });
                      BackgroundLocation.stopLocationService();
                      Navigator.of(context).pop();
                      Future.delayed(Duration(milliseconds: 500), () {
                        Navigator.pop(context);
                      });
                    },
                    onCancelBtnTap: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool('isPlay', false);
                      setState(() {
                        xIsPlay = false;
                        // _isDialogVisible = true;
                      });
                      BackgroundLocation.stopLocationService();
                      Navigator.of(context).pop();
                      Future.delayed(Duration(milliseconds: 500), () {
                        Navigator.pop(context);
                      });
                    },
                  );
                },
                child: Icon(
                  xIsPlay ? Icons.stop : Icons.play_arrow,
                ),
              ),
            ),
            Positioned(
              bottom: 70,
              right: 10,
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () {
                  _showLocation();
                },
                child: Icon(
                  Icons.list,
                  color: Colors.white,
                ),
              ),
            ),
            //my location
            Positioned(
              bottom: 130,
              right: 10,
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () async {
                  var latlon = _determinePosition();
                  var dlat = await latlon.then((value) => value.latitude);
                  var dlon = await latlon.then((value) => value.longitude);
                  print(latlon);
                  latlon.then(
                    (value) => {
                      setState(
                        () {
                          map.currentState?.call("location", args: [
                            {
                              "lon": value.longitude,
                              "lat": value.latitude,
                            }
                          ]);
                        },
                      ),
                    },
                  );
                },
                child: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
              ),
            ),
            //menu station oil and electric
            Positioned(
              bottom: 5,
              left: 10,
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showStation("ปั๊มน้ำมัน");
                      },
                      child: Icon(
                        Icons.local_gas_station,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC70039),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(50, 50),
                        padding: EdgeInsets.all(10),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _showStation("สถานีชาร์จรถไฟฟ้า");
                      },
                      child: Icon(
                        Icons.electric_car,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC70039),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(50, 50),
                        padding: EdgeInsets.all(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isDialogVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {}, // Optional: close dialog on tap outside
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            // Custom Dialog
            if (_isDialogVisible) _buildCustomDialog(),
          ],
        ),
      ),
    );
  }
}

class EntryLinePainter extends CustomPainter {
  final int index;
  final int length;
  final bool status;

  EntryLinePainter(this.index, this.length, this.status);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;
    print("custom painter");

    // Existing line drawing code remains unchanged
    if (index != 0) {
      // canvas.drawLine(Offset(-38, size.height / 2), Offset(-38, -38), paint);
      drawDottedLine(canvas, Offset(5, 0), Offset(5, size.height / 2),
          paint); // Draw a dotted line
    }
    if (index != length - 1) {
      final paintx = Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2;
      drawDottedLine(
          canvas, Offset(5, size.height / 2), Offset(5, size.height), paint);
      // canvas.drawLine(Offset(-38, size.height / 2), Offset(-38, 60.0), paint);
    }
    drawDottedLine(canvas, Offset(0, size.height / 2),
        Offset(50, size.height / 2), paint); // Draw a dotted line
    // canvas.drawLine(
    //     Offset(20, size.height / 2), Offset(40, size.height / 2), paint);

    // White background circle
    final paintCircleWhite = Paint()
      ..color = status ? Colors.green.shade700 : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(6, size.height / 2), 10, paintCircleWhite);

    // Red border circle
    final paintCircleRed = Paint()
      ..color = Colors.green.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; // Adjust the border thickness here
    canvas.drawCircle(Offset(6, size.height / 2), 10, paintCircleRed);
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
