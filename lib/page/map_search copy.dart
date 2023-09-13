import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:longdo_maps_api3_flutter/longdo_maps_api3_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Mymap_search extends StatefulWidget {
  const Mymap_search({super.key, required this.title});
  final String title;

  @override
  State<Mymap_search> createState() => MapState();
}

class MapState extends State<Mymap_search> {
  final map = GlobalKey<LongdoMapState>();
  var apikey = "804903bb8f1b3b154a6f11b156adaf62";
  Future<void> fetchData(value) async {
    final url = Uri.parse(
        'https://search.longdo.com/mapsearch/json/search?keyword=${value}&limit=100&key=${apikey}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      var name = List.from(jsonData['data'].map((e) => e['name']));
      print(name is List ? true : false);
      print(name);
      setState(() {
        province = name;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<bool> isCheckedList = List.generate(20, (index) => false);
  var province = [];
  List<String> bpro = [];

  @override
  Widget build(BuildContext context) {
    // set_pro();
    return MaterialApp(
        home: Scaffold(
            // appBar: AppBar(
            //   title: Text(widget.title),
            // ),
            body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            height: 50,
            width: double.infinity,
            child: TextFormField(
              onChanged: (value) {
                fetchData(value);
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
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: [
                for (int i = 0; i < province.length; i++)
                  Column(
                    children: [
                      Container(
                        // decoration: BoxDecoration(),
                        // color: Colors.blue[50], // Set the background color here
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              print(isCheckedList);
                              setState(() {
                                isCheckedList[i] = !isCheckedList[i];
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.location_on),
                              // child: Icon(
                              //   isCheckedList[i]
                              //       ? Icons.check_box
                              //       : Icons.check_box_outline_blank,
                              // ),
                            ),
                          ),
                          title: Text('${province[i]}'),
                          subtitle: Text('Subtitle ${i + 1}'),
                          trailing: Icon(Icons.add),
                          onTap: () {
                            print('Location $i');
                          },
                        ),
                      ),
                      SizedBox(height: 10), // Add spacing between items
                    ],
                  ),
              ],
            ),
          )
        ]),
      ),
    )));
  }
}
