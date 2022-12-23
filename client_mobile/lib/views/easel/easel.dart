import 'dart:async';

import 'package:client_leger/services/game/easel_service.dart';
import 'package:client_leger/services/game/game_service.dart';
import 'package:client_leger/services/game/grid_service.dart';
import 'package:client_leger/services/sockets/game_socket.dart/game_socket_service.dart';
import 'package:events_emitter/listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get_it/get_it.dart';

import '../play-area/grid.dart';

class Easel extends StatefulWidget {
  const Easel({super.key, this.isObserving});
  final bool? isObserving;
  @override
  State<Easel> createState() => _EaselState();
}

class _EaselState extends State<Easel> {
  StreamSubscription<Future<List<LetterTile>>>? receiveEaselSubscription;
  EventListener? placedEvent;
  EventListener? removedEvent;
  GameSocketService gameSocketService = GameSocketService();
  GameService gameService = GameService();
  late Future<List<LetterTile>> letterTiles =
      Future.value(GetIt.instance<EaselService>().letterTiles);

  @override
  void initState() {
    receiveEaselSubscription =
        gameSocketService.easelController.stream.listen((letters) async {
      setState(() {
        letterTiles = letters;
      });
    });
    placedEvent = GetIt.instance<GridService>().events.on('placed', (data) {
      letterTiles.then((list) {
        for (int i = 0; i < list.length; i++) {
          if (list[i].letter == data as String) {
            list.removeAt(i);
            break;
          }
        }
      });
      setState(() {});
    });
    removedEvent = GetIt.instance<GridService>().events.on('removed', (data) {
      letterTiles.then((list) {
        list.add(LetterTile(letter: data as String));
      });
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    receiveEaselSubscription!.cancel();
    removedEvent!.cancel();
    placedEvent!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: letterTiles,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
              child: Row(children: [
            for (var i = 0; i < snapshot.data!.length; i++)
              LongPressDraggable<LetterTile>(
                delay: widget.isObserving!
                    ? const Duration(days: 10)
                    : const Duration(milliseconds: 100),
                dragAnchorStrategy:
                    (Draggable<Object> _, BuildContext __, Offset ___) =>
                        const Offset(25, 25),
                feedback: Opacity(
                  opacity: 0.5,
                  child: Container(
                      height: 50,
                      width: 50,
                      color: Colors.greenAccent,
                      child: Center(
                        child: snapshot.data![i],
                      )),
                ),
                childWhenDragging: Container(
                    height: 75,
                    width: 75,
                    child: const SizedBox(
                      width: 75,
                    )),
                data: snapshot.data![i],
                child: GestureDetector(
                    onTap: () {
                      if (widget.isObserving!) {
                        return;
                      }
                      setState(() {
                        if (snapshot.data![i].isSelected) {
                          snapshot.data![i].isSelected = false;
                          GetIt.instance<EaselService>()
                              .tilesToChange
                              .remove(snapshot.data![i]);
                        } else {
                          snapshot.data![i].isSelected = true;
                          GetIt.instance<EaselService>()
                              .tilesToChange
                              .add(snapshot.data![i]);
                        }
                      });
                    },
                    child: Container(
                        decoration:
                            snapshot.data![i].isSelected ? selected() : null,
                        height: 75,
                        width: 75,
                        child: snapshot.data![i])),
              )
          ]));
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

selected() {
  return BoxDecoration(
    color: Color.fromARGB(255, 1, 103, 220),
    borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10)),
    boxShadow: [
      BoxShadow(
        color: Color.fromARGB(255, 68, 111, 128).withOpacity(0.5),
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3), // changes position of shadow
      ),
    ],
  );
}
