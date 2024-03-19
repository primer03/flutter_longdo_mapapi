import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:getgeo/model/CarService.dart';
import 'package:getgeo/model/oilService.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _typeAheadController = TextEditingController();
  var db = FirebaseFirestore.instance;
  final TextEditingController _usernameController = TextEditingController();
  String selectoil = '';
  String imageUrlClound = '';
  bool isDropdownEnabled = true;
  int? selectedValue = 1;
  List<String> Oilname = [];
  bool _isLoading = true;
  String imageUrl = '';
  var data = null;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  List<Map<String, dynamic>> carData = [];
  String uploadPreset = "user_image";

  // @override
  // void dispose() {
  //   super.dispose();
  //   _typeAheadController.dispose();
  // }

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
    GetuserData();
    getOil();
    getEvData();
  }

  void _startLoading() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoading = !_isLoading;
    });
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

  Widget _buildLoadingScreen() {
    return AbsorbPointer(
      absorbing: true, // ปิดการใช้งานปุ่ม
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

  void Imagepick() async {
    final XFile? selectImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (selectImage != null) {
      print(selectImage.path);
      File? croppedFile = await cropImage(selectImage.path);
      if (croppedFile != null) {
        print("Cropped Image Path: ${croppedFile.path}");
        setState(() {
          _imageFile = XFile(croppedFile.path);
        });
        // saveImage(XFile(croppedFile.path));
      }
    }
  }

  Future<File?> cropImage(String imagePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Color.fromARGB(255, 197, 13, 0),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ],
      cropStyle: CropStyle.circle,
    );
    return croppedFile != null ? File(croppedFile.path) : null;
  }

  Future<void> updateUserData() async {
    print(_isLoading);
    setState(() {
      _isLoading = true;
    });
    print(_isLoading);
    // _startLoading();
    _imageFile != null ? await saveImage() : null;
    if (_imageFile != null) {
      if (imageUrlClound != '') {
        _startLoading();
      }
    }
    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    var user_email = userModel.email;
    try {
      db
          .collection('user_setting')
          .where('user_email', isEqualTo: user_email)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          _imageFile != null
              ? db.collection('user_setting').doc(element.id).update({
                  'user_img': imageUrlClound,
                  'user_name': _usernameController.text,
                  'car_brand': _typeAheadController.text,
                  'car_type': selectedValue == 1 ? 'น้ำมัน' : 'ไฟฟ้า',
                  'car_oil': selectoil,
                })
              : db.collection('user_setting').doc(element.id).update({
                  'user_img': userModel.imgPhoto,
                  'user_name': _usernameController.text,
                  'car_brand': _typeAheadController.text,
                  'car_type': selectedValue == 1 ? 'น้ำมัน' : 'ไฟฟ้า',
                  'car_oil': selectoil,
                });
        });
      });
      if (_imageFile == null) {
        _startLoading();
      }
      setState(() {
        userModel.imgPhoto = imageUrlClound != '' ? imageUrlClound : imageUrl;
        userModel.email = user_email;
        userModel.username = _usernameController.text;
        _imageFile = null;
        imageUrl = imageUrlClound != '' ? imageUrlClound : imageUrl;
        // _isLoading = imageUrlClound != '' ? false : true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 10),
              Text('บันทึกข้อมูลสำเร็จ'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกข้อมูลไม่สำเร็จ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> saveImage() async {
    String uploadPreset = "user_image";
    String cloudName = "djncj31nj";
    Uri uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    http.MultipartRequest request = http.MultipartRequest("POST", uri);
    request.fields['upload_preset'] = uploadPreset;
    request.files
        .add(await http.MultipartFile.fromPath('file', _imageFile!.path));
    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedResponse = json.decode(responseData);
        imageUrlClound = decodedResponse['secure_url'];
        print(decodedResponse);
        print(imageUrlClound);
        UserModel userModel = Provider.of<UserModel>(context, listen: false);
        var user_email = userModel.email;
        userModel.imgPhoto = imageUrlClound;
        await db
            .collection('user_setting')
            .where('user_email', isEqualTo: user_email)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            db.collection('user_setting').doc(element.id).update({
              'user_img': imageUrlClound,
            });
          });
        });
        return imageUrlClound;
      } else {
        print('Failed to upload image');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> GetuserData() async {
    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    var user_email = userModel.email;
    print(user_email);
    data = await db
        .collection('user_setting')
        .where('user_email', isEqualTo: user_email)
        .get();
    if (data.docs.isNotEmpty) {
      _startLoading();
    }
    setState(() {
      _typeAheadController.text = data.docs[0]['car_brand'];
      data.docs[0]['car_type'] == 'น้ำมัน'
          ? selectedValue = 1
          : selectedValue = 2;
      selectoil = data.docs[0]['car_oil'];
      _usernameController.text = data.docs[0]['user_name'];
      imageUrl = data.docs[0]['user_img'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขข้อมูลส่วนตัว'),
        backgroundColor: Color(0xFFFC70039),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        // padding: EdgeInsets.all(10),
        // margin: EdgeInsets.only(top: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Material(
                          elevation: 8, //คือการเงา
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          //สีเงา
                          shadowColor: Colors.red.withOpacity(0.5),
                          shape: CircleBorder(),
                          child: InkWell(
                            splashColor: Colors.black26,
                            splashFactory: InkSplash.splashFactory,
                            onTap: () {
                              print('Image Clicked');
                              Imagepick();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                //border gardient
                                border: Border.all(
                                  color: Color.fromARGB(255, 197, 13, 0),
                                  width: 4,
                                ),
                              ),
                              child: Ink.image(
                                image: _imageFile != null
                                    ? FileImage(File(_imageFile!.path))
                                    : NetworkImage(
                                        imageUrl == ''
                                            ? 'https://www.pngkey.com/png/full/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png'
                                            : imageUrl,
                                      ) as ImageProvider<Object>,
                                fit: BoxFit.cover,
                                width: 150,
                                height: 150,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 197, 13, 0),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.camera_alt, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'ชื่อ-สกุล',
                        hintText: 'ชื่อ-สกุล',
                        // hintStyle: TextStyle(color: Colors.grey[400]),
                        // labelStyle: TextStyle(color: Color(0xFFFC70039)),
                        floatingLabelStyle:
                            TextStyle(color: Color(0xFFFC70039)),
                        prefixIcon: Icon(Icons.person),
                        contentPadding: EdgeInsets.all(20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFFFC70039),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'ประเภทรถที่ใช้งาน',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
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
                            });
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
                    Container(
                      width: double.infinity,
                      child: Text(
                        'แบรนด์รถที่ใช้งาน',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    selectedValue == 1
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
                                prefixIcon: Icon(Icons.car_repair_sharp),
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
                            suggestionsBoxDecoration: SuggestionsBoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              elevation: 8.0,
                              color: Theme.of(context).cardColor,
                            ),
                          )
                        : TypeAheadField(
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
                                prefixIcon: Icon(Icons.car_repair_sharp),
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
                            suggestionsBoxDecoration: SuggestionsBoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              elevation: 8.0,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                    SizedBox(height: 10),
                    selectedValue == 1
                        ? Container(
                            width: double.infinity,
                            child: Text(
                              'เลือกประเภทน้ำมันที่ใช้งาน',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(height: 10),
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
                    selectedValue == 1 ? SizedBox(height: 10) : Container(),
                    ElevatedButton(
                      onPressed: () {
                        updateUserData();
                        // Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFC70039),
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(200, 50),
                      ),
                      child: Text(
                        'บันทึกข้อมูล',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Impact',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _isLoading ? _buildLoadingScreen() : Container(),
          ],
        ),
      ),
    );
  }
}
