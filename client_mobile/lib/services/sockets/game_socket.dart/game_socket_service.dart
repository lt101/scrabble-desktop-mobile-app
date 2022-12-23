import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:client_leger/classes/SidebarInformation.dart';
import 'package:client_leger/classes/SidebarPlayerInformations.dart';
import 'package:client_leger/classes/letter.dart';
import 'package:client_leger/constants/socket_events.dart';
import 'package:client_leger/services/game/easel_service.dart';
import 'package:client_leger/services/game/game_service.dart';
import 'package:client_leger/services/game/grid_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/sockets/socket_service.dart';
import 'package:client_leger/services/user-info/user_info_service.dart';
import 'package:client_leger/views/play-area/grid.dart' as play;
import 'package:client_leger/views/play-area/grid.dart';
import 'package:get_it/get_it.dart';

//
class GameSocketService {
  SocketService socketService = SocketService();
  UserInfoService userInfoService = UserInfoService();
  StreamController<dynamic> gridController = StreamController<dynamic>();
  StreamController<Future<List<play.LetterTile>>> easelController =
      StreamController<Future<List<play.LetterTile>>>();
  StreamController<List<SidebarPlayerInformations>> sidebarController =
      StreamController<List<SidebarPlayerInformations>>();
  StreamController<String> cancelLettersStreamController =
      StreamController<String>();
  StreamController endGameController = StreamController();
  List<String> hintList = [];
  List<Letter> lettersPlaced = [];
  AudioPlayer? wrongAnswer;
  AudioPlayer? playAudio;

  GameSocketService() {
    closeExistantEventListeners();
    initSocketListeners();
    wrongAnswer = AudioPlayer(playerId: 'wrong');
    playAudio = AudioPlayer(playerId: 'play');
  }

  StreamController<dynamic> get gridController_ => gridController;
  StreamController<String> get cancelLettersStreamController_ =>
      cancelLettersStreamController;
  StreamController<Future<List<play.LetterTile>>> get easelController_ =>
      easelController;
  StreamController<List<SidebarPlayerInformations>> get sidebarController_ =>
      sidebarController;

  void sendPlayToServer() {
    String username = '';
    userInfoService
        .getCurrentUser()
        .then((player) => username = player.userName);
    String word = '';
    for (var letter in GetIt.instance<GridService>().lettersPlaced) {
      word += letter.letter.toLowerCase();
    }
    if (GetIt.instance<GridService>().lettersPlaced.isEmpty) {
      return;
    }
    String placement =
        '!placer ${GetIt.instance<GridService>().lettersPlaced[0].rowLetter.toLowerCase()}${GetIt.instance<GridService>().lettersPlaced[0].col}${GetIt.instance<GridService>().lettersPlaced[0].orientation} $word';
    socketService.socket!.emit(chatEvent, {
      'gameId': GetIt.instance<GameService>().gameId,
      'playerId': socketService.socket!.id,
      'playerName': username,
      'content': placement,
    });
  }

  void skipTurn() {
    String username = '';
    userInfoService
        .getCurrentUser()
        .then((player) => username = player.userName);
    socketService.socket!.emit(chatEvent, {
      'gameId': GetIt.instance<GameService>().gameId,
      'playerId': socketService.socket!.id,
      'playerName': username,
      'content': '!passer',
    });
  }

  void exchangeLetters() {
    String username = '';
    userInfoService
        .getCurrentUser()
        .then((player) => username = player.userName);
    String letters = '';
    for (LetterTile letter in GetIt.instance<EaselService>().tilesToChange) {
      letters += letter.letter.toLowerCase();
    }
    String exchangeRequest = '!échanger $letters';
    socketService.socket!.emit(chatEvent, {
      'gameId': GetIt.instance<GameService>().gameId,
      'playerId': socketService.socket!.id,
      'playerName': username,
      'content': exchangeRequest,
    });
    GetIt.instance<EaselService>().tilesToChange.clear();
  }

