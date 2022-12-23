import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:client_leger/classes/SidebarInformation.dart';
import 'package:client_leger/classes/letter.dart';
import 'package:client_leger/constants/letter_values.dart';
import 'package:client_leger/services/game/game_service.dart';
import 'package:client_leger/services/game/grid_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/sockets/game_socket.dart/game_socket_service.dart';
import 'package:client_leger/views/play-area/support/inner_shadow.dart';
import 'package:events_emitter/listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

List<Letter>? lettersOnBoard;

class Grid extends StatefulWidget {
  final bool? isObserving;

  const Grid({super.key, this.isObserving});

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  @override
  void initState() {
    lettersOnBoard = [];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Layout Grid Scrabble Example',
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: GetIt.instance<SettingService>().isDefaultSkin
                ? GetIt.instance<SettingService>().isLightMode
                    ? const Color.fromARGB(255, 221, 205, 153)
                    : const Color(0xff3a506b)
                : Colors.transparent),
        height: 665,
        width: 665,
        margin: const EdgeInsets.only(top: 25),
        child: SizedBox(
          height: GetIt.instance<SettingService>().isDefaultSkin ? 665 : 650,
          width: GetIt.instance<SettingService>().isDefaultSkin ? 665 : 650,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 36, right: 34),
                child: DefaultTextStyle(
                  style: TextStyle(
                      color: GetIt.instance<SettingService>().isDefaultSkin
                          ? GetIt.instance<SettingService>().isLightMode
                              ? Colors.black
                              : Colors.white
                          : Colors.white),
                  child: Container(
                    color: GetIt.instance<SettingService>().isDefaultSkin
                        ? null
                        : Color.fromARGB(110, 0, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: letterCoordinates(),
                    ),
                  ),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: DefaultTextStyle(
                        style: GoogleFonts.ubuntu(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: GetIt.instance<SettingService>()
                                    .isDefaultSkin
                                ? GetIt.instance<SettingService>().isLightMode
                                    ? Colors.black
                                    : Colors.white
                                : Colors.white),
                        child: Container(
                          color: GetIt.instance<SettingService>().isDefaultSkin
                              ? null
                              : Color.fromARGB(110, 0, 0, 0),
                          child: Column(
                            children: numberCoordinates(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: GetIt.instance<SettingService>().isDefaultSkin
                          ? const EdgeInsets.only(bottom: 0)
                          : const EdgeInsets.only(left: 15, bottom: 15),
                      child: ScrabbleBoard(
                        tiles: getLettersOnBoard(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> letterCoordinates() {
    return const [
      Text('A'),
      Text('B'),
      Text('C'),
      Text('D'),
      Text('E'),
      Text('F'),
      Text('G'),
      Text('H'),
      Text('I'),
      Text('J'),
      Text('K'),
      Text('L'),
      Text('M'),
      Text('N'),
      Text('O'),
    ];
  }

  List<Widget> numberCoordinates() {
    return const [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('1'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('2'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('3'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('4'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('5'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('6'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('7'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('8'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('9'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('10'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('11'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('12'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('13'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('14'),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 11.5),
        child: Text('15'),
      ),
    ];
  }
}

// This method updates the displayed grid
List<Letter> getTiles() {
  // update grid with socketIO
  return convertGridToLetterList();
}

// This method converts a 2D List (List<List<Tile>>) representing the grid to a 1D List
List<Letter> convertGridToLetterList() {
  /*Letter letter = Letter("A", 1, 1); // remove this line
  
  Letter letter2 = Letter("G", 1, 2);
  Letter letter3 = Letter("M", 1, 3);
  Letter letter4 = Letter("D", 1, 4);
  list.add(letter);
  list.add(letter2);
  list.add(letter3);
  list.add(letter4);*/

  return GetIt.instance<GridService>().lettersPlaced;
}

List<Letter> getLettersOnBoard() {
  if (GetIt.instance<GridService>().lettersPlaced.isNotEmpty) {
    for (Letter letter in GetIt.instance<GridService>().lettersPlaced) {
      if (!lettersOnBoard!.contains(letter)) {
        lettersOnBoard!.add(letter);
      }
    }
  }
  return lettersOnBoard ?? [Letter('NULL', 8, 8, 'h')];
}

const trackCount = 15;
const doubleLetterCount = 24;
const doubleWordCount = 16;
const tripleLetterCount = 12;
const tripleWordCount = 8;
const tileCount = trackCount * trackCount; // star

class ScrabbleBoard extends StatefulWidget {
  ScrabbleBoard({
    Key? key,
    required this.tiles,
  }) : super(key: key);

  List<Letter> tiles;

  @override
  State<ScrabbleBoard> createState() => _ScrabbleBoardState();
}

class _ScrabbleBoardState extends State<ScrabbleBoard> {
  StreamSubscription<dynamic>? gridStreamSubscription;
  EventListener? cancelEvent;
  GameSocketService gameSocketService = GameSocketService();
  GameService gameService = GameService();
  final String areas = '''
        tw0 .  . dl0 .  .  . tw1 .  .  . dl1 .  . tw2
         . dw0 .  .  . tl0 .  .  . tl1 .  .  . dw1 .
         .  . dw2 .  .  . dl2 . dl3 .  .  . dw3 .  .
        dl4 .  . dw4 .  .  . dl5 .  .  . dw5 .  .  dl6
         .  .  .  . dw6 .  .  .  .  . dw7 .  .  .  .
         . tl2 .  .  . tl3 .  .  . tl4 .  .  . tl5 .
         .  . dl7 .  .  . dl8 . dl9 .  .  . dla .  .
        tw3 .  . dlb .  .  .  ★  .  .  . dlc .  .  tw4
         .  . dld .  .  . dle . dlf .  .  . dlg .  .
         . tl6 .  .  . tl7 .  .  . tl8 .  .  . tl9 .
         .  .  .  . dw8 .  .  .  .  . dw9 .  .  .  .
        dlh .  . dwa .  .  . dli .  .  . dwb .  .  dlj
         .  . dwc .  .  . dlk . dll .  .  . dwd .  .
         . dwe .  .  . tla .  .  . tlb .  .  . dwf .
        tw5 .  . dlm .  .  . tw6 .  .  . dln .  .  tw7
      ''';

  @override
  void initState() {
    gridStreamSubscription =
        gameSocketService.gridController_.stream.listen((letterFromServer) {
      setState(() {
        widget.tiles = letterFromServer;
        lettersOnBoard = letterFromServer;
      });
    });
    cancelEvent = GetIt.instance<GridService>().events.on('cancel', (_) {
      log('cancel called');
      removeAllPlacedLetters();
    });
    super.initState();
  }

  @override
  void dispose() {
    gridStreamSubscription!.cancel();
    cancelEvent!.cancel();
    super.dispose();
  }

  void removeAllPlacedLetters() {
    for (Letter letter in GetIt.instance<GridService>().lettersPlaced) {
      lettersOnBoard!.remove(letter);
      GetIt.instance<GridService>().emitRemovedLetters(letter.letter);
      gameService.putLetterBackController.add(letter);
    }
    setState(() {});
    GetIt.instance<GridService>().lettersPlaced.clear();
  }

  @override
  Widget build(BuildContext context) {
    Widget scrabbleBoardWidget = LayoutGrid(
      areas: areas,
      // A number of extension methods are provided for concise track sizing
      columnSizes: GetIt.instance<SettingService>().isDefaultSkin
          ? repeat(trackCount, [42.px])
          : repeat(trackCount, [39.px]),
      rowSizes: GetIt.instance<SettingService>().isDefaultSkin
          ? repeat(trackCount, [42.px])
          : repeat(trackCount, [39.px]),
      children: [
        // First, square bases
        for (int i = 0; i < trackCount; i++)
          for (int j = 0; j < trackCount; j++)
            StandardSquare(Vector2(j + 1, i + 1))
                .withGridPlacement(columnStart: i, rowStart: j),
        // Then put bonuses on top
        StartingSquare(getColoredSquareCoordinate('★')).inGridArea('★'),
        for (int i = 0; i < doubleLetterCount; i++)
          DoubleLetterSquare(
                  getColoredSquareCoordinate('dl${i.toRadixString(36)}'))
              .inGridArea('dl${i.toRadixString(36)}'),
        for (int i = 0; i < doubleWordCount; i++)
          DoubleWordSquare(
                  getColoredSquareCoordinate('dw${i.toRadixString(36)}'))
              .inGridArea('dw${i.toRadixString(36)}'),
        for (int i = 0; i < tripleLetterCount; i++)
          TripleLetterSquare(
                  getColoredSquareCoordinate('tl${i.toRadixString(36)}'))
              .inGridArea('tl${i.toRadixString(36)}'),
        for (int i = 0; i < tripleWordCount; i++)
          TripleWordSquare(
                  getColoredSquareCoordinate('tw${i.toRadixString(36)}'))
              .inGridArea('tw${i.toRadixString(36)}'),

        // Then place tiles on top of those
        for (final tile in widget.tiles)
          LetterTile(letter: tile.letter).withGridPlacement(
            columnStart: tile.col - 1,
            rowStart: tile.row - 1,
            // - 1 since the method starts placing at index 0
          ),
      ],
    );
    return scrabbleBoardWidget;
  }

  // Returns coordinates from an input bonus label such as tw0
  Vector2 getColoredSquareCoordinate(String bonusLabel) {
    List<String> grid = formatStringGrid();
    int index = -1;
    for (int i = 0; i < grid.length; i++) {
      if (grid[i].contains(bonusLabel)) {
        index = i;
        break;
      }
    }
    int col = (index % 15) + 1;
    int row = (index ~/ 15) + 1;
    if (col == 0) col = 15; // 15 % 15 = 0

    return Vector2(row, col);
  }

  List<String> formatStringGrid() {
    List<String> formattedGrid = areas.trim().split(" ");
    String emptyChar = formattedGrid[2];
    formattedGrid.removeWhere((element) => element == emptyChar);
    return formattedGrid;
  }
}

const orangeSquareBackground = Color(0xfffd8e73);
const magentaSquareBackground = Color(0xfff01c7a);
const lightBlueSquareBackground = Color(0xff8ecafc);
const darkBlueSquareBackground = Color(0xff1375b0);

class LetterTile extends StatelessWidget {
  LetterTile({Key? key, required String letter})
      : letter = letter.toUpperCase(),
        super(key: key);

  final String letter;
  bool isSelected = false;

  double get lockupRightPadding {
    switch (letter) {
      case 'M':
        return 1.5;
      case 'G':
        return 3;
      default:
        return 1;
    }
  }

  double get pointsRightPadding {
    switch (letter) {
      case 'G':
        return 0;
      case 'A':
      case 'M':
        return 1;
      case 'T':
        return 3;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: SizedBox.expand(
        child: InnerShadow(
          offset: const Offset(0, -1.5),
          blurX: 0.8,
          blurY: 1,
          color: Colors.black.withOpacity(.25),
          child: _buildTileContents(),
        ),
      ),
    );
  }

  DecoratedBox _buildTileContents() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xfffaeac2),
        border: Border.all(
          color: Colors.black.withAlpha(18),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          right: lockupRightPadding + 0.3,
          bottom: 0.8,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildLetterLabel(),
            _buildPointLabel(),
          ],
        ),
      ),
    );
  }

  Text _buildLetterLabel() {
    return Text(
      letter,
      style: GoogleFonts.nunitoSans(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Positioned _buildPointLabel() {
    return Positioned(
      right: pointsRightPadding,
      bottom: 1,
      child: Text(
        '${letterPointMapping[letter]}',
        style: GoogleFonts.nunitoSans(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class StartingSquare extends Square {
  const StartingSquare(Vector2 coordinates, {Key? key})
      : super(
          coordinates: coordinates,
          key: key,
          label: '★',
          color: orangeSquareBackground,
          edgeInsetsOverride: const EdgeInsets.only(left: 0.2, bottom: 0.5),
          labelFontSizeOverride: 14,
        );
}

class DoubleLetterSquare extends Square {
  const DoubleLetterSquare(Vector2 coordinates, {Key? key})
      : super(
          coordinates: coordinates,
          key: key,
          label: 'DL',
          color: lightBlueSquareBackground,
        );
}

class DoubleWordSquare extends Square {
  const DoubleWordSquare(Vector2 coordinates, {Key? key})
      : super(
          coordinates: coordinates,
          key: key,
          label: 'DW',
          color: orangeSquareBackground,
        );
}

class TripleLetterSquare extends Square {
  const TripleLetterSquare(Vector2 coordinates, {Key? key})
      : super(
          coordinates: coordinates,
          key: key,
          label: 'TL',
          color: darkBlueSquareBackground,
        );
}

class TripleWordSquare extends Square {
  const TripleWordSquare(Vector2 coordinates, {Key? key})
      : super(
          coordinates: coordinates,
          key: key,
          label: 'TW',
          color: magentaSquareBackground,
        );
}

class StandardSquare extends Square {
  StandardSquare(Vector2 coordinates, {Key? key})
      : super(
          coordinates: coordinates,
          key: key,
          color: const Color(0xffe7eaef),
        );
}

class Square extends StatefulWidget {
  const Square({
    Key? key,
    required this.coordinates,
    required this.color,
    this.label,
    this.labelFontSizeOverride,
    this.edgeInsetsOverride,
  }) : super(key: key);

  final Vector2 coordinates;
  final Color color;
  final String? label;
  final double? labelFontSizeOverride;
  final EdgeInsets? edgeInsetsOverride;

  @override
  State<Square> createState() => _SquareState();
}

class _SquareState extends State<Square> {
  GameSocketService gameSocketService = GameSocketService();
  static bool accepted = false;
  static LetterTile letterTile = LetterTile(letter: 'A');
  AudioPlayer? placeAudio;

  @override
  void initState() {
    placeAudio = AudioPlayer(playerId: 'place');
    super.initState();
  }

  @override
  void dispose() {
    placeAudio?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // LetterTile letterTile;

    return DragTarget<LetterTile>(
      builder: (context, candidateData, rejectedData) {
        return accepted
            ? returnText(context)
            : Padding(
                padding: const EdgeInsets.all(3.0),
                child: SizedBox.expand(
                    child: InnerShadow(
                  offset: const Offset(0, 0.5),
                  blurX: 0.8,
                  blurY: 0.7,
                  color: Colors.black.withOpacity(.25),
                  child: SizedBox.expand(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius:
                            const BorderRadius.all(Radius.elliptical(6, 4)),
                      ),
                      child: _buildLabel(context),
                    ),
                  ),
                )));
      },
      onAcceptWithDetails: (data) => placeLetter(data),
      onAccept: (data) {},
    );
  }

  Widget returnText(BuildContext context) {
    accepted = false;
    return letterTile;
  }

  Widget _buildLabel(BuildContext context) {
    final label = widget.label;
    if (label == null) return const SizedBox();
    return Center(
      child: Padding(
        padding: widget.edgeInsetsOverride ??
            const EdgeInsets.only(top: 1.0, left: 0.5),
        child: Text(
          label,
          style: GoogleFonts.robotoCondensed(
            fontWeight: FontWeight.w500,
            fontSize: widget.labelFontSizeOverride ?? 12,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  void placeLetter(DragTargetDetails<LetterTile> data) {
    if (GetIt.instance<SidebarInformations>().currentPlayerId !=
        gameSocketService.socketService.socket!.id) return;
    placeAudio?.play(AssetSource('audio/place.mp3'));
    if (lettersOnBoard!.isEmpty) {
      if ((widget.coordinates.y == 8) && (widget.coordinates.x == 8)) {
        accepted = true;
        GetIt.instance<GridService>().lettersPlaced.add(Letter(
            data.data.letter, widget.coordinates.y, widget.coordinates.x, ''));
        GetIt.instance<GridService>().emitPlacedLetters(data.data.letter);
      }
    } else {
      String orientation = '';
      for (var i = 0; i < lettersOnBoard!.length; i++) {
        if (true) {
          accepted = true;
          if (GetIt.instance<GridService>().lettersPlaced.length == 1) {
            //Set orientaiton
            if (lettersOnBoard![i].row + 1 == widget.coordinates.x ||
                lettersOnBoard![i].row - 1 == widget.coordinates.x) {
              orientation = 'v';
            } else if (lettersOnBoard![i].col + 1 == widget.coordinates.y ||
                lettersOnBoard![i].col - 1 == widget.coordinates.y) {
              orientation = 'h';
            }
          }
        }
      }
      if (accepted) {
        Letter letter;
        if (GetIt.instance<GridService>().lettersPlaced.length == 1) {
          //Set orientaiton
          GetIt.instance<GridService>().lettersPlaced[0].orientation =
              orientation;
          letter = Letter(data.data.letter, widget.coordinates.y,
              widget.coordinates.x, orientation);
          GetIt.instance<GridService>().lettersPlaced.add(letter);
          GetIt.instance<GridService>().emitPlacedLetters(data.data.letter);
        } else if (GetIt.instance<GridService>().lettersPlaced.length >= 2) {
          if (GetIt.instance<GridService>().lettersPlaced[0].orientation ==
                  'h' &&
              (GetIt.instance<GridService>().lettersPlaced[0].row ==
                  widget.coordinates.x)) {
            letter = Letter(
                data.data.letter,
                widget.coordinates.y,
                widget.coordinates.x,
                GetIt.instance<GridService>().lettersPlaced[0].orientation);
            GetIt.instance<GridService>().lettersPlaced.add(letter);
            GetIt.instance<GridService>().emitPlacedLetters(data.data.letter);
          } else if (GetIt.instance<GridService>()
                      .lettersPlaced[0]
                      .orientation ==
                  'v' &&
              (GetIt.instance<GridService>().lettersPlaced[0].col ==
                  widget.coordinates.y)) {
            letter = Letter(
                data.data.letter,
                widget.coordinates.y,
                widget.coordinates.x,
                GetIt.instance<GridService>().lettersPlaced[0].orientation);
            GetIt.instance<GridService>().lettersPlaced.add(letter);
            GetIt.instance<GridService>().emitPlacedLetters(data.data.letter);
          }
        } else if (GetIt.instance<GridService>().lettersPlaced.isEmpty) {
          letter = Letter(data.data.letter, widget.coordinates.y,
              widget.coordinates.x, orientation);
          GetIt.instance<GridService>().lettersPlaced.add(letter);
          GetIt.instance<GridService>().emitPlacedLetters(data.data.letter);
        }
        accepted = false;
      }
    }

    var ancestralState = context.findAncestorStateOfType<_GridState>();
    ancestralState?.setState(() {});
  }
}

class Vector2 {
  Vector2(this.x, this.y);
  final int x;
  final int y;
}
