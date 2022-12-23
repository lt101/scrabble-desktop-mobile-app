import 'dart:async';
import 'dart:convert';

import 'package:client_leger/classes/RoomInformations.dart';
import 'package:client_leger/classes/SidebarInformation.dart';
import 'package:client_leger/classes/objective.dart';
import 'package:client_leger/constants/socket_events.dart';
import 'package:client_leger/services/chat/chat_service.dart';
import 'package:client_leger/services/game/game_mode_service.dart';
import 'package:client_leger/services/game/game_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/sockets/socket_service.dart';
import 'package:get_it/get_it.dart';

class GameRoomSocketService {
  late SocketService socketService;
  ChatService chatService = ChatService();

  StreamController<List<RoomInformations>> roomListController =
      StreamController<List<RoomInformations>>();
  StreamController<List<RoomInformations>> objRoomListController =
      StreamController<List<RoomInformations>>();
  StreamController<List<RoomInformations>> observableListController =
      StreamController<List<RoomInformations>>();
  StreamController<PlayerInfo> playersRequestListController =
      StreamController<PlayerInfo>();
  StreamController<String> playerLeftController = StreamController<String>();
  StreamController<bool> canStartController = StreamController<bool>();
  StreamController<bool> isAdmittedController = StreamController<bool>();
  StreamController<dynamic> gameStartController = StreamController<dynamic>();
  StreamController<String> sideBarController = StreamController<String>();
  StreamController<void> timerController = StreamController<void>();
  StreamController isPlaying = StreamController();
  StreamController<List<Objective>> objectivesController =
      StreamController<List<Objective>>();

  GameRoomSocketService() {
    socketService = SocketService();
    socketService.socket!
        .emit(availableRoomsEvent, GetIt.instance<GameModeService>().gameMode);
    socketService.socket!.emit("room:observable_rooms_request", 'classic');
    socketService.socket!.on("room:available_rooms_updated", (data) {
      updateRoomList(data);
    });

    socketService.socket!.on("room:observable_rooms_updated", (data) {
      List<RoomInformations> rooms = [];
      (data as List<dynamic>).forEach((room) {
        RoomInformations newRoom = RoomInformations.fromJSON(room);
        rooms.add(newRoom);
      });
      observableListController.add(rooms);
    });

    socketService.socket!.on("room:join_request_abandoned", (id) {
      playerLeftController.add(id);
    });

    socketService.socket!.on("room:join_requested", (data) {
      PlayerInfo playerInfo = PlayerInfo(data['id'], data['name']);
      addPlayerRequest(playerInfo);
    });

    socketService.socket!.on("room:game_can_start", (data) {
      canStartController.add(data);
    });

    socketService.socket!.on("room:join_request_rejected", (_) {
      isAdmittedController.add(false);
    });

    socketService.socket!.on("room:join_request_accepted", (_) {
      isAdmittedController.add(true);
    });

    socketService.socket!.on("room:game_started", (data) {
      String gameId = data['gameId'];
      int timer = data['timer'];
      GetIt.instance<GameService>().gameId = gameId;
      GetIt.instance<GameService>().setTimer(timer);
    });

    socketService.socket!.on("room:game_started_mobile", (data) {
      gameStartController.add('');
    });

    socketService.socket!.on("sidebar:updated", (data) {
      GetIt.instance<SidebarInformations>().reserveSize = data['reserveSize'];
      GetIt.instance<SidebarInformations>().currentPlayerId =
          data['currentPlayerId'];
      GetIt.instance<SidebarInformations>().setPlayerInfo(data);
      sideBarController.add(data['reserveSize'].toString());
      // ignore: void_checks
      timerController.add('');
      isPlaying.add('');
    });

    socketService.socket!.on("objectives:public-updated", (objectives) {
      if ((objectives as List<dynamic>).isEmpty) return;
      for (int i = 0; i < 4; i++) {
        Objective ojective = Objective(
          objectives[i]['title'],
          objectives[i]['description'],
          objectives[i]['points'],
          objectives[i]['done'],
        );
        if (GetIt.instance<GameService>().objectives.length < 4) {
          GetIt.instance<GameService>().objectives.add(ojective);
        }
      }
      objectivesController.add(GetIt.instance<GameService>().objectives);
    });
  }

  StreamController<List<RoomInformations>> get roomListcontroller_ =>
      roomListController;

  void createNewRoom(String roomName, String dict, int timer, String visibility,
      String password) {
    GameParameters parameters = GameParameters(
        'dictionnary.json',
        GetIt.instance<GameModeService>().gameMode,
        timer,
        visibility,
        password);
    socketService.socket!
        .emit(createRoomEvent, [roomName, jsonEncode(parameters)]);
  }

//
  void updateRoomList(List<dynamic> roomList) {
    List<RoomInformations> rooms = [];
    List<RoomInformations> objRooms = [];
    for (var room in roomList) {
      RoomInformations newRoom = RoomInformations.fromJSON(room);
      if (newRoom.parameters?.mode == 'classic') {
        rooms.add(newRoom);
      } else if (newRoom.parameters?.mode == 'log2990') {
        objRooms.add(newRoom);
      }
    }

    objRoomListController.add(objRooms);
    roomListController.add(rooms);
  }

  void addPlayerRequest(PlayerInfo info) {
    playersRequestListController.add(info);
  }

  void denyPlayerRequest(String playerName, String playerID) {
    String playerInfo = '{"id": "$playerID", "name": "$playerName"}';
    socketService.socket!.emit("room:reject_join_request", playerInfo);
  }

  void acceptPlayerRequest(String playerName, String playerID) {
    String playerInfo = '{"id": "$playerID", "name": "$playerName"}';
    socketService.socket!.emit("room:accept_join_request", playerInfo);
  }

  void joinRoom(String playerName, String playerID, String roomId) {
    String playerInfo = '{"id": "$playerID", "name": "$playerName"}';
    GetIt.instance<GameService>().gameId = roomId;
    chatService.addChatRoom(roomId);
    socketService.socket!.emit(joinRoomEvent, [playerInfo, roomId]);
  }

  void observeRoom(String roomId, String userName) {
    GetIt.instance<GameService>().gameId = roomId;
    chatService.addChatRoom(roomId);
    socketService.socket!.emit("room:add_observer", [roomId, userName]);
  }

  void startGame() {
    socketService.socket!.emit("room:game_start");
  }

  void cancelRequest(String roomid) {
    socketService.socket!.emit("room:cancel_join_request", roomid);
  }

  void quitGame() {
    socketService.socket!
        .emit("game:surrender", GetIt.instance<GameService>().gameId);
    GetIt.instance<GameService>().gameId = '';
    socketService.socket!.disconnect();
    GetIt.instance<SettingService>().socketDisconnected();
  }

  void leaveRoom(String playerId, String roomId) {
    socketService.socket!.emit(leaveRoomEvent, [playerId, roomId]);
    chatService.deleteChatRoom(roomId);
    GetIt.instance<GameService>().gameId = '';
  }

  void deleteRoom() {
    socketService.socket!.emit(deleteRoomEvent);
  }

  void flushAllControllers() {
    sideBarController.close();
    sideBarController = StreamController<String>();
    objectivesController.close();
    objectivesController = StreamController<List<Objective>>();
    timerController.close();
    timerController = StreamController();
    isPlaying.close();
    isPlaying = StreamController();
  }
}

class PlayerInfo {
  String? id;
  String? name;
  PlayerInfo(this.id, this.name);
}
