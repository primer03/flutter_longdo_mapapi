import 'dart:ffi';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:getgeo/model/TripModel.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:getgeo/page/list_location.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  List<DateTime?> _dates = [];
  List<TimeOfDay> _times = [];
  List<bool> _isSelected = [];
  int _animatedIndex = -1;
  var db = FirebaseFirestore.instance;
  TextEditingController _nameController = TextEditingController();
  bool _Ispublice = false;
  List<Map<String, dynamic>> _userData = [];
  List<Map<String, dynamic>> _trip_friend = [];
  String _selectedTripType = 'การเดินทางท่องเที่ยว';
  List<String> _trip_type = [
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

  Future _selectTime(int index) async {
    DateTime daytime = _dates[index]!;
    print('Selected time: ${index + 1}');
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText:
          'เลือกเวลาของวันที่ ${daytime.day}/${daytime.month}/${daytime.year}',
      cancelText: 'ยกเลิก',
      confirmText: 'ตกลง',
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFFFC70039),

            colorScheme: ColorScheme.light(
              primary: Color(0xFFFC70039),
              onSurface: Color(0xFFFC70039),
              onPrimary: Color(0xFFFC70039),
            ),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFFC70039),
                foregroundColor: Colors.white,
              ),
            ),
            // other time picker theme properties
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              dayPeriodColor: Color(0xFFFC70039),
              dayPeriodTextColor: Color(0xFF141E46),
              // dialBackgroundColor: Colors.white,
              // hourMinuteColor: Color(0xFFFC70039),
              // hourMinuteTextColor: Color(0xFF141E46),
              helpTextStyle: TextStyle(
                color: Color(0xFFFC70039),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(
                  color: Color(0xFFFC70039),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _times[index] = time;
        _isSelected[index] = true;
        print('Selected time: ${_times[index]}');
      });
      print('Selected time: ${_times}');
    }
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

  Future<void> getUser() async {
    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    var data = await db
        .collection('user_setting')
        .where('user_email', isNotEqualTo: userModel.email)
        .get();
    data.docs.forEach((result) {
      print(result.data());
      _userData.add(result.data());
    });
    setState(() {
      _userData = _userData;
    });
  }

  List<Map<String, dynamic>> _searchUser(String query) {
    List<Map<String, dynamic>> matches = [];
    _userData.forEach((user) {
      if (user['user_name'].toLowerCase().contains(query.toLowerCase())) {
        matches.add({
          'user_name': user['user_name'],
          'user_img': user['user_img'],
          'user_email': user['user_email'],
        });
      }
    });
    print(matches);
    return matches;
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the padding at the bottom to account for the keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    DateTime? selectedDate;
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มทริป'),
        backgroundColor: Color(0xFFFC70039), // Corrected color value
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: bottomPadding), // Apply padding at the bottom
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    cursorColor: Color(0xFF141E46),
                    decoration: InputDecoration(
                      floatingLabelStyle: TextStyle(
                        color: Color(0xFF141E46),
                        fontSize: 20,
                      ),
                      labelText: 'ชื่อทริป',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF141E46),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF141E46),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF141E46),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    child: Text(
                      'ประเภททริป',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF141E46),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF141E46),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedTripType,
                            items: _trip_type.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            underline: Container(
                              height: 0,
                              color: Colors.transparent,
                            ),
                            onChanged: (String? value) {
                              setState(() {
                                _selectedTripType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  SwitchListTile(
                    title: Text(
                      'ทริปสาธารณะ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF141E46),
                      ),
                    ),
                    value: _Ispublice,
                    activeColor: Color(0xFFFC70039),
                    onChanged: (bool value) {
                      setState(() {
                        _Ispublice = value;
                        print(_Ispublice);
                      });
                    },
                  ),

                  Container(
                    width: double.infinity,
                    child: Text(
                      'เลือกเพื่อนที่จะเข้าร่วมทริป',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF141E46),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: InputDecoration(
                        label: Text('ค้นหาเพื่อน'),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF141E46),
                          fontSize: 20,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF141E46),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF141E46),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF141E46),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return _searchUser(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFFFC70039),
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(suggestion['user_img']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(suggestion['user_name']),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      print(suggestion);
                      // setState(() {
                      //   _trip_friend.add(suggestion);
                      // });
                      //check unique
                      if (_trip_friend.length != 0) {
                        for (int i = 0; i < _trip_friend.length; i++) {
                          if (_trip_friend[i]['user_email'] ==
                              suggestion['user_email']) {
                            _showmsgQuickAlert(
                                'เพื่อนนี้ได้ถูกเพิ่มแล้ว',
                                'เพื่อนนี้ได้ถูกเพิ่มแล้ว',
                                QuickAlertType.error);
                            return;
                          }
                        }
                      }
                      setState(() {
                        _trip_friend.add(suggestion);
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  _trip_friend.length != 0
                      ? Container(
                          width: double.infinity,
                          child: Text(
                            'เพื่อนที่เข้าร่วมทริป',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF141E46),
                            ),
                          ),
                        )
                      : Container(),
                  _trip_friend.length != 0 ? SizedBox(height: 10) : Container(),
                  _trip_friend.length != 0
                      ? Container(
                          width: double.infinity,
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _trip_friend.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 7,
                                                offset: Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Color(0xFFFC70039),
                                              width: 4,
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                _trip_friend[index]['user_img'],
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          _trip_friend[index]['user_name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF141E46),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      bottom: 37,
                                      right: 1.9,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _trip_friend.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            color: Color(0xFFFC70039),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(100),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : Container(),
                  // SizedBox(height: 10),
                  Text(
                    'วันที่เดินทาง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF141E46),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF141E46),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CalendarDatePicker2(
                      config: CalendarDatePicker2Config(
                        calendarType: CalendarDatePicker2Type.multi,
                        selectedDayHighlightColor: Color(0xFFFC70039),
                        selectedDayTextStyle: TextStyle(color: Colors.white),
                        todayTextStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        dayTextStyle: TextStyle(color: Colors.black),
                        controlsHeight: 40,
                      ),
                      value: _dates,
                      onValueChanged: (dates) {
                        print(dates);
                        //ห้ามมีวันที่น้อยกว่าวันปัจจุบันแต่เลือกวันปัจจุบันได้
                        for (int i = 0; i < dates.length; i++) {
                          DateTime currentDate = DateTime.now();
                          DateTime currentDateWithoutTime = DateTime(
                              currentDate.year,
                              currentDate.month,
                              currentDate.day);

                          DateTime dateWithoutTime = DateTime(
                              dates[i]!.year, dates[i]!.month, dates[i]!.day);

                          if (dateWithoutTime
                              .isBefore(currentDateWithoutTime)) {
                            print('ไม่สามารถเลือกวันที่ย้อนหลังได้');
                            _showmsgQuickAlert(
                                'ไม่สามารถเลือกวันที่ย้อนหลังได้',
                                'ไม่สามารถเลือกวันที่ย้อนหลังได้',
                                QuickAlertType.error);
                            dates.removeAt(i);
                            return;
                          }
                        }
                        setState(() {
                          var backupDatez = _dates;
                          _dates = dates;
                          _times = List.generate(_dates.length, (index) {
                            if (backupDatez.contains(_dates[index])) {
                              int idx = backupDatez.indexOf(_dates[index]);
                              return _times[idx];
                            } else {
                              return TimeOfDay.now();
                            }
                          });
                          _isSelected = List.generate(_dates.length, (index) {
                            if (backupDatez.contains(_dates[index])) {
                              int idx = backupDatez.indexOf(_dates[index]);
                              return _isSelected[idx];
                            } else {
                              return false;
                            }
                          });
                        });
                        print('times: $_times');
                        print('isSelected: $_isSelected');
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'เลือกเวลาเริ่มต้นการเดินทาง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF141E46),
                    ),
                  ),
                  SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: _dates.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _selectTime(index);
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: _isSelected[index]
                                        ? Colors.green[600]!
                                        : Color(0xFF141E46),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  splashFactory: InkRipple.splashFactory,
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    _selectTime(index);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(
                                        8), // Optional, in case you need padding
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.date_range_outlined,
                                          color: Color(0xFF141E46),
                                          size: 30,
                                        ),
                                        Text(
                                          '${_dates[index]?.day}', // Corrected value
                                          style: TextStyle(
                                            color: Color(0xFF141E46),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                          ),
                                        ),
                                        // Display selected time with am/pm
                                        _isSelected[index]
                                            ? Text(
                                                _times[index].format(context),
                                                style: TextStyle(
                                                  color: Colors.green[600]!,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              )
                                            : Text('เลือกเวลา'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            //display time
                            Positioned(
                              top: 1,
                              right: 1.9,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _times.removeAt(index);
                                    _dates.removeAt(index);
                                    _isSelected.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFC70039),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_nameController.text.isEmpty) {
            _showmsgQuickAlert(
                'กรุณากรอกชื่อทริป', 'กรุณากรอกชื่อทริป', QuickAlertType.error);
            return;
          }
          if (_dates.isEmpty) {
            _showmsgQuickAlert('กรุณาเลือกวันที่เดินทาง',
                'กรุณาเลือกวันที่เดินทาง', QuickAlertType.error);
            return;
          }
          if (_times.isEmpty) {
            _showmsgQuickAlert('กรุณาเลือกเวลาเริ่มต้นการเดินทาง',
                'กรุณาเลือกเวลาเริ่มต้นการเดินทาง', QuickAlertType.error);
            return;
          }
          if (_isSelected.contains(false)) {
            _showmsgQuickAlert('กรุณาเลือกเวลาเริ่มต้นการเดินทาง',
                'กรุณาเลือกเวลาเริ่มต้นการเดินทาง', QuickAlertType.error);
            return;
          }
          print(_times);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('trip_name', _nameController.text);
          prefs.setStringList('trip_dates',
              _dates.map((date) => date!.toIso8601String()).toList());
          prefs.setStringList('trip_times',
              _times.map((time) => time.format(context)).toList());
          prefs.setString('trip_type', _selectedTripType);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return LocationList();
          }));
          TripModel tripModel = Provider.of<TripModel>(context, listen: false);
          tripModel.clear_trip();
          List<String> trip_friend_email = [];
          if (_trip_friend.length != 0) {
            for (int i = 0; i < _trip_friend.length; i++) {
              trip_friend_email.add(_trip_friend[i]['user_email']);
            }
          }
          tripModel.add_trip({
            'is_public': _Ispublice,
            'name': _nameController.text,
            'dates': _dates,
            'times': _times,
            'locations':
                List.generate(_dates.length, (index) => [] as List<dynamic>),
            'activities_time':
                List.generate(_dates.length, (index) => [] as List<dynamic>),
            'friend_email': trip_friend_email,
            'trip_type': _selectedTripType,
          });
        },
        //next page
        child: Icon(Icons.arrow_forward),
        backgroundColor: Color(0xFFFC70039),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
