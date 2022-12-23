import 'dart:async';

import 'package:client_leger/classes/letter.dart';
import 'package:client_leger/classes/objective.dart';

class GameService {
  String gameId = '';
  dynamic player = {'id': '', 'name': ''};
  late bool isCurrentPlayer;
  late String currentPlayerId;
  int timerDuration = 60;
  List<Objective> objectives = [];
  late StreamController<Letter> placeLetterStreamController;
  late StreamController<Letter> putLetterBackController;
  GameService() {
    placeLetterStreamController = StreamController<Letter>();
    putLetterBackController = StreamController<Letter>();
  }

  setTimer(int time) {
    timerDuration = time;
  }
}
//