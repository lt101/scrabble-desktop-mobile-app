import 'dart:async';

import 'package:client_leger/classes/SidebarInformation.dart';
import 'package:client_leger/services/game/game_service.dart';
import 'package:client_leger/services/sockets/game_room_socket/game_room_socket_service.dart';
import 'package:client_leger/services/sockets/game_socket.dart/game_socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

//
class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  StreamSubscription<void>? timerSubscription;
  GameRoomSocketService gameRoomSocketService = GameRoomSocketService();
  GameSocketService gameSocketService = GameSocketService();
  Timer? timer;
  Duration duration = const Duration();
  int turnDuration = 60;
  int seconds = 60;

  @override
  void initState() {
    setState(() {
      turnDuration = GetIt.instance<GameService>().timerDuration;
      seconds = turnDuration;
    });
    timerSubscription =
        gameRoomSocketService.timerController.stream.listen((_) {
      resetTimer();
    });
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    timer!.cancel();
    timerSubscription!.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        if (GetIt.instance<SidebarInformations>().currentPlayerId ==
            gameSocketService.socketService.socket!.id) {
          gameSocketService.skipTurn();
        }
        stopTimer(true);
      }
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() => seconds = turnDuration);
    startTimer();
  }

  void stopTimer(bool reset) {
    if (reset) {
      resetTimer();
    }
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) => Container(
        height: 130,
        width: 130,
        child: Center(
          child: buildTimer(),
        ),
      );

  Widget buildTimer() {
    if (turnDuration.isInfinite || turnDuration.isNaN) {
      turnDuration = 60;
      seconds = turnDuration;
    }
    return SizedBox(
        width: 130,
        height: 130,
        child: Stack(fit: StackFit.loose, children: [
          const Center(
            child: Image(
                width: 130,
                height: 130,
                image: AssetImage("assets/images/clock-bg.png")),
          ),
          Center(
            child: SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: 1 - seconds / turnDuration,
                strokeWidth: 8,
                valueColor: const AlwaysStoppedAnimation(
                    Color.fromARGB(255, 255, 255, 255)),
                backgroundColor: Color.fromARGB(255, 27, 53, 94),
              ),
            ),
          ),
          Center(child: buildTime()),
        ]));
  }

  Widget buildTime() {
    final isRunning = timer == null ? false : timer!.isActive;
    final isCompleted = seconds == 0;
    Color timeColor = (seconds <= 10 && seconds % 2 == 0)
        ? Color.fromARGB(255, 255, 0, 0)
        : Color.fromARGB(255, 255, 255, 255);
    int sec = seconds % 60;
    int min = (seconds / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return Text('$minute : $second',
        style: TextStyle(
            fontWeight: FontWeight.bold, color: timeColor, fontSize: 20));
  }
}
