import 'dart:convert';
import 'dart:async';
import 'dart:math';
// import 'dart:developer';
// import 'dart:ffi';
// import 'dart:math';
// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:getgeo/model/TripModel.dart';
import 'package:getgeo/model/mapModel.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:longdo_maps_api3_flutter/longdo_maps_api3_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class MapSelectEdit extends StatefulWidget {
  const MapSelectEdit({
    super.key,
    required this.idx,
    required this.callback,
  });
  final int idx;
  final VoidCallback callback;

  @override
  State<MapSelectEdit> createState() => _MapSelectEditState();
}

class _MapSelectEditState extends State<MapSelectEdit> {
  final map = GlobalKey<LongdoMapState>();
  final GlobalKey<ScaffoldMessengerState> messenger =
      GlobalKey<ScaffoldMessengerState>();
  var dataMark = [];
  Object? mark;
  bool _isDialogVisible = false;
  bool _isLoading = false;
  var dataSearch = [];
  List<dynamic> _num = [0, 0, 0, 0];
  int _currentValue = 0;
  double bottom_list = 15;
  TextEditingController _controller = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();
  TextEditingController _controller4 = TextEditingController();
  TextEditingController _money = TextEditingController();

  FocusNode _focusNode = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode3 = FocusNode();
  FocusNode _focusNode4 = FocusNode();

