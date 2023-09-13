import 'dart:math';

void main(List<String> args) {
  // var n = 1.0452.toStringAsFixed(2);
  // print(n);
  // String? strd = "123456789";
  // String? strd2 = strd?.substring(0, 2);

  // print(strd2);

  // int? num = set_ramdom();
  // num += 1;
  // print(num);
  var anime_name = ['Naruto', 'One Piece', 'Bleach', 'Dragon Ball'];
  print("Naruto in anime_name: ${anime_name.contains('Naruto')}");
  anime_name.forEach((element) => print(element));

  // var anime_n = List.generate(anime_name.length,
  //     (index) => anime_name[index].contains('a') ? anime_name[index] : '')
  //   ..removeWhere((element) => element.isEmpty);
  var anime_n = anime_name.where((element) => element.contains('a')).toList();
  print(anime_n);
  print(max(1, 2));
}

int set_ramdom() => Random().nextInt(100);
