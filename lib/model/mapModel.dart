import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class mapModel extends ChangeNotifier {
  List<dynamic> maplist = [];

  // set set_map(Map<String, dynamic> maplist) => this.maplist = maplist;

  void add_map(dynamic value) {
    maplist.add(value);
    notifyListeners();
  }

  void remove_map(dynamic value) {
    maplist.remove(value);
    print("remove: ${value} success");
    notifyListeners();
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

  dynamic get_geolocatio() async {
    try {
      var position = await _determinePosition();
      var lat = position.latitude;
      var lon = position.longitude;
      print("lat: ${lat} lon: ${lon}");
      const apikey = "804903bb8f1b3b154a6f11b156adaf62";
      final url = Uri.parse(
          'https://api.longdo.com/POIService/json/search?key=${apikey}&lon=${lon}&lat=${lat}&limit=10&span=20km');
      final response = await http.get(url);
      final jsonreponse = json.decode(response.body);
      return jsonreponse['data'];
    } catch (e) {
      print(e);
    }
  }

  List get get_map => maplist;
}