  void cancelLetterPlaced() {
    GetIt.instance<GridService>().cancelLetterPlaced();
  }

  void observePlayer(String targetId) {
    socketService.socket!.emit(
        "game:get_easel", [targetId, GetIt.instance<GameService>().gameId]);
  }

  void replaceVirtualPlayer(String virtualId) {
    socketService.socket!.emit("game:replace_virtual_player",
        [virtualId, GetIt.instance<GameService>().gameId]);
  }

  void stopObserving() {
    socketService.socket!
        .emit("game:observer_quit", GetIt.instance<GameService>().gameId);
    GetIt.instance<GameService>().gameId = '';
    socketService.socket!.disconnect();
    GetIt.instance<SettingService>().socketDisconnected();
  }

  void getHints() {
    hintList.clear();
    socketService.socket!
        .emit("game:get_hints", GetIt.instance<GameService>().gameId);
  }

  void receiveHints(String hints) {
    hintList.add(hints);
  }

  bool didPlayerWin(String winner) {
    return winner == userInfoService.userprofile.userName;
  }

  void closeExistantEventListeners() {
    socketService.socket!.off('game:return_hints');
  }

  void initSocketListeners() {
    socketService.socket!.on(gridUpdateEvent, (data) {
      List<Letter> letterOnBoard = [];
      for (var i = 0; i < 15; i++) {
        for (var j = 0; j < 15; j++) {
          if (data['boxes'][i][j]['available'] == false) {
            letterOnBoard.add(Letter(
                (data['boxes'][i][j]['value'] as String).toUpperCase(),
                data['boxes'][i][j]['y'],
                data['boxes'][i][j]['x'],
                ''));
          }
        }
      }
      if (!gridController.isClosed) {
        gridController.add(letterOnBoard);
      }
    });
    // Receive easel (Letter[])
    socketService.socket!.on(easelUpdateEvent, (data) {
      List<play.LetterTile> letters = [];
      for (var letter_ in (data as List<dynamic>)) {
        letters.add(play.LetterTile(letter: letter_['letter']));
      }
      if (!easelController.isClosed) {
        easelController.add(Future.value(letters));
      }
      GetIt.instance<EaselService>().letterTiles = letters;
    });

    // Receive SidebarInfo (SidebarInformation)
    socketService.socket!.on(sideBarUpdateEvent, (data) {
      GetIt.instance<SidebarInformations>().reserveSize = data['reserveSize'];
      GetIt.instance<SidebarInformations>().setPlayerInfo(data);
      GetIt.instance<SidebarInformations>()
          .setCurrentPlayer(data['currentPlayerId']);
    });

    socketService.socket!.on(chatEvent, (message) {
      if (message is String) return;
      if ((message as Map<String, dynamic>)['content'] ==
          "Ce placement est impossible") {
        cancelLetterPlaced();
        wrongAnswer?.play(AssetSource('audio/wrong.mp3'));
      } else if ((message as Map<String, dynamic>)['content'][0] == '!') {
        GetIt.instance<GridService>().lettersPlaced.clear();
        playAudio?.play(AssetSource('audio/word.wav'), volume: 20);
      }
    });

    socketService.socket!.on("game:ended", ([endGameInfo, winner]) {
      String winner = (endGameInfo as List).last;
      bool result = didPlayerWin(winner);
      endGameController.add(result);
    });

    socketService.socket!.on('game:return_hints', (hints) {
      receiveHints(hints);
    });
  }

  void flushAllControllers() {
    gridController.close();
    easelController.close();
    sidebarController.close();
    cancelLettersStreamController.close();
    endGameController.close();
    gridController = StreamController<dynamic>();
    easelController = StreamController<Future<List<LetterTile>>>();
    sidebarController = StreamController<List<SidebarPlayerInformations>>();
    cancelLettersStreamController = StreamController<String>();
    endGameController = StreamController();
  }
}
