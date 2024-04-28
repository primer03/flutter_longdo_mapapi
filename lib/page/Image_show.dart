import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:http/http.dart' as http;

class ImageShowTrip extends StatefulWidget {
  const ImageShowTrip({Key? key, required this.trip_id}) : super(key: key);
  final String trip_id;

  @override
  State<ImageShowTrip> createState() => _ImageShowTripState();
}

class _ImageShowTripState extends State<ImageShowTrip> {
  final picker = ImagePicker();
  List<XFile>? images;

  Future<void> _pickImages() async {
    List<XFile>? pickedImages = await picker.pickMultiImage();
    setState(() {
      images = pickedImages;
      print(images);
    });
    saveImage();
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
        FirebaseFirestore.instance
            .collection('trip')
            .doc(widget.trip_id)
            .update({
          //เพิ่มข้อมูลรูปภาพไปเลื่อยๆ
          'image': FieldValue.arrayUnion([data['url']]),
        });
      });
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
        title: const Text('รูปภาพที่ถ่ายขณะเดินทาง'),
        backgroundColor: Color(0xFFC70039),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        width: double.infinity,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('trip')
              .doc(widget.trip_id)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text("No data available"),
              );
            }
            var data = snapshot.data!.data() as Map<String, dynamic>;
            var images = data['image'] as List<dynamic>?; // Add null check here
            if (images == null) {
              return const Center(
                child: Text("No images available"),
              );
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.confirm,
                              title: 'ยืนยันการลบรูปภาพ',
                              text: 'คุณต้องการลบรูปภาพนี้ใช่หรือไม่',
                              onConfirmBtnTap: () {
                                FirebaseFirestore.instance
                                    .collection('trip')
                                    .doc(widget.trip_id)
                                    .update({
                                  'image':
                                      FieldValue.arrayRemove([images[index]])
                                });
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  title: 'ลบรูปภาพสำเร็จ',
                                  text: 'รูปภาพถูกลบเรียบร้อยแล้ว',
                                  onConfirmBtnTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _pickImages();
        },
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}
