import 'package:client_leger/constants/letter_values.dart';

class Letter {
  Letter(this.letter, this.col, this.row, this.orientation) {
    points = letterPointMapping[letter]!;
    rowLetter = rowLetterMap[row]!;
  }

  final String letter;
  final int col;
  final int row;
  late int points;
  late String rowLetter;
  String orientation;

  @override
  String toString() => '$letter@($col, $row)=$points';
}
