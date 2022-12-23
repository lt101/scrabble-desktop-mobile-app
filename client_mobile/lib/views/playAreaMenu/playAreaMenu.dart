// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:client_leger/classes/SidebarInformation.dart';
import 'package:client_leger/classes/objective.dart';
import 'package:client_leger/constants/routes.dart';
import 'package:client_leger/services/game/game_mode_service.dart';
import 'package:client_leger/services/game/game_service.dart';
import 'package:client_leger/services/game/grid_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/sockets/game_room_socket/game_room_socket_service.dart';
import 'package:client_leger/services/sockets/game_socket.dart/game_socket_service.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nice_buttons/nice_buttons.dart';

//
class PlayAreaMenu extends StatefulWidget {
  const PlayAreaMenu({super.key});
  @override
  State<PlayAreaMenu> createState() => _PlayAreaMenuState();
}

class _PlayAreaMenuState extends State<PlayAreaMenu> {
  GameSocketService gameSocketService = GameSocketService();
  GameRoomSocketService gameRoomSocketService = GameRoomSocketService();
  late StreamSubscription<List<Objective>> objectivesSubscription;
  late StreamSubscription isPlayingSubscription;
  List<Objective> objectives = [];
  AudioPlayer? cancelAudio;

  @override
  void initState() {
    objectives = GetIt.instance<GameService>().objectives;
    objectivesSubscription =
        gameRoomSocketService.objectivesController.stream.listen((liste) {
      setState(() {
        objectives = liste;
      });
    });
    isPlayingSubscription =
        gameRoomSocketService.isPlaying.stream.listen((event) {
      setState(() {});
    });
    cancelAudio = AudioPlayer(playerId: 'cancel');
    super.initState();
  }

  @override
  void dispose() {
    objectivesSubscription.cancel();
    isPlayingSubscription.cancel();
    gameRoomSocketService.flushAllControllers();
    gameSocketService.flushAllControllers();
    cancelAudio!.dispose();
    super.dispose();
  }

