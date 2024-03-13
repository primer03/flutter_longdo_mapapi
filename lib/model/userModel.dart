import 'package:flutter/material.dart';
import 'package:getgeo/page/map.dart';
import 'package:card_swiper/card_swiper.dart';

class UserModel {
  String username = "";
  String imgPhoto = "";
  String email = "";
  String password = "";

  // UserModel({required this.username, required this.imgPhoto});

  set set_user(String username) {
    this.username = username;
  }

  set set_email(String email) {
    this.email = email;
  }

  set set_img(String imgPhoto) {
    this.imgPhoto = imgPhoto;
  }

  set set_password(String password) {
    this.password = password;
  }

  Map<String, dynamic> get_user() {
    return {
      "username": username,
      "imgPhoto": imgPhoto,
      "email": email,
      "password": password
    };
  }
}
