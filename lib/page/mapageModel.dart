import 'dart:convert';
import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/model/mapModel.dart';
import 'package:longdo_maps_api3_flutter/longdo_maps_api3_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Mapmode extends StatefulWidget {
  const Mapmode({super.key, required this.set_currentidx});
  final void Function(int) set_currentidx;

  @override
  State<Mapmode> createState() => _MapmodeState();
}

class _MapmodeState extends State<Mapmode> {
  final map = GlobalKey<LongdoMapState>();
  final GlobalKey<ScaffoldMessengerState> messenger =
      GlobalKey<ScaffoldMessengerState>();
  List<bool> ischeckbtnAdd = List.generate(20, (index) => false);
  var boxsearch = TextEditingController();
  var dataSearch = [];
  var dataMark = [];
  Object? mark;
  late StreamSubscription<Position> positionStream;

  Future<void> fetchData(lon, lat) async {
    // print("lat: ${lat} lon: ${lon}");
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
        if (dataMark.length == 0) {
          dataMark.add(datax[0]);
          mapModel maplist = Provider.of<mapModel>(context, listen: false);
          maplist.add_map(datax[0]);
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
        } else {
          var check =
              dataMark.where((element) => element['name'] == datax[0]['name']);
          print(check.length);
          if (check.length == 0) {
            setState(() {
              messenger.currentState?.showSnackBar(
                SnackBar(
                  content: Text(datax[0]['name'] + " ถูกเพิ่มแล้ว"),
                ),
              );
              dataMark.add(datax[0]);
              mapModel maplist = Provider.of<mapModel>(context, listen: false);
              maplist.add_map(datax[0]);
              context.read<mapModel>().get_map.forEach((element) {
                print("maplist ${element['name']}");
              });
            });
            // set_location(datax[0]['lat'], datax[0]['lon']);
            add_mark(datax[0]['lat'], datax[0]['lon']);
          } else {
            print("มีข้อมูลแล้ว");
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  title: Text("แจ้งเตือน"),
                  content: Text("มีข้อมูลนี้อยู่แล้ว",
                      style: TextStyle(color: Colors.black, fontSize: 15)),
                  actions: [
                    TextButton(
                      child: Text("ปิด",
                          style: TextStyle(color: Colors.red, fontSize: 20)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
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
                            focusNode: FocusNode(
                                canRequestFocus: true,
                                descendantsAreFocusable: true),
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
                                      set_location(dataSearch[index]['lat'],
                                          dataSearch[index]['lon']);
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
                                      // setState(() {
                                      //   dataMark.add(dataSearch[index]);
                                      // });
                                      if (dataMark.length > 0) {
                                        var check = dataMark.where((element) =>
                                            element['name'] ==
                                            dataSearch[index]['name']);
                                        print(check.length);
                                        if (check.length == 0) {
                                          setState(() {
                                            dataMark.add(dataSearch[index]);
                                          });
                                          mapModel maplist =
                                              Provider.of<mapModel>(context,
                                                  listen: false);
                                          maplist.add_map(dataSearch[index]);
                                          set_location(dataSearch[index]['lat'],
                                              dataSearch[index]['lon']);
                                          add_mark(dataSearch[index]['lat'],
                                              dataSearch[index]['lon']);
                                        } else {
                                          print("มีข้อมูลแล้ว");
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor:
                                                    Colors.grey[200],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                title: Text("แจ้งเตือน"),
                                                content: Text(
                                                    "มีข้อมูลนี้อยู่แล้ว",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15)),
                                                actions: [
                                                  TextButton(
                                                    child: Text("ปิด",
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 20)),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      } else {
                                        setState(() {
                                          dataMark.add(dataSearch[index]);
                                        });
                                        set_location(dataSearch[index]['lat'],
                                            dataSearch[index]['lon']);
                                        add_mark(dataSearch[index]['lat'],
                                            dataSearch[index]['lon']);
                                      }
                                    },
                                    child: Icon(Icons.add_box,
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

  void set_location(lat, lon) {
    map.currentState?.call("location", args: [
      {
        "lon": lon,
        "lat": lat,
      }
    ]);
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

  void load_maplist() {
    mapModel maplist = Provider.of<mapModel>(context, listen: false);
    print("maplist");
    maplist.get_map.forEach((element) {
      print("maplist ${element['name']}");
      print("lat: ${element['lat']} lon: ${element['lon']}");
      add_mark(element['lat'], element['lon']);
      setState(() {
        dataMark.add(element);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    print("start");
    // positionStream = Geolocator.getPositionStream().listen((Position position) {
    //   if (mounted) {
    //     setState(() {
    //       print("lat: ${position.latitude} lon: ${position.longitude}");
    //       set_location(position.latitude, position.longitude);
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    positionStream.cancel();
    print("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var maplist = context.watch<mapModel>().get_map;
    return Consumer<mapModel>(
      builder: (context, maplist, child) => Scaffold(
        body: Scaffold(
            floatingActionButton: FloatingActionButton.small(
              onPressed: () => _displayDraggableScrollableSheet(context),
              backgroundColor: Colors.red[600],
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
                            map.currentState
                                ?.call('Layers.setBase', args: [lay]);
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
                          load_maplist();
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
                          // map.currentState?.call("Route.add", args: [
                          //   {
                          //     "lon": lon,
                          //     "lat": lat,
                          //   }
                          // ]);
                          // print("maplist ${context.read<mapModel>().get_map}");
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
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    print("clear xd");
                                    map.currentState
                                        ?.call("Overlays.clear", args: []);
                                    setState(() {
                                      dataMark = [];
                                    });
                                    // map.currentState?.call("Route.clear");
                                    // map.currentState?.call("Route.add", args: [
                                    //   {"lon": 101.2, "lat": 12.8}
                                    // ]);
                                    // map.currentState?.call("Route.add", args: [
                                    //   {"lon": 99.5, "lat": 13.2}
                                    // ]);
                                    // map.currentState?.call("Route.search");
                                    // map.currentState
                                    //     ?.call("Route.auto", args: [true]);
                                  },
                                  child: Text("ลบทั้งหมด"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    print(dataMark.length);
                                    if (dataMark.length == 0) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.grey[200],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            title: Text("แจ้งเตือน"),
                                            content: Text(
                                                "ไม่มีข้อมูลที่จะค้นหา",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15)),
                                            actions: [
                                              TextButton(
                                                child: Text("ปิด",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 20)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      widget.set_currentidx(3);
                                    }
                                  },
                                  child: Text("ค้นหาเส้นทาง"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF141E46),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ],
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
                          padding: EdgeInsets.only(bottom: 50),
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
                                        set_location(dataMark[index]['lat'],
                                            dataMark[index]['lon']);
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
                                        print("id: ${dataMark[index]['id']}");
                                        remove_mark(index);
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
                      ),
                    ),
                    // FloatingActionButton(
                    //   onPressed: () => print("zs"),
                    //   child: Icon(Icons.add),

                    // )
                  ]),
                ))
              ],
            )),
      ),
    );
  }
}
