import 'package:client_leger/views/play-area/grid.dart';

class EaselService {
  List<LetterTile> letterTiles = [
    LetterTile(letter: ""),
    LetterTile(letter: ""),
    LetterTile(letter: ""),
    LetterTile(letter: ""),
    LetterTile(letter: ""),
    LetterTile(letter: ""),
    LetterTile(letter: ""),
  ];

  List<LetterTile> tilesToChange = [];

  EaselService();

  List<LetterTile> getTiles() {
    return letterTiles;
  }
}
