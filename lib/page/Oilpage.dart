import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:getgeo/model/CarService.dart';
import 'package:getgeo/model/oilService.dart';

class Oilpage extends StatefulWidget {
  const Oilpage({super.key});

  @override
  State<Oilpage> createState() => _OilpageState();
}

class _OilpageState extends State<Oilpage> {
  int _day = DateTime.now().day;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  List<String> District = [];
  List<Map<String, dynamic>> oillogo = [
    {
      'name': 'ดีเซล',
      'img': 'assets/images/oil/oil2.jpg',
    },
    {
      'name': 'ดีเซล B7',
      'img': 'assets/images/oil/oil1.jpg',
    },
    {
      'name': 'เบนซินแก๊สโซฮอล์ E85',
      'img': 'assets/images/oil/oil7.jpg',
    },
    {
      'name': 'เบนซินแก๊สโซฮอล์ E20',
      'img': 'assets/images/oil/oil6.jpg',
    },
    {
      'name': 'เบนซินแก๊สโซฮอล์ 91',
      'img': 'assets/images/oil/oil5.jpg',
    },
    {
      'name': 'เบนซินแก๊สโซฮอล์ 95',
      'img': 'assets/images/oil/oil4.jpg',
    },
    {
      'name': 'เบนซิน',
      'img': 'assets/images/oil/oil3.jpg',
    },
    {
      'name': 'Super Power Diesel',
      'img': 'assets/images/oil/oil9.jpg',
    },
    {
      'name': 'Super Power GSH95',
      'img': 'assets/images/oil/oil8.jpg',
    },
  ];
  List<String> provinces = [
    'กระบี่',
    'กรุงเทพมหานคร',
    'กาญจนบุรี',
    'กาฬสินธุ์',
    'กำแพงเพชร',
    'ขอนแก่น',
    'จันทบุรี',
    'ฉะเชิงเทรา',
    'ชลบุรี',
    'ชัยนาท',
    'ชัยภูมิ',
    'ชุมพร',
    'เชียงราย',
    'เชียงใหม่',
    'ตรัง',
    'ตราด',
    'ตาก',
    'นครนายก',
    'นครปฐม',
    'นครพนม',
    'นครราชสีมา',
    'นครศรีธรรมราช',
    'นครสวรรค์',
    'นนทบุรี',
    'นราธิวาส',
    'น่าน',
    'บึงกาฬ',
    'บุรีรัมย์',
    'ปทุมธานี',
    'ประจวบคีรีขันธ์',
    'ปราจีนบุรี',
    'ปัตตานี',
    'พระนครศรีอยุธยา',
    'พะเยา',
    'พังงา',
    'พัทลุง',
    'พิจิตร',
    'พิษณุโลก',
    'เพชรบุรี',
    'เพชรบูรณ์',
    'แพร่',
    'ภูเก็ต',
    'มหาสารคาม',
    'มุกดาหาร',
    'แม่ฮ่องสอน',
    'ยะลา',
    'ยโสธร',
    'ระนอง',
    'ระยอง',
    'ราชบุรี',
    'ร้อยเอ็ด',
    'ลพบุรี',
    'ลำปาง',
    'ลำพูน',
    'เลย',
    'ศรีสะเกษ',
    'สกลนคร',
    'สงขลา',
    'สตูล',
    'สมุทรปราการ',
    'สมุทรสงคราม',
    'สมุทรสาคร',
    'สระบุรี',
    'สระแก้ว',
    'สิงห์บุรี',
    'สุโขทัย',
    'สุพรรณบุรี',
    'สุราษฎร์ธานี',
    'สุรินทร์',
    'หนองคาย',
    'หนองบัวลำภู',
    'อยุธยา',
    'อรัญประเทศ',
    'อำนาจเจริญ',
    'อุดรธานี',
    'อุตรดิตถ์',
    'อุทัยธานี',
    'อุบลราชธานี',
    'อ่างทอง',
  ];
  List<String> provincesEN = [
    "Krabi",
    "Bangkok",
    "Kanchanaburi",
    "Kalasin",
    "Kamphaeng Phet",
    "Khon Kaen",
    "Chanthaburi",
    "Chachoengsao",
    "Chon Buri",
    "Chainat",
    "Chaiyaphum",
    "Chumphon",
    "Chiang Rai",
    "Chiang Mai",
    "Trang",
    "Trat",
    "Tak",
    "Nakhon Nayok",
    "Nakhon Pathom",
    "Nakhon Phanom",
    "Nakhon Ratchasima",
    "Nakhon Si Thammarat",
    "Nakhon Sawan",
    "Nonthaburi",
    "Narathiwat",
    "Nan",
    "Bueng Kan",
    "Buri Ram",
    "Pathum Thani",
    "Prachuap Khiri Khan",
    "Prachin buri",
    "Pattani",
    "Phra Nakhon Si Ayutthaya",
    "Phayao",
    "Phangnga",
    "Phatthalung",
    "Phichit",
    "Phitsanulok",
    "Phetcha buri",
    "Phetchabun",
    "Phrae",
    "Phuket",
    "Maha Sarakham",
    "Mukdahan",
    "Mae Hong Son",
    "Yala",
    "Yasothon",
    "Ranong",
    "Rayong",
    "Ratcha buri",
    "Roi Et",
    "Lopburi",
    "Lampang",
    "Lamphun",
    "Loei",
    "Si Sa Ket",
    "Sakon Nakhon",
    "Songkhla",
    "Satun",
    "Samut Prakan",
    "Samut Songkhram",
    "Samut Sakhon",
    "Saraburi",
    "Sa Kaeo",
    "Sing Buri",
    "Sukhothai",
    "Suphanburi",
    "Surat Thani",
    "Surin",
    "Nong Khai",
    "Nong Bua Lamphu",
    "Ayutthaya",
    "Aranyaprathet",
    "Amnat Charoen",
    "Udon Thani",
    "Uttaradit",
    "Uthai Thani",
    "Ubon Ratchathani",
    "Ang Thong"
  ];
  List<Map<String, dynamic>> dataOil = [];
  List<Map<String, dynamic>> dataOilDistrict = [];
  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController _typeAheadControllerDistrict =
      TextEditingController();
  bool checkBangkok = false;
  bool _isLoading = false;

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  Future<void> getOil() async {
    _toggleLoading();
    var now = DateTime.now();
    var date = now.day.toString();
    var month = now.month.toString();
    var year = now.year.toString();
    var oil = await OilService().getSuggestions();
    oillogo.forEach((element) {
      oil.forEach((element2) {
        if (element['name'] == element2['Product']) {
          element2['img'] = element['img'];
        }
      });
    });
    //
    oil.forEach((element) {
      print(element['Product']);
      print(element['Price']);
      print(element['img']);
    });
    print(oillogo.length);
    // print(oillogo);
    setState(() {
      dataOilDistrict = oil as List<Map<String, dynamic>>;
      checkBangkok = true;
      _toggleLoading();
    });
  }

