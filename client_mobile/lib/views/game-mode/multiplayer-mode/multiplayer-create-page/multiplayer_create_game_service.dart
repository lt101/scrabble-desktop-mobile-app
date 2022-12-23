// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:developer';

import 'package:client_leger/services/sockets/game_room_socket/game_room_socket_service.dart';

class MultiplayerCreateGameService {
  static const List<String> dictionaryList = <String>['Dictionnaire de base'];
  static const List<String> timerList = <String>[
    '30s',
    '1min',
    '1min30s',
    '2min',
    '2min30s',
    '3min',
    '3min30',
    '4min',
    '4min30',
    '5min'
  ];
  final Map<String, int> timerConvertMap = {
    '30s': 30,
    '1min': 60,
    '1min30s': 90,
    '2min': 120,
    '2min30s': 150,
    '3min': 180,
    '3min30': 210,
    '4min': 240,
    '4min30': 270,
    '5min': 300
  };
  static const List<String> visibilities = ['Publique', 'Privée'];

  GameRoomSocketService gameRoomSocketService = GameRoomSocketService();

  MultiplayerCreateGameService();

  bool isAlphabetical(str) {
    return RegExp(r'^[a-zA-Z]+').hasMatch(str);
  }

  createGame(String roomName, String dictionary, String timerValue,
      String visibility, String password) {
    log('Create game called');
    if (visibility == 'Publique')
      visibility = 'public';
    else if (visibility == 'Privée') visibility = 'private';
    int timer = timerConvertMap[timerValue] ?? 60;
    gameRoomSocketService.createNewRoom(
        roomName, dictionary, timer, visibility, password);
  }
}
