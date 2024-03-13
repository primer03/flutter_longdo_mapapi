import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:getgeo/model/mapModel.dart';
import 'package:getgeo/model/userModel.dart';
import 'package:longdo_maps_api3_flutter/longdo_maps_api3_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class routing extends StatefulWidget {
  const routing({super.key});

  @override
  State<routing> createState() => _routingState();
}

class _routingState extends State<routing> {
  final map = GlobalKey<LongdoMapState>();
  final GlobalKey<ScaffoldMessengerState> messenger =
      GlobalKey<ScaffoldMessengerState>();
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

  Future<void> _displayDraggableScrollableSheet(BuildContext context) async {
    mapModel maplist = Provider.of<mapModel>(context, listen: false);
    var datamark = maplist.get_map;
    print(datamark);
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
            return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: ListView.builder(
                controller: scrollController,
                itemCount: datamark.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0xFFC70039), width: 4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          // height: 50,
                          child: ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: Color(0xFF141E46),
                            ),
                            trailing: Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                            title: Text(
                              '${datamark[index]['name']}',
                              style: TextStyle(
                                color: Color(0xFF141E46),
                                fontSize: 17,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
    // load_maplist();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, value, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFFC70039),
          onPressed: () => _displayDraggableScrollableSheet(context),
          child: Icon(Icons.navigation),
        ),
        body: Column(children: [
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
                    var lay =
                        map.currentState?.LongdoStatic("Layers", 'RASTER_POI');
                    if (lay != null) {
                      print("ready");
                      map.currentState?.call('Layers.setBase', args: [lay]);
                    }
                    var latlon = _determinePosition();
                    var dlat = await latlon.then((value) => value.latitude);
                    var dlon = await latlon.then((value) => value.longitude);
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
                    mapModel maplist =
                        Provider.of<mapModel>(context, listen: false);
                    print("maplist");
                    print("dlat: ${dlat} dlon: ${dlon}");
                    map.currentState?.call("Route.add", args: [
                      {
                        "lon": dlon,
                        "lat": dlat,
                      }
                    ]);
                    maplist.get_map.forEach((element) {
                      print("maplist ${element['name']}");
                      print("lat: ${element['lat']} lon: ${element['lon']}");
                      map.currentState?.call("Route.add", args: [
                        {
                          "lon": element['lon'],
                          "lat": element['lat'],
                        }
                      ]);
                    });
                    map.currentState?.run(
                        'map.Route.enableRoute(longdo.RouteType.AllDrive, false);');

                    // if (AllDrive != null) {
                    //   map.currentState
                    //       ?.call("Route.enableRoute", args: [AllDrive, false]);
                    // }
                    map.currentState?.call("Route.search");
                    map.currentState?.run('''
map.Route.auto(true);
''');
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
        ]),
      ),
    );
  }
}
