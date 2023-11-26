import 'package:flutter/material.dart';
import 'package:getgeo/page/map.dart';
import 'package:card_swiper/card_swiper.dart';

class UserModel {
  String username = "";
  String imgPhoto = "";

  // UserModel({required this.username, required this.imgPhoto});

  set set_user(String username) {
    this.username = username;
  }

  set set_img(String imgPhoto) {
    this.imgPhoto = imgPhoto;
  }

  Map<String, dynamic> get_user() {
    return {"username": username, "imgPhoto": imgPhoto};
  }
}
