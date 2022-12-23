import 'dart:async';
import 'dart:ui';

import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/sockets/game_room_socket/game_room_socket_service.dart';
import 'package:client_leger/views/game-mode/scrabble_logo.dart';
import 'package:client_leger/views/game/game_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

//
class WaitingPlayersCard extends StatefulWidget {
  const WaitingPlayersCard({super.key, required this.visibility, this.isHost});
  final String visibility;
  final bool? isHost;

  @override
  State<WaitingPlayersCard> createState() => _WaitingPlayersCardState();
}

class _WaitingPlayersCardState extends State<WaitingPlayersCard> {
  StreamSubscription<PlayerInfo>? streamSubscription;
  StreamSubscription<bool>? canStartStreamSubscription;
  GameRoomSocketService gameRoomSocketService = GameRoomSocketService();
  StreamSubscription<String>? playerLeftSubscription;
  late String visible;
  List<PlayerInfo> playerRequestList_ = [];
  List<PlayerInfo> playersAccepted_ = [];
  int acceptedPlayers = 0;
  bool canStart = false;

  @override
  void initState() {
    setState(() {
      canStart = false;
      visible = widget.visibility;
    });
    if (widget.isHost!) {
      streamSubscription = gameRoomSocketService
          .playersRequestListController.stream
          .listen((request) {
        setState(() {
          playerRequestList_.add(request);
        });
        if ((visible == "Publique" || visible == "Public") && !canStart) {
          gameRoomSocketService.acceptPlayerRequest(request.name!, request.id!);
          playerRequestList_.remove(request);
        }
      });

      playerLeftSubscription =
          gameRoomSocketService.playerLeftController.stream.listen((id) {
        setState(() {
          playersAccepted_.removeWhere((player) => player.id == id);
        });
      });

      canStartStreamSubscription =
          gameRoomSocketService.canStartController.stream.listen((event) {
        setState(() {
          canStart = event;
        });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    canStart = false;
    playerLeftSubscription?.cancel();
    canStartStreamSubscription?.cancel();
    streamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
      color: GetIt.instance<SettingService>().isLightMode
          ? Colors.white
          : const Color(0xff1c2541),
      elevation: 50.00,
      child: SizedBox(
        width: 500,
        height: 600,
        child: Column(
          children: [
            const SizedBox(height: 30),
            const ScrabbleLogoImage(),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.waitingPlayers,
              style: TextStyle(
                  fontSize: 20,
                  color: GetIt.instance<SettingService>().isLightMode
                      ? Colors.black
                      : Colors.white),
            ),
            const SizedBox(height: 50),
            const SizedBox(
              height: 10,
            ),
            playerRequestList_.isEmpty
                ? SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>((Colors.green[900])!),
                    ),
                  )
                : const SizedBox(),
            visible != 'Publique'
                ? Expanded(
                    child: ListView.builder(
                      itemCount: playerRequestList_.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 50.0, bottom: 10),
                                  child: Text(
                                    '${playerRequestList_[index].name} ${AppLocalizations.of(context)!.wantsToJoin}',
                                    style: TextStyle(
                                        color: GetIt.instance<SettingService>()
                                                .isLightMode
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          gameRoomSocketService
                                              .acceptPlayerRequest(
                                                  playerRequestList_[index]
                                                      .name!,
                                                  playerRequestList_[index]
                                                      .id!);
                                          setState(() {
                                            playersAccepted_
                                                .add(playerRequestList_[index]);
                                            playerRequestList_.removeAt(index);
                                            acceptedPlayers++;
                                          });
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .accept)),
                                    SizedBox(
                                      width: 30,
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        onPressed: () {
                                          gameRoomSocketService
                                              .denyPlayerRequest(
                                                  playerRequestList_[index]
                                                      .name!,
                                                  playerRequestList_[index]
                                                      .id!);
                                          setState(() {
                                            playerRequestList_.removeAt(index);
                                          });
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .deny)),
                                  ],
                                )
                              ],
                            )
                          ],
                        );
                      },
                    ),
                  )
                : const SizedBox(),
            Container(
              padding: EdgeInsets.only(bottom: 20),
              child: widget.isHost!
                  ? Text(
                      '${playersAccepted_.length + 1}/4 ${AppLocalizations.of(context)!.players}',
                      style: TextStyle(
                          fontSize: 18,
                          color: GetIt.instance<SettingService>().isLightMode
                              ? Colors.black
                              : Colors.white),
                    )
                  : const SizedBox(),
            ),
            Container(
                child: canStart
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: ElevatedButton(
                            onPressed: () {
                              gameRoomSocketService.startGame();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const GameView(
                                          isObserving: false,
                                        )),
                              );
                            },
                            child:
                                Text(AppLocalizations.of(context)!.startGame)),
                      )
                    : const SizedBox())
          ],
        ),
      ),
    ));
  }
}
