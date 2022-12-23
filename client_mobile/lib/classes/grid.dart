class Multiplier {
  static const String WordX3 = 'WORD X3';
  static const String WordX2 = 'WORD X2';
  static const String LetterX2 = 'LETTER X2';
  static const String LetterX3 = 'LETTER X3';
  static const String Basic = 'BASIC';
}

class Box {
  late int x;
  late int y;
  late String value;
  late int index;
  late String color;
  late bool available;
  late Multiplier multiplier;
}

class Grid {
  late List<List<Box>> box;
}
