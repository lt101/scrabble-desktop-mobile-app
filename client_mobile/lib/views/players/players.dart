import 'dart:async';

import 'package:client_leger/classes/SidebarInformation.dart';
import 'package:client_leger/classes/SidebarPlayerInformations.dart';
import 'package:client_leger/services/game/game_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/sockets/game_room_socket/game_room_socket_service.dart';
import 'package:client_leger/services/sockets/game_socket.dart/game_socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/game_view.dart';

class Players extends StatefulWidget {
  const Players({super.key, this.isObserving});
  final isObserving;
  @override
  State<Players> createState() => _PlayersState();
}

class _PlayersState extends State<Players> {
  StreamSubscription<String>? streamSubscription;
  GameRoomSocketService gameRoomSocketService = GameRoomSocketService();
  GameSocketService gameSocketService = GameSocketService();
  GameService gameService = GameService();
  List<SidebarPlayerInformations>? players =
      GetIt.instance<SidebarInformations>().players;
  String reserveSize = '72';

  @override
  void initState() {
    players = GetIt.instance<SidebarInformations>().players;
    streamSubscription =
        gameRoomSocketService.sideBarController.stream.listen((size) {
      setState(() {
        players = GetIt.instance<SidebarInformations>().players;
        reserveSize = size;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    streamSubscription!.cancel();
    gameRoomSocketService.flushAllControllers();
    gameSocketService.flushAllControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> playerWidget = <Widget>[];
    for (var i = 0; i < (players?.length ?? 0); i++) {
      playerWidget.add(Column(children: [
        Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
                left: 10, right: 1, bottom: widget.isObserving ? 0 : 20),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                    width: 3.0, color: const Color.fromARGB(255, 27, 94, 32)),
                color: GetIt.instance<SettingService>().isLightMode
                    ? (GetIt.instance<SidebarInformations>().currentPlayerId ==
                            players![i].playerId)
                        ? const Color.fromARGB(255, 173, 19, 19)
                        : const Color.fromARGB(255, 27, 94, 32)
                    : (GetIt.instance<SidebarInformations>().currentPlayerId ==
                            players![i].playerId)
                        ? const Color(0xff3f0059)
                        : const Color(0xff0c1821)),
            width: 250,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(players![i].playerName!,
                        textScaleFactor: 1,
                        style: GoogleFonts.baloo2(
                            fontSize: 23, color: Colors.white),
                        textAlign: TextAlign.center),
                    Text('Score: ${players![i].score.toString()}',
                        textScaleFactor: 1,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                  ],
                ),
                widget.isObserving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                // TODO: Set Easel to check
                                gameSocketService
                                    .observePlayer(players![i].playerId!);
                              },
                              child:
                                  Text(AppLocalizations.of(context)!.observe)),
                          players![i].playerId!.contains('virtual')
                              ? ElevatedButton(
                                  onPressed: () {
                                    // TODO: Set Easel to check
                                    gameSocketService.replaceVirtualPlayer(
                                        players![i].playerId!);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const GameView(
                                                isObserving: false,
                                              )),
                                    );
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!.remplace))
                              : const SizedBox()
                        ],
                      )
                    : const SizedBox()
              ],
            )),
        const SizedBox(height: 10)
      ]));
    }
    return Column(
      children: [
        Container(
          width: 240,
          margin: EdgeInsets.only(bottom: 10),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              width: 1.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            color: GetIt.instance<SettingService>().isLightMode
                ? const Color.fromARGB(255, 27, 94, 32)
                : const Color(0xff0c1821),
          ),
          child: DefaultTextStyle(
            style: GoogleFonts.baloo2(color: Colors.white, fontSize: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Reserve: '), Text(reserveSize)],
            ),
          ),
        ),
        Column(children: playerWidget),
      ],
    );
  }
}