  void _toggleDialog() {
    setState(() {
      _isDialogVisible = !_isDialogVisible;
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

  Future<void> searchData(value) async {
    try {
      const apikey = "804903bb8f1b3b154a6f11b156adaf62";
      final url = Uri.parse(
          'https://search.longdo.com/mapsearch/json/search?keyword=${value}&limit=40&key=${apikey}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        dataSearch = jsonData['data'];
        setState(() {
          dataSearch = dataSearch;
        });
        print(dataSearch);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<String> calculateDistance(double lat2, double lon2) async {
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
    if (distance > 1) {
      // ระยะทางมากกว่า 1 กิโลเมตร, แสดงผลเป็นกิโลเมตร
      return distance.toStringAsFixed(2) + " กิโลเมตร";
    } else {
      // ระยะทางน้อยกว่าหรือเท่ากับ 1 กิโลเมตร, แสดงผลเป็นเมตร
      return (distance * 1000).toStringAsFixed(2) + " เมตร";
    }
  }

  double _toRadians(double degree) {
    return degree * (pi / 180.0);
  }

  Future<void> _displayDraggableScrollableSheet(BuildContext context) async {
    dataSearch = [];
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
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      width: 100,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Text(
                      'ค้นหาสถานที่',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC70039),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              onChanged: (value) {
                                searchData(value);
                              },
                              decoration: InputDecoration(
                                hintText: 'ค้นหา',
                                suffixIcon: Icon(Icons.search),
                                labelText: 'ค้นหา',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //สถานที่แนะนำ
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      width: double.infinity,
                      child: Text(
                        'สถานที่แนะนำ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    //menu แนะนำ
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 255, 179, 186), // Pastel Red
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                minimumSize: Size(20, 20),
                              ),
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await Suggest_location("restaurant", setState);
                                Future.delayed(Duration(seconds: 4), () {
                                  if (dataSearch.length == 0) {
                                    _showmsgQuickAlert("แจ้งเตือน",
                                        "ไม่พบข้อมูล", QuickAlertType.error);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                });
                              },
                              child: Icon(
                                Icons.restaurant,
                                color: Colors.red[700],
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 179, 205, 255), // Pastel Blue
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                minimumSize: Size(20, 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                Suggest_location("hotel", setState);
                                Future.delayed(Duration(seconds: 4), () {
                                  if (dataSearch.length == 0) {
                                    _showmsgQuickAlert("แจ้งเตือน",
                                        "ไม่พบข้อมูล", QuickAlertType.error);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                });
                              },
                              child: Icon(
                                Icons.hotel,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 255, 223, 186), // Pastel Orange
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                minimumSize: Size(20, 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                Suggest_location("attraction", setState);
                                Future.delayed(Duration(seconds: 4), () {
                                  if (dataSearch.length == 0) {
                                    _showmsgQuickAlert("แจ้งเตือน",
                                        "ไม่พบข้อมูล", QuickAlertType.error);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                });
                              },
                              child: Icon(
                                Icons.attractions,
                                color: Colors.orange[700],
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 186, 255, 186), // Pastel Green
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                minimumSize: Size(20, 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                Suggest_location("shopping", setState);
                                Future.delayed(Duration(seconds: 4), () {
                                  if (dataSearch.length == 0) {
                                    _showmsgQuickAlert("แจ้งเตือน",
                                        "ไม่พบข้อมูล", QuickAlertType.error);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                });
                              },
                              child: Icon(
                                Icons.shopping_bag,
                                color: Colors.green[700],
                              ),
                            ),
                            SizedBox(width: 10),
                            //สถานีชาร์จรถไฟฟ้า
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 255, 186, 255), // Pastel Purple
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                minimumSize: Size(20, 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                Suggest_location("สถานีชาร์จรถไฟฟ้า", setState);
                                Future.delayed(Duration(seconds: 4), () {
                                  if (dataSearch.length == 0) {
                                    _showmsgQuickAlert("แจ้งเตือน",
                                        "ไม่พบข้อมูล", QuickAlertType.error);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                });
                              },
                              child: Icon(
                                Icons.electric_car,
                                color: Colors.purple[700],
                              ),
                            ),
                            SizedBox(width: 10),
                            //ปั๊มน้ำมัน
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 255, 148, 255), // Pastel Purple
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                minimumSize: Size(20, 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                Suggest_location("ปั๊มน้ำมัน", setState);
                                Future.delayed(Duration(seconds: 4), () {
                                  if (dataSearch.length == 0) {
                                    _showmsgQuickAlert("แจ้งเตือน",
                                        "ไม่พบข้อมูล", QuickAlertType.error);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                });
                              },
                              child: Icon(
                                Icons.local_gas_station,
                                color: Colors.pink[700],
                              ),
                            ),
                            SizedBox(width: 10),
                            // สถานบันเทิง
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 255, 186, 186), // Pastel Pink
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                minimumSize: Size(20, 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                Suggest_location("สถานบันเทิง", setState);
                                Future.delayed(Duration(seconds: 4), () {
                                  if (dataSearch.length == 0) {
                                    _showmsgQuickAlert("แจ้งเตือน",
                                        "ไม่พบข้อมูล", QuickAlertType.error);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                });
                              },
                              child: Icon(
                                Icons.local_bar,
                                color: Colors.pink[700],
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 186, 186, 255), // Pastel Purple
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                minimumSize: Size(20, 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                Suggest_location("hospital", setState);
                                Future.delayed(Duration(seconds: 4), () {
                                  if (dataSearch.length == 0) {
                                    _showmsgQuickAlert("แจ้งเตือน",
                                        "ไม่พบข้อมูล", QuickAlertType.error);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                });
                              },
                              child: Icon(
                                Icons.local_hospital,
                                color: Colors.purple[700],
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 255, 186, 186), // Pastel Pink
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                minimumSize: Size(20, 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                Suggest_location("school", setState);
                                Future.delayed(Duration(seconds: 4), () {
                                  if (dataSearch.length == 0) {
                                    _showmsgQuickAlert("แจ้งเตือน",
                                        "ไม่พบข้อมูล", QuickAlertType.error);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                });
                              },
                              child: Icon(
                                Icons.school,
                                color: Colors.pink[700],
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 186, 255, 255), // Pastel Cyan
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                minimumSize: Size(20, 20),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                });
                                Suggest_location("bank", setState);
                                Future.delayed(Duration(seconds: 4), () {
                                  if (dataSearch.length == 0) {
                                    _showmsgQuickAlert("แจ้งเตือน",
                                        "ไม่พบข้อมูล", QuickAlertType.error);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                });
                              },
                              child: Icon(
                                Icons.account_balance,
                                color: Colors.cyan[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFC70039)),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: dataSearch.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom: 10, left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 7,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    title: Text(
                                      '${dataSearch[index]['name']}',
                                      style: TextStyle(
                                        color: Color(0xFF141E46),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${dataSearch[index]['address']}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        FutureBuilder<String>(
                                          future: calculateDistance(
                                              dataSearch[index]['lat'],
                                              dataSearch[index]['lon']),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<String> snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              // กำลังโหลดข้อมูล, แสดง progress indicator หรือข้อความว่ากำลังโหลด
                                              return Text("กำลังคำนวณ...",
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14));
                                            } else if (snapshot.hasError) {
                                              // ถ้ามีข้อผิดพลาดในการคำนวณ, แสดงข้อความข้อผิดพลาด
                                              return Text(
                                                  "Error: ${snapshot.error}",
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 14));
                                            } else {
                                              // ข้อมูลพร้อม, แสดงระยะห่าง
                                              return Text(
                                                  'ระยะห่าง ${snapshot.data}',
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14));
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: Color(0xFFC70039),
                                      child: IconButton(
                                        icon: Icon(Icons.location_on,
                                            color: Colors.white),
                                        onPressed: () {
                                          map.currentState
                                              ?.call("location", args: [
                                            {
                                              "lon": dataSearch[index]['lon'],
                                              "lat": dataSearch[index]['lat'],
                                            }
                                          ]);
                                        },
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.add,
                                          color: Color(0xFFC70039)),
                                      onPressed: () {
                                        fetchData(dataSearch[index]['lon'],
                                            dataSearch[index]['lat']);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    )
                  ],
                ),
              );
            });
          },
        );
      },
    );
    // load_maplist();
  }

  Future<void> getTripData() async {
    TripModel trip = Provider.of<TripModel>(context, listen: false);
    // print(trip.trip[0]['locations'][widget.idx]);
    print("getTripData ${trip.trip[0]['locations'][widget.idx]}");
    trip.trip[0]['locations'][widget.idx].forEach((element) {
      add_mark(element['lat'], element['lon']);
      dataMark.add(element);
      // print("element ${element}");
    });
  }

  void confirmAddmark(Function(bool) onResult) {
    _controller.clear();
    _controller2.clear();
    _controller3.clear();
    _controller4.clear();
    _money.clear();
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
      onConfirmBtnTap: () {
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
          TripModel trip = Provider.of<TripModel>(context, listen: false);
          setState(() {
            trip.trip[0]['activities_time'][widget.idx].add({
              "time": time,
              "money": money,
              "success": false,
            });
          });
          onResult(true);
          Navigator.of(context).pop();
        }
      },
    );
  }

  void confirmeditMark(int idx, Function(bool) onResult) {
    _controller.clear();
    _controller2.clear();
    _controller3.clear();
    _controller4.clear();
    _money.clear();
    String time = "";
    String money = "";
    TripModel trip = Provider.of<TripModel>(context, listen: false);
    print(trip.trip[0]['activities_time'][widget.idx][idx]['time']);
    time = trip.trip[0]['activities_time'][widget.idx][idx]['time']
        .replaceAll(new RegExp(r'[^0-9]'), ''); // ลบทุกอย่างที่ไม่ใช่ตัวเลข
    money = trip.trip[0]['activities_time'][widget.idx][idx]['money'];
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
      onConfirmBtnTap: () {
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
          TripModel trip = Provider.of<TripModel>(context, listen: false);
          setState(() {
            trip.trip[0]['activities_time'][widget.idx][idx] = {
              "time": time,
              "money": money,
              "success": false,
            };
          });
          onResult(true);
          Navigator.of(context).pop();
        }
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
    );
  }

  Future<void> fetchData(lon, lat) async {
    print("lat: ${lat} lon: ${lon}");
    var apiKey = "804903bb8f1b3b154a6f11b156adaf62";
    final url = Uri.parse(
        'https://api.longdo.com/POIService/json/search?key=${apiKey}&lon=${lon}&lat=${lat}&limit=20&span=40km');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      var lotlat = jsonData['data'].map((e) => {
            "lat": e['lat'].toStringAsFixed(4),
            "lon": e['lon'].toStringAsFixed(4),
          });
      var lotlats = jsonData['data'].map((e) => {
            "lat": e['lat'].toStringAsFixed(4),
            "lon": e['lon'].toStringAsFixed(5),
          });
      print(lat.toStringAsFixed(4) + ' ' + lon.toStringAsFixed(4));
      print(lat.toStringAsFixed(4) + ' ' + lon.toStringAsFixed(6));
      print(lotlat);
      print(lotlats);
      dynamic datax = [];
      jsonData['data'].forEach((element) {
        if (element['lat'].toStringAsFixed(4) == lat.toStringAsFixed(4) &&
            element['lon'].toStringAsFixed(4) == lon.toStringAsFixed(4)) {
          datax.add(element);
        }
      });
      // print( is List ? true : false);
      print(datax.length);
      if (datax.length > 0) {
        if (dataMark.length == 0) {
          confirmAddmark((result) {
            if (result) {
              dataMark.add(datax[0]);
              mapModel maplist = Provider.of<mapModel>(context, listen: false);
              maplist.add_map(datax[0]);
              TripModel trip = Provider.of<TripModel>(context, listen: false);
              setState(() {
                trip.trip[0]['locations'][widget.idx].add(datax[0]);
                trip.print_trip();
                widget.callback();
              });
              context.read<mapModel>().get_map.forEach((element) {
                print("maplist ${element['name']}");
              });

              setState(() {
                messenger.currentState?.showSnackBar(
                  SnackBar(
                    content: Text(datax[0]['name'] + " ถูกเพิ่มแล้ว"),
                  ),
                );
                dataMark = dataMark;
              });
              add_mark(datax[0]['lat'], datax[0]['lon']);
            }
          });
        } else {
          // print("more data maker");
          print("more data maker");
          var check =
              dataMark.where((element) => element['name'] == datax[0]['name']);
          print(check.length);
          if (check.length == 0) {
            confirmAddmark((result) {
              if (result) {
                setState(() {
                  messenger.currentState?.showSnackBar(
                    SnackBar(
                      content: Text(datax[0]['name'] + " ถูกเพิ่มแล้ว"),
                    ),
                  );
                  dataMark.add(datax[0]);
                  mapModel maplist =
                      Provider.of<mapModel>(context, listen: false);
                  TripModel trip =
                      Provider.of<TripModel>(context, listen: false);
                  setState(() {
                    trip.trip[0]['locations'][widget.idx].add(datax[0]);
                    trip.print_trip();
                    widget.callback();
                    print(trip.trip[0]['locations'][widget.idx][0]['id']);
                  });
                  maplist.add_map(datax[0]);
                  context.read<mapModel>().get_map.forEach((element) {
                    print("maplist ${element['name']}");
                  });
                });
                // set_location(datax[0]['lat'], datax[0]['lon']);
                add_mark(datax[0]['lat'], datax[0]['lon']);
              }
            });
          } else {
            print("มีข้อมูลแล้ว");
            _showmsgQuickAlert(
                "แจ้งเตือน", "มีข้อมูลนี้อยู่แล้ว", QuickAlertType.error);
          }
        }
      } else {
        setState(() {
          messenger.currentState?.showSnackBar(
            SnackBar(
              content: Text("ไม่พบข้อมูล"),
            ),
          );
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  void add_mark(lat, lon) {
    print("add_mark ${lat} ${lon}");
    mark = map.currentState?.LongdoObject(
      "Marker",
      args: [
        {
          "lon": lon,
          "lat": lat,
        },
      ],
    );
    if (mark != null) {
      map.currentState?.call("Overlays.add", args: [mark!]);
    }
  }

  void remove_mark(index) async {
    print("remove ${index}");
    var x = await map.currentState?.call("Overlays.list");
    var xd = jsonDecode(x.toString());
    print(xd[index]);
    map.currentState?.call("Overlays.remove", args: [xd[index]]);
    mapModel maplist = Provider.of<mapModel>(context, listen: false);
    maplist.remove_map(dataMark[index]);
    print("maplist XD ${context.read<mapModel>().get_map}");
    setState(() {
      dataMark.removeAt(index);
    });
  }

  String formatDateTime(String time) {
    // time = "00:30";
    var hour = time.substring(0, 2);
    var minute = time.substring(3, time.length);
    // hour.replaceAll("0", "2");
    if (hour == "00") {
      hour = "";
      return "${minute} นาที";
    } else if (hour[0] == "0") {
      hour = hour[1];
      return "${hour} ชั่วโมง ${minute} นาที";
    } else {
      return "${hour} ชั่วโมง ${minute} นาที";
    }
  }

  Future<void> Suggest_location(String tag, StateSetter setState) async {
    var apiKey = "804903bb8f1b3b154a6f11b156adaf62";
    var my_location = await _determinePosition();
    var lat = my_location.latitude;
    var lon = my_location.longitude;
    var span = "50km";
    final url = Uri.parse(
        'https://api.longdo.com/POIService/json/search?key=${apiKey}&lon=${lon}&lat=${lat}&limit=20&tag=${tag}&span=${span}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      // ใช้ setState จาก StatefulBuilder เพื่ออัพเดท UI
      print(jsonData['data']);
      setState(() {
        dataSearch = jsonData['data'];
      });
    }
  }

  Widget _buildCustomDialog() {
    TripModel trip = Provider.of<TripModel>(context, listen: false);
    List<dynamic> data = trip.trip[0]['locations'][widget.idx];
    // print("data ${data}");
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
          children: [
            Text(
              'รายการสถานที่ที่ต้องการไป',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC70039),
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: data.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = data.removeAt(oldIndex);
                    final item_activities_time = trip.trip[0]['activities_time']
                            [widget.idx]
                        .removeAt(oldIndex);
                    data.insert(newIndex, item);
                    trip.trip[0]['activities_time'][widget.idx]
                        .insert(newIndex, item_activities_time);
                    // trip.print_trip();
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    key: Key('$index'),
                    margin: EdgeInsets.only(
                      bottom: bottom_list,
                      // left: 40,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(5),
                      subtitle: Text(
                        'เวลาที่ต้องการอยู่ ${formatDateTime(trip.trip[0]['activities_time'][widget.idx][index]['time'])} \n ค่าใช้จ่าย ${trip.trip[0]['activities_time'][widget.idx][index]['money']} บาท',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                      leading: Listener(
                        onPointerMove: (event) {
                          print("onPointerMove");
                          setState(() {
                            bottom_list = 0;
                          });
                        },
                        onPointerUp: (event) {
                          print("onPointerUp");
                          setState(() {
                            bottom_list = 15;
                          });
                        },
                        child: ReorderableDragStartListener(
                          index: index,
                          child: CircleAvatar(
                            backgroundColor: Color(0xFFC70039),
                            child: IconButton(
                              icon:
                                  Icon(Icons.location_on, color: Colors.white),
                              onPressed: () {
                                map.currentState?.call("location", args: [
                                  {
                                    "lon": data[index]['lon'],
                                    "lat": data[index]['lat'],
                                  }
                                ]);
                              },
                            ),
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              confirmeditMark(index, (result) {
                                if (result) {
                                  print(result);
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              remove_mark(index);
                              trip.trip[0]['locations'][widget.idx]
                                  .removeAt(index);
                              trip.print_trip();
                              widget.callback();
                              setState(() {
                                trip.trip[0]['activities_time'][widget.idx]
                                    .removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                      title: Text(
                        '${data[index]['name']}',
                        style: TextStyle(
                          color: Color(0xFF141E46),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              // height: 50,
              alignment: Alignment.topRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC70039),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsets.all(10),
                  minimumSize: Size(20, 20),
                ),
                onPressed: _toggleDialog,
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, value, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 2,
                  child: LongdoMapWidget(
                    apiKey: "804903bb8f1b3b154a6f11b156adaf62",
                    key: map,
                    eventName: [
                      JavascriptChannel(
                        name: "ready",
                        onMessageReceived: (JavascriptMessage message) async {
                          print("ready click");
                          getTripData();
                          var lay = map.currentState
                              ?.LongdoStatic("Layers", 'RASTER_POI');
                          if (lay != null) {
                            print("ready");
                            map.currentState
                                ?.call('Layers.setBase', args: [lay]);
                          }
                          var latlon = _determinePosition();
                          var dlat =
                              await latlon.then((value) => value.latitude);
                          var dlon =
                              await latlon.then((value) => value.longitude);
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
                          fetchData(lon, lat);
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
              ],
            ),
            //btn top floatingbutton
            Positioned(
              bottom: 80,
              right: 19,
              child: FloatingActionButton(
                backgroundColor: Colors.amber[700],
                onPressed: () {
                  var latlon = _determinePosition();
                  var dlat = latlon.then((value) => value.latitude);
                  var dlon = latlon.then((value) => value.longitude);
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
                child: Icon(Icons.gps_fixed, color: Colors.white),
                tooltip: "ตำแหน่งปัจจุบัน",
              ),
            ),
            //btn show list
            Positioned(
              bottom: 143,
              right: 19,
              child: FloatingActionButton(
                backgroundColor: Colors.green[700],
                onPressed: () {
                  _toggleDialog();
                },
                child: Icon(Icons.list, color: Colors.white),
                tooltip: "รายการสถานที่",
              ),
            ),
            //btn search
            Positioned(
              bottom: 15,
              right: 19,
              child: FloatingActionButton(
                backgroundColor: Color(0xFFC70039),
                onPressed: () => _displayDraggableScrollableSheet(context),
                child: Icon(Icons.search, color: Colors.white),
                tooltip: "ค้นหาสถานที่",
              ),
            ),
            // Black Overlay
            if (_isDialogVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleDialog, // Optional: close dialog on tap outside
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

  EntryLinePainter(this.index, this.length);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    // Existing line drawing code remains unchanged
    if (index != 0) {
      // canvas.drawLine(Offset(-38, size.height / 2), Offset(-38, -38), paint);
      drawDottedLine(canvas, Offset(-78, size.height / 2), Offset(-78, -58),
          paint); // Draw a dotted line
    }
    if (index != length - 1) {
      final paintx = Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2;
      drawDottedLine(
          canvas, Offset(-78, size.height / 2), Offset(-78, 90), paint);
      // canvas.drawLine(Offset(-38, size.height / 2), Offset(-38, 60.0), paint);
    }
    drawDottedLine(canvas, Offset(-60, size.height / 2),
        Offset(-30, size.height / 2), paint);
    // canvas.drawLine(
    //     Offset(20, size.height / 2), Offset(40, size.height / 2), paint);

    // White background circle
    final paintCircleWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-78, size.height / 2), 15, paintCircleWhite);

    // Red border circle
    final paintCircleRed = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; // Adjust the border thickness here
    canvas.drawCircle(Offset(-78, size.height / 2), 15, paintCircleRed);
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
