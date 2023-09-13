import 'dart:convert';
import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:longdo_maps_api3_flutter/longdo_maps_api3_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Mymap extends StatefulWidget {
  const Mymap({super.key, required this.title});
  final String title;
  @override
  State<Mymap> createState() => MapState();
}

class MapState extends State<Mymap> {
  final map = GlobalKey<LongdoMapState>();
  final GlobalKey<ScaffoldMessengerState> messenger =
      GlobalKey<ScaffoldMessengerState>();
  List<bool> ischeckbtnAdd = List.generate(20, (index) => false);
  var boxsearch = TextEditingController();
  var dataSearch = [];
  var dataMark = [];
  Object? mark;
  Future<void> fetchData(lon, lat) async {
    var apiKey = "804903bb8f1b3b154a6f11b156adaf62";
    final url = Uri.parse(
        'https://api.longdo.com/POIService/json/search?key=${apiKey}&lon=${lon}&lat=${lat}&limit=20');
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
        dataMark.add(datax[0]);
        // print("dataMark ${dataMark}");
        // print("daramark length ${dataMark.length}");
        var name = List.from(datax.map((e) => e['name']));
        print(name is List ? true : false);
        print(name);
        setState(() {
          dataMark = dataMark;
          messenger.currentState?.showSnackBar(
            SnackBar(
              content: Text(name.toString()),
            ),
          );
        });
        mark = map.currentState?.LongdoObject(
          "Marker",
          args: [
            {
              "lon": datax[0]['lon'],
              "lat": datax[0]['lat'],
            },
          ],
        );
        if (mark != null) {
          map.currentState?.call("Overlays.add", args: [mark!]);
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

  Future _displayBottomSheet(BuildContext context) {
    TextEditingController _searchController = TextEditingController();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30.0),
        ),
      ),
      builder: (context) => Container(
        height: 400,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 50,
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'ค้นหา',
                          suffixIcon: Icon(Icons.search),
                          // labelText: 'ค้นหา',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () {
                          print("XD");
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.search, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.pink.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> searchData(value) async {
    const apikey = "804903bb8f1b3b154a6f11b156adaf62";
    final url = Uri.parse(
        'https://search.longdo.com/mapsearch/json/search?keyword=${value}&limit=100&key=${apikey}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      // print(jsonData['data']);
      dataSearch = jsonData['data'];
      if (value == "") {
        dataSearch = [];
      } else {
        print(jsonData['data']);
        dataSearch = jsonData['data'];
      }
      setState(() {
        dataSearch = dataSearch;
      });
      print(dataSearch.length);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _displayDraggableScrollableSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.95,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0), // Adjust as needed
                  topRight: Radius.circular(20.0), // Adjust as needed
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  child: Column(children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: boxsearch,
                            onChanged: (value) {
                              searchData(value);
                            },
                            decoration: InputDecoration(
                              hintText: 'ค้นหา',
                              suffixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10, // ปรับตามต้องการ
                                horizontal: 10, // ปรับตามต้องการ
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => searchData(boxsearch.text),
                          child: Icon(Icons.search, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: dataSearch.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              ListTile(
                                  leading: GestureDetector(
                                    onTap: () {
                                      map.currentState?.call("location", args: [
                                        {
                                          "lon": dataSearch[index]['lon'],
                                          "lat": dataSearch[index]['lat'],
                                        }
                                      ]);
                                      print(
                                          "lat: ${dataSearch[index]['lat']} lon: ${dataSearch[index]['lon']}");
                                    },
                                    child: Icon(Icons.location_on,
                                        color: Colors.grey.shade300),
                                  ),
                                  title: Text(dataSearch[index]['name']),
                                  subtitle: Text(dataSearch[index]['address']),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        dataMark.add(dataSearch[index]);
                                      });
                                      map.currentState?.call("location", args: [
                                        {
                                          "lon": dataSearch[index]['lon'],
                                          "lat": dataSearch[index]['lat'],
                                        }
                                      ]);
                                      mark = map.currentState?.LongdoObject(
                                        "Marker",
                                        args: [
                                          {
                                            "lon": dataSearch[index]['lon'],
                                            "lat": dataSearch[index]['lat'],
                                          },
                                        ],
                                      );
                                      if (mark != null) {
                                        map.currentState?.call("Overlays.add",
                                            args: [mark!]);
                                      }
                                    },
                                    child: Icon(
                                        ischeckbtnAdd[index]
                                            ? Icons.add_box
                                            : Icons.add_box_outlined,
                                        color: Colors.pink.shade300),
                                  )),
                              Divider(
                                height: 1,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    )
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Object? marker;
    return MaterialApp(
      scaffoldMessengerKey: messenger,
      home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _displayDraggableScrollableSheet(context),
            backgroundColor: Colors.pink.shade300,
            child: Icon(Icons.search),
          ),
          body: Column(
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
                        // map.currentState
                        //     ?.call("Ui.Geolocation.visible", args: [true]);
                        // map.currentState?.call("zoom", args: [20, true]);
                        // var zoom = await map.currentState?.call("location");
                        // print("get zoom ${zoom} xd}");
                        // print(zoom);
                        // print("get zoom ${zoom.cur} xd}");
                        // map.currentState?.call("Event.bind",
                        //     args: ["click", (e) => print("click")]);
                        var lay = map.currentState
                            ?.LongdoStatic("Layers", 'RASTER_POI');
                        if (lay != null) {
                          print("ready");
                          map.currentState?.call('Layers.setBase', args: [lay]);
                        }
                        var latlon = _determinePosition();
                        print(latlon);
                        latlon.then((value) => {
                              setState(() {
                                map.currentState?.call("location", args: [
                                  {
                                    "lon": value.longitude,
                                    "lat": value.latitude,
                                  }
                                ]);
                              })
                            });
                      },
                    ),
                    JavascriptChannel(
                      name: "click",
                      onMessageReceived: (message) {
                        // print("click XD");
                        // print(jsonDecode(message.message)['data']);
                        var data = jsonDecode(message.message)['data'];
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
              Expanded(
                  child: Padding(
                padding: EdgeInsets.all(2.0),
                child: Column(children: [
                  Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.pink, width: 2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("รายการที่ marker",
                              style: TextStyle(fontSize: 20)),
                          ElevatedButton(
                            onPressed: () {
                              map.currentState
                                  ?.call("Overlays.clear", args: []);
                              setState(() {
                                dataMark = [];
                              });
                            },
                            child: Text("ลบทั้งหมด"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: dataMark.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: Colors.pink[50],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.purple,
                                  width: 2,
                                ),
                              ),
                              child: ListTile(
                                leading: GestureDetector(
                                  onTap: () {
                                    // print(ischeckbtnAdd);
                                    // setState(() {
                                    //   ischeckbtnAdd[index] =
                                    //       !ischeckbtnAdd[index];
                                    // });
                                  },
                                  child: Container(
                                    // alignment: Alignment.centerLeft,
                                    width: 50,
                                    height: 50,
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.purple,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                title: Text("${dataMark[index]['name']}"),
                                trailing: GestureDetector(
                                  onTap: () {
                                    print(
                                        "lat: ${index + 1} lon: ${index + 1}");
                                  },
                                  child: Icon(Icons.delete,
                                      color: Colors.pink.shade300),
                                ),
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
                  )),
                  // FloatingActionButton(
                  //   onPressed: () => print("zs"),
                  //   child: Icon(Icons.add),

                  // )
                ]),
              ))
            ],
          )),
    );
  }
}