  // Function called :
  /* 
    Quit -> quitAlert() "Abandonner"
    Pass -> gameSocketService.skipTurn()
    Exchange -> gameSocketService.exchangeLetters()
    Cancel -> GetIt.instance<GridService>().cancelLetterPlaced()
    Play - > gameSocketService.sendPlayToServer()
   */

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Column(
        children: [
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              onPressed: () {
                quitAlert();
              },
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_rounded),
                  Text(AppLocalizations.of(context)!.surrender)
                ],
              )),
          const SizedBox(
            height: 5,
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  top: GetIt.instance<GameModeService>().isObjectiveMode
                      ? 45
                      : 0,
                  left: 50,
                  right: 50),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/stone-bg.png"),
                  fit: BoxFit.fill,
                ),
              ),
              height: 280,
              width: 340,
              child: GetIt.instance<GameModeService>().isObjectiveMode
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            'Objectives',
                            style: GoogleFonts.baloo2(
                                color: Colors.white, fontSize: 16),
                          ),
                          for (int i = 0;
                              i <
                                  GetIt.instance<GameService>()
                                      .objectives
                                      .length;
                              i++)
                            ExpandablePanel(
                              collapsed: const SizedBox(),
                              expanded: Text(
                                GetIt.instance<GameService>()
                                    .objectives[i]
                                    .description,
                                style: GoogleFonts.baloo2(
                                    fontSize: 12, color: Colors.white),
                              ),
                              header: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    GetIt.instance<GameService>()
                                        .objectives[i]
                                        .title,
                                    style: GoogleFonts.baloo2(
                                      fontSize: GetIt.instance<GameService>()
                                                  .objectives[i]
                                                  .title
                                                  .length <
                                              10
                                          ? 20
                                          : 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    objectives[0].done
                                        ? Icons.task_alt_rounded
                                        : Icons.stars_rounded,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            )
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        AppLocalizations.of(context)!.classicMode,
                        style: GoogleFonts.baloo2(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            NiceButtons(
              disabled: isNotPlaying(),
              startColor: isNotPlaying()
                  ? Color.fromARGB(183, 129, 131, 129)
                  : const Color.fromARGB(255, 16, 104, 145),
              borderColor: const Color.fromARGB(255, 58, 58, 58),
              endColor: isNotPlaying()
                  ? Color.fromARGB(183, 129, 131, 129)
                  : const Color.fromARGB(255, 1, 102, 156),
              width: 120,
              stretch: false,
              gradientOrientation: GradientOrientation.Vertical,
              onTap: (finish) {
                gameSocketService.skipTurn();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.pass,
                    style: GoogleFonts.baloo2(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20),
                  ),
                  const Icon(
                    Icons.fast_forward,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            NiceButtons(
              disabled: isNotPlaying(),
              startColor: isNotPlaying()
                  ? Color.fromARGB(183, 129, 131, 129)
                  : const Color.fromARGB(255, 16, 104, 145),
              borderColor: const Color.fromARGB(255, 58, 58, 58),
              endColor: isNotPlaying()
                  ? Color.fromARGB(183, 129, 131, 129)
                  : const Color.fromARGB(255, 1, 102, 156),
              width: 120,
              stretch: false,
              gradientOrientation: GradientOrientation.Vertical,
              onTap: (finish) {
                gameSocketService.exchangeLetters();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.exchange,
                    style: GoogleFonts.baloo2(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18),
                  ),
                  const Icon(
                    Icons.autorenew_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(
            height: 20,
          ),
          NiceButtons(
            disabled: isNotPlaying(),
            startColor: isNotPlaying()
                ? Color.fromARGB(183, 129, 131, 129)
                : const Color.fromARGB(255, 0, 133, 0),
            borderColor: const Color.fromARGB(255, 34, 62, 36),
            endColor: isNotPlaying()
                ? Color.fromARGB(123, 129, 131, 129)
                : const Color.fromARGB(255, 0, 133, 0),
            width: 120,
            height: 120,
            borderRadius: 100,
            stretch: false,
            gradientOrientation: GradientOrientation.Vertical,
            onTap: (finish) {
              gameSocketService.sendPlayToServer();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.play,
                  style: GoogleFonts.fredokaOne(
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      fontSize: 23),
                ),
                const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              NiceButtons(
                startColor: const Color.fromARGB(255, 133, 0, 0),
                borderColor: const Color.fromARGB(255, 0, 0, 0),
                endColor: const Color.fromARGB(255, 156, 1, 1),
                width: 100,
                height: 40,
                stretch: false,
                gradientOrientation: GradientOrientation.Vertical,
                onTap: (finish) {
                  cancelAudio!.play(AssetSource('audio/cancel.mp3'));
                  GetIt.instance<GridService>().cancelLetterPlaced();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Icon(
                      Icons.cancel,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 35,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(10),
                      backgroundColor: isNotPlaying()
                          ? Color.fromARGB(183, 129, 131, 129)
                          : Color.fromARGB(255, 8, 81, 142)),
                  onPressed: () {
                    if (isNotPlaying()) return;
                    List<String> hintList = [];
                    gameSocketService.closeExistantEventListeners();
                    showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: ((context) {
                          gameSocketService.getHints();

                          return StatefulBuilder(
                              builder: (context, StateSetter set) {
                            gameSocketService.socketService.socket!
                                .on('game:return_hints', (hints) {
                              hintList.add(hints);
                              set(() {});
                            });
                            return Dialog(
                              child: Container(
                                  padding: EdgeInsets.all(20),
                                  height: 300,
                                  width: 300,
                                  child: Column(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .possibleHints,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (hintList.isEmpty)
                                        Center(
                                          child: Container(
                                              margin: EdgeInsets.only(top: 100),
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                      for (String hints in hintList)
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Text(
                                            hints,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        )
                                    ],
                                  )),
                            );
                          });
                        })).then((value) {
                      gameSocketService.socketService.socket!
                          .off('game:return_hints');
                    });
                  },
                  child: const Icon(Icons.lightbulb,
                      size: 35, color: Colors.white)),
              SizedBox(
                width: 50,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(10),
                      backgroundColor: Color.fromARGB(255, 8, 81, 142)),
                  onPressed: (() {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                              width: 900,
                              color: Colors.white,
                              padding: EdgeInsets.all(20),
                              child: Image.asset('assets/images/help.jpg')),
                        );
                      },
                    );
                  }),
                  child: const Icon(Icons.help, size: 35, color: Colors.white))
            ],
          )
        ],
      )
    ]);
  }

  isNotPlaying() {
    return GetIt.instance<SidebarInformations>().currentPlayerId !=
        gameSocketService.socketService.socket!.id;
  }

  quitAlert() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: GetIt.instance<SettingService>().isLightMode
              ? Colors.white
              : Color.fromARGB(255, 9, 39, 65),
          title: Text(
            AppLocalizations.of(context)!.surrendering,
            style: TextStyle(
                color: GetIt.instance<SettingService>().isLightMode
                    ? Colors.black
                    : Colors.white),
          ),
          content: Text(AppLocalizations.of(context)!.surrenderConfirm,
              style: TextStyle(
                  color: GetIt.instance<SettingService>().isLightMode
                      ? Colors.black
                      : Colors.white)),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(
              width: 150,
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(AppLocalizations.of(context)!.yes),
              onPressed: () {
                GetIt.instance<GameService>().objectives.clear();
                gameRoomSocketService.quitGame();
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  mainMenuRoute,
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
