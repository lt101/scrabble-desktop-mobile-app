import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:client_leger/constants/routes.dart';
import 'package:client_leger/services/chat/chat_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/sockets/game_room_socket/game_room_socket_service.dart';
import 'package:client_leger/services/sockets/game_socket.dart/game_socket_service.dart';
import 'package:client_leger/views/chat/chat_floater.dart';
import 'package:client_leger/views/chat/chat_page.dart';
import 'package:client_leger/views/easel/easel.dart';
import 'package:client_leger/views/play-area/grid.dart';
import 'package:client_leger/views/playAreaMenu/playAreaMenu.dart';
import 'package:client_leger/views/players/players.dart';
import 'package:client_leger/views/timer/timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../music/music.dart';

//
class GameView extends StatefulWidget {
  const GameView({super.key, required this.isObserving});
  final bool isObserving;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  GameSocketService gameSocketService = GameSocketService();
  GameRoomSocketService gameRoomSocketService = GameRoomSocketService();
  late StreamSubscription endGameSubscription;
  AudioPlayer? resultAudio;

  @override
  void initState() {
    resultAudio = AudioPlayer(playerId: 'result');
    endGameSubscription =
        gameSocketService.endGameController.stream.listen((isWinner) {
      isWinner
          ? resultAudio!.play(AssetSource('audio/win.mp3'), volume: 100)
          : resultAudio!.play(AssetSource('audio/lost.mp3'), volume: 100);
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: ((context) {
            return Dialog(
              child: contentBox(context, isWinner),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
            );
          }));
    });

    super.initState();
  }

  @override
  void dispose() {
    endGameSubscription.cancel();
    gameSocketService.flushAllControllers();
    gameRoomSocketService.flushAllControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: null,
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: GetIt.instance<SettingService>().isLightMode
                ? AssetImage("assets/images/bg-game.jpg")
                : AssetImage("assets/images/bg-game-dark.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            Container(
                margin: const EdgeInsets.only(
                  top: 60,
                ),
                child: widget.isObserving
                    ? Container(
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.only(left: 100, right: 100),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(120, 50),
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () {
                              gameSocketService.stopObserving();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  multiPlayerModeRoute, (route) => false);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Icon(Icons.arrow_back),
                                Text(
                                  AppLocalizations.of(context)!.quit,
                                  style: GoogleFonts.baloo2(fontSize: 14),
                                ),
                              ],
                            )),
                      )
                    : const PlayAreaMenu()),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: GetIt.instance<SettingService>().isDefaultSkin
                        ? null
                        : DecorationImage(
                            alignment: Alignment.bottomRight,
                            fit: BoxFit.fill,
                            image: getSkinImage()!,
                          ),
                  ),
                  child: const Grid(),
                ),
                const SizedBox(
                  height: 10,
                ),
                Easel(
                  isObserving: widget.isObserving,
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 50, left: 15),
              child: Column(
                children: [
                  const PlayerMusic(),
                  const TimerWidget(),
                  const SizedBox(
                    height: 30,
                  ),
                  Players(
                    isObserving: widget.isObserving,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  AssetImage? getSkinImage() {
    switch (GetIt.instance<SettingService>().boardSkin) {
      case 'wood':
        return const AssetImage('assets/images/wood-board.jpg');
      case 'metal':
        return const AssetImage('assets/images/metal-skin.png');
      default:
        return const AssetImage('assets/images/wood-board.jpg');
    }
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

  contentBox(BuildContext context, bool isWinner) {
    return Stack(
      children: <Widget>[
        Container(
          width: 500,
          padding: const EdgeInsets.only(
              left: 20, top: 40 + 20, right: 20, bottom: 20),
          margin: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.gameOver,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                isWinner
                    ? AppLocalizations.of(context)!.youWon
                    : AppLocalizations.of(context)!
                        .youLost, // <-- Lost or win msg
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 22,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                    onPressed: () {
                      resultAudio?.dispose();
                      gameSocketService.userInfoService
                          .getUserUpdateFromServer();
                      Navigator.pushNamedAndRemoveUntil(
                          context, mainMenuRoute, (route) => false);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.quit,
                      style: TextStyle(fontSize: 18),
                    )),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 10,
          child: isWinner
              ? Image.asset(
                  "assets/images/win.png",
                  height: 70,
                )
              : Image.asset(
                  "assets/images/lost.png",
                  height: 70,
                ),
        ),
      ],
    );
  }
}