  Widget _buildLoadingScreen() {
    return AbsorbPointer(
      absorbing: true,
      child: Stack(
        children: <Widget>[
          ModalBarrier(dismissible: false, color: Colors.black45),
          Center(
            child: SizedBox(
              width: 50, // กำหนดความกว้าง
              height: 50, // กำหนดความสูง
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade900),
                strokeWidth: 10, // เพิ่มความหนาของวงกลม
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getOil(); //3456728
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Color(0xFFFC70039),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRect(
                        child: Image.asset(
                          'assets/images/cosplayoil.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ราคาน้ำมันวันนี้',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$_day/$_month/$_year',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFC70039),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(60),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: 20,
                            ),
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/images/pttstation-logo.png',
                              width: 200,
                              height: 50,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TypeAheadField(
                                      noItemsFoundBuilder: (context) =>
                                          Container(
                                        height: 20,
                                        child: Center(
                                          child: Text(
                                            'No Data Found',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Impact',
                                              color: Color(0xFF141E46),
                                            ),
                                          ),
                                        ),
                                      ),
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
                                        controller: _typeAheadController,
                                        autofocus: false,
                                        decoration: const InputDecoration(
                                          hintText: 'เลือกจังหวัด',
                                          //เพิ่ม icon select,
                                          suffixIcon: Icon(
                                              Icons.arrow_drop_down_outlined,
                                              color: Colors.black),
                                          border: OutlineInputBorder(
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
                                        return provinces.where((element) =>
                                            element.toLowerCase().contains(
                                                pattern.toLowerCase()));
                                      },
                                      itemBuilder:
                                          (context, String suggestion) {
                                        return Row(
                                          children: [
                                            Flexible(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Text(
                                                  suggestion,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Color(0xFF141E46),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                      itemSeparatorBuilder: (context, index) =>
                                          const Divider(height: 1),
                                      onSuggestionSelected:
                                          (String suggestion) async {
                                        this._typeAheadController.text =
                                            suggestion;
                                        print("จังหวัดที่เลือก: $suggestion");
                                        if (provinces.contains(suggestion)) {
                                          if (suggestion == 'กรุงเทพมหานคร') {
                                            // checkBangkok = true;
                                            _typeAheadControllerDistrict
                                                .clear();
                                            getOil();
                                          } else {
                                            int idx =
                                                provinces.indexOf(suggestion);
                                            print(provincesEN[idx]);
                                            var District = await OilService()
                                                .getOilProvince(
                                                    provincesEN[idx]);
                                            oillogo.forEach((element) {
                                              District.forEach((element2) {
                                                element2['Data']
                                                    .forEach((element3) {
                                                  if (element['name'] ==
                                                      element3['Product']) {
                                                    element3['img'] =
                                                        element['img'];
                                                  }
                                                });
                                              });
                                            });
                                            print(District);
                                            setState(() {
                                              // checkBangkok = false;
                                              dataOil = District
                                                  as List<Map<String, dynamic>>;
                                              // print(dataOil);
                                              _typeAheadControllerDistrict
                                                  .clear();
                                              this.District = District.map(
                                                  (e) => e['Location']
                                                      as String).toList();
                                            });
                                          }
                                        } else {
                                          print('not found');
                                        }
                                      },
                                      suggestionsBoxDecoration:
                                          SuggestionsBoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        elevation: 8.0,
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: TypeAheadField(
                                      noItemsFoundBuilder: (context) =>
                                          Container(
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
                                        controller:
                                            _typeAheadControllerDistrict,
                                        autofocus: false,
                                        decoration: const InputDecoration(
                                          hintText: 'เลือกอำเภอ',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          suffixIcon: Icon(
                                              Icons.arrow_drop_down_outlined,
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
                                        return District.where((element) =>
                                            element.toLowerCase().contains(
                                                pattern.toLowerCase()));
                                      },
                                      itemBuilder:
                                          (context, String suggestion) {
                                        return Row(
                                          children: [
                                            Flexible(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Text(
                                                  suggestion,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                      onSuggestionSelected:
                                          (String suggestion) {
                                        this._typeAheadControllerDistrict.text =
                                            suggestion;
                                        dataOilDistrict = dataOil
                                            .where((element) =>
                                                element['Location'] ==
                                                suggestion)
                                            .toList();
                                        setState(() {
                                          checkBangkok = false;
                                          print(dataOilDistrict);
                                          dataOilDistrict = dataOilDistrict;
                                        });
                                      },
                                      suggestionsBoxDecoration:
                                          SuggestionsBoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        elevation: 8.0,
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            // width: double.infinity,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: List.generate(
                                    checkBangkok
                                        ? dataOilDistrict.length
                                        : dataOilDistrict.length == 0
                                            ? oillogo.length
                                            : dataOilDistrict[0]['Data'].length,
                                    (index) => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          '${checkBangkok ? dataOilDistrict[index]['img'] : dataOilDistrict.length == 0 ? oillogo[index]['img'] : dataOilDistrict[0]['Data'][index]['img']}',
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          height: 60,
                                          fit: BoxFit.fill,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          child: Text(
                                            "${checkBangkok ? double.parse(dataOilDistrict[index]['Price']).toStringAsFixed(2) : dataOilDistrict.length == 0 ? '0' : double.parse(dataOilDistrict[0]['Data'][index]['Price']).toStringAsFixed(2)}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF141E46),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _isLoading ? _buildLoadingScreen() : SizedBox(),
          ],
        ),
      ),
    );
  }
}
