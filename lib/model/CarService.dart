import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CarService {
  static final cars = [];

  // static dynamic _searchcar(String query) async {
  //   Map<String, String> headers = {
  //     'X-Api-Key': "/9WjotIvCfUR6iHeo/IMsQ==xpQlgq1dtyZyW5lS",
  //   };
  //   Uri uri =
  //       Uri.parse("https://api.api-ninjas.com/v1/cars?make=$query&limit=1000");
  //   http.Response response = await http.get(uri, headers: headers);
  //   if (response.statusCode == 200) {
  //     List json = jsonDecode(response.body);
  //     List<String> datacar = [];
  //     json.forEach((element) {
  //       datacar.add(element['make']);
  //     });
  //     Set<String> carset = datacar.toSet(); // Specify the type of Set
  //     return carset.toList();
  //   }
  //   return [""]; // Return a List<String>
  // }

  static Future<List<String>> _searchcar(String query) async {
    Map<String, String> headers = {
      'X-Api-Key': "/9WjotIvCfUR6iHeo/IMsQ==xpQlgq1dtyZyW5lS",
    };
    Uri uri =
        Uri.parse("https://api.api-ninjas.com/v1/cars?make=$query&limit=1000");
    http.Response response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      List json = jsonDecode(response.body);
      List<String> datacar = [];
      json.forEach((element) {
        datacar.add(element['make']);
      });
      Set<String> carset = datacar.toSet(); // Specify the type of Set
      return carset.toList();
    }
    return [""]; // Return a List<String>
  }

  static Future<List<String>> getSuggestions(String query) async {
    return await _searchcar(query);
  }
}
