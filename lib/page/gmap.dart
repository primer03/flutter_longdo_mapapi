import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class GMap extends StatefulWidget {
  const GMap({Key? key});

  @override
  State<GMap> createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  LatLng _pGooglePle = LatLng(13.736717, 100.523186);
  Completer<GoogleMapController> _controller = Completer();

  List<Marker> _markers = [
    Marker(
      markerId: MarkerId("pGooglePle1"),
      position: LatLng(14.0589267, 101.3959333),
      infoWindow: InfoWindow(
        title: "มหาวิทยาลัยเทคโนโลยีพระจอมเกล้าธนบุรี",
        snippet: "มจพ",
      ),
    ),
  ];

  void fetchData(lat, lon) async {
    // var apikey = "AIzaSyBCTC1OPtff-m0psBq7F4dhDKYEkyOKR1w";
    // final url = Uri.parse(
    //     'https://maps.googleapis.com/maps/api/place/nearbysearch/json?input=สยามพารากอน&inputtype=textquery&key=${apikey}');
    // final response = await http.get(url);
    // if (response.statusCode == 200) {
    //   print("data: ${response.body}");
    // } else {
    //   print("Error: ${response.statusCode}");
    // }
    // lat = 13.720246;
    // lon = 100.51531;
    // add_mark(lat, lon);
    add_mark(13.73917, 100.52177);
    lat = lat.toStringAsFixed(6);
    lon = lon.toStringAsFixed(6);
    var apiKey = "804903bb8f1b3b154a6f11b156adaf62";
    final url = Uri.parse(
        'https://api.longdo.com/POIService/json/search?key=${apiKey}&lon=${lon}&lat=${lat}&limit=20');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print("lat: ${lat} lon: ${lon}");
      jsonData['data'].forEach((element) {
        print(
            "name ${element['name']} lat ${element['lat']} lon ${element['lon']}");
      });
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  Future<void> add_mark(lat, lon) async {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("lat ${lat} lng ${lon}"),
          position: LatLng(lat, lon),
          infoWindow: InfoWindow(
            title: "ตำแหน่งใหม่",
            snippet: "${lat}, ${lon}",
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_disabled_outlined),
        onPressed: () async {
          print("get location");
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          print("Position: ${position.latitude}, ${position.longitude}");
          GoogleMapController controller = await _controller.future;
          if (controller != null) {
            print("Animating camera");
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 15,
                ),
              ),
            );
          } else {
            print("Controller is null");
          }
        },
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _pGooglePle,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (LatLng latLng) {
                print("onTap: ${latLng.latitude}, ${latLng.longitude}");
                fetchData(latLng.latitude, latLng.longitude);
                // setState(
                //   () {
                //     _markers.add(
                //       Marker(
                //         markerId: MarkerId(
                //             "lat ${latLng.latitude} lng ${latLng.longitude}"),
                //         position: latLng,
                //         infoWindow: InfoWindow(
                //           title: "ตำแหน่งใหม่",
                //           snippet: "${latLng.latitude}, ${latLng.longitude}",
                //         ),
                //       ),
                //     );
                //   },
                // );
              },
              markers: Set.from(_markers),
            ),
          ),
        ],
      ),
    );
  }
}
