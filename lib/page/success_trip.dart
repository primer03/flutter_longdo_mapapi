import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/page/Fabtab.dart';
import 'package:getgeo/page/homePage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuccessTrip extends StatefulWidget {
  const SuccessTrip({Key? key}) : super(key: key);

  @override
  State<SuccessTrip> createState() => _SuccessTripState();
}

class _SuccessTripState extends State<SuccessTrip> {
  String additionalExpense = '';
  final picker = ImagePicker();
  List<XFile>? images;
  var db = FirebaseFirestore.instance;

  Future<void> _pickImages() async {
    List<XFile>? pickedImages = await picker.pickMultiImage();
    setState(() {
      images = pickedImages;
      print(images);
    });
  }

  Future<String?> saveImage() async {
    String uploadPreset = "user_image";
    String cloudName = "djncj31nj";
    try {
      images!.forEach((image) async {
        Uri uri = Uri.parse(
            "https://api.cloudinary.com/v1_1/$cloudName/image/upload");
        http.MultipartRequest request = http.MultipartRequest("POST", uri);
        request.fields['upload_preset'] = uploadPreset;
        request.files
            .add(await http.MultipartFile.fromPath('file', image.path));
        http.StreamedResponse response = await request.send();
        final res = await http.Response.fromStream(response);
        final data = json.decode(res.body);
        print(data['url']);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        var tripId = prefs.getString('trip_id');
        db.collection('trip').doc(tripId).update({
          //เพิ่มข้อมูลรูปภาพไปเลื่อยๆ
          'image': FieldValue.arrayUnion([data['url']]),
        });
      });
      //ถ้าอัพโหลดรูปภาพสำเร็จshowDialog
      setState(() {
        images = null;
      });
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "อัพโหลดรูปภาพสำเร็จ",
        text: "รูปภาพถูกอัพโหลดเรียบร้อยแล้ว",
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'การเดินทางสำเร็จแล้ว',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFC70039),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => fabtab()),
              (route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildExpenseInput(),
            SizedBox(height: 40),
            _buildImageUpload(),
            SizedBox(height: 40),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseInput() {
    return Column(
      children: <Widget>[
        Text(
          'มีค่าใช้จ่ายเพิ่มเติมหรือไม่?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFC70039),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: TextFormField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                additionalExpense = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'ระบุค่าใช้จ่ายเพิ่มเติม',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload() {
    return Column(
      children: <Widget>[
        Text(
          'อัพโหลดรูปภาพการเดินทาง',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFC70039),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            _pickImages();
          },
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFFC70039),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(75),
              color: Colors.grey[200],
            ),
            child: Center(
              child: Icon(
                Icons.cloud_upload,
                size: 40,
                color: Color(0xFFC70039),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        var tripId = prefs.getString('trip_id');
        db.collection('trip').doc(tripId).update({
          'additional_expense':
              additionalExpense == '' ? '0' : additionalExpense,
        });
        saveImage();
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => fabtab()),
            (route) => false,
          );
        });
      },
      child: Text(
        'ยืนยัน',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFC70039),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 50,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
