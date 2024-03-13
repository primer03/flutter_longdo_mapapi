import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

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
        // print('Selected time: ${_times}');
        // for (int i = 0; i < _isSelected.length; i++) {
        //   if (_isSelected[i] == true) {
        //     print('Selected time: ${_times[i]}');
        //   }
        // }
        print('Selected time: ${_times[index]}');
      });
      print('Selected time: ${_times}');
    }
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
                  SizedBox(height: 20),
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
                  SizedBox(height: 20),
                  Text(
                    'เพิ่มสถานที่ที่จะไปในวันที่เดินทางนี้',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF141E46),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Only show the image if there's no bottom padding (keyboard is not shown)
          // if (bottomPadding == 0)
          //   Positioned(
          //     bottom: 0,
          //     right: 0,
          //     child: Image.asset(
          //       'assets/images/trip_logo.png',
          //       width: 200,
          //       height: 200,
          //     ),
          //   ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
          },
          child: Icon(Icons.add),
          backgroundColor: Color(0xFFFC70039),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          )),
    );
  }
}
