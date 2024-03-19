import 'package:flutter/material.dart';
import 'package:getgeo/page/map.dart';
import 'package:card_swiper/card_swiper.dart';

class TripModel extends ChangeNotifier {
  List<dynamic> trip = [];

  set set_trip(List<dynamic> trip) {
    this.trip = trip;
  }

  Map<String, dynamic> get_trip() {
    return {"trip": trip};
  }

  void add_trip(dynamic trip) {
    this.trip.add(trip);
  }

  void remove_trip(int index) {
    this.trip.removeAt(index);
  }

  void clear_trip() {
    this.trip.clear();
  }

  void update_trip(int index, dynamic trip) {
    this.trip[index] = trip;
  }

  void swap_trip(int firstIndex, int secondIndex) {
    final temp = trip[firstIndex];
    trip[firstIndex] = trip[secondIndex];
    trip[secondIndex] = temp;
  }

  void move_trip(int fromIndex, int toIndex) {
    final trip = this.trip.removeAt(fromIndex);
    this.trip.insert(toIndex, trip);
  }

  void print_trip() {
    print(trip);
  }
}
