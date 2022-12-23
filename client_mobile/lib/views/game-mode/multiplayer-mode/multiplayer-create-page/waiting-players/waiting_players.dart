import 'dart:async';

import 'package:client_leger/classes/RoomInformations.dart';
import 'package:client_leger/constants/routes.dart';
import 'package:client_leger/services/chat/chat_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/sockets/game_room_socket/game_room_socket_service.dart';
import 'package:client_leger/services/sockets/game_socket.dart/game_socket_service.dart';
import 'package:client_leger/views/chat/chat_floater.dart';
import 'package:client_leger/views/chat/chat_page.dart';
import 'package:client_leger/views/game-mode/multiplayer-mode/multiplayer-create-page/waiting-players/waiting_players_card.dart';
import 'package:client_leger/views/game/game_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

class WaitingPlayers extends StatefulWidget {
  WaitingPlayers(
      {super.key, required this.isHost, this.roomInfo, this.visibility});
  bool isHost;
  RoomInformations? roomInfo;
  final String? visibility;

  @override
  State<WaitingPlayers> createState() => _WaitingPlayersState();
}

class _WaitingPlayersState extends State<WaitingPlayers> {
  GameRoomSocketService gameRoomSocketService = GameRoomSocketService();
  GameSocketService gameSocketService = GameSocketService();
  StreamSubscription<bool>? admittedStreamSubscription;
  StreamSubscription<dynamic>? startGameStreamSubscription;
  bool? isAdmitted = false;

  @override
  void initState() {
    if (!widget.isHost) {
      admittedStreamSubscription =
          gameRoomSocketService.isAdmittedController.stream.listen((event) {
        if (!event) {
          Navigator.of(context).pushNamed(multiPlayerModeRoute);
        }
        setState(() {
          isAdmitted = event;
        });
      });

      startGameStreamSubscription =
          gameRoomSocketService.gameStartController.stream.listen((event) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => const GameView(
                      isObserving: false,
                    )),
            (route) => false);
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    if (startGameStreamSubscription != null) {
      startGameStreamSubscription?.cancel();
    }
    if (admittedStreamSubscription != null) {
      admittedStreamSubscription?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        exitWaitingRoom();
        return Future.value(false);
      },
      child: Scaffold(
        floatingActionButton: Container(
          height: 70,
          margin: const EdgeInsets.only(bottom: 20, right: 10),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Stack(alignment: Alignment(-1.0, -1.7), children: [
              FloatingActionButton.extended(
                elevation: 20,
                onPressed: () {
                  GetIt.instance<ChatService>().chatIsOpen();
                  setState(() {});
                  Navigator.of(context).push(openChat());
                },
                materialTapTargetSize: MaterialTapTargetSize.padded,
                backgroundColor: Color.fromARGB(255, 1, 52, 114),
                icon: const Icon(
                  Icons.question_answer_rounded,
                ),
                label: Text(AppLocalizations.of(context)!.chat),
              ),
              NotificationDot()
            ]),
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: GetIt.instance<SettingService>().isLightMode
                ? AssetImage("assets/images/basic-bg.jpg")
                : AssetImage("assets/images/basic-dark.jpg"),
            fit: BoxFit.cover,
          )),
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              WaitingPlayersCard(
                visibility: widget.visibility!,
                isHost: widget.isHost,
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    exitWaitingRoom();
                  },
                  child: Text(AppLocalizations.of(context)!.quit))
            ],
          ),
        ),
      ),
    );
  }

  exitWaitingRoom() {
    if (widget.isHost) {
      gameRoomSocketService.deleteRoom();
    } else if (isAdmitted!) {
      gameRoomSocketService.leaveRoom(
          gameRoomSocketService.socketService.socket!.id!,
          widget.roomInfo!.id!);
    } else if (!isAdmitted!) {
      // Should be cancel room but cancel room not working correctly
      gameRoomSocketService.leaveRoom(
          gameRoomSocketService.socketService.socket!.id!,
          widget.roomInfo!.id!);
    }

    Navigator.of(context).pushNamed(multiPlayerModeRoute);
  }

  Route openChat() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const ChatPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
