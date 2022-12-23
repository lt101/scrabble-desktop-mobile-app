import 'package:client_leger/constants/routes.dart';
import 'package:client_leger/services/chat/chat_service.dart';
import 'package:client_leger/services/game/game_mode_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/views/chat/chat_floater.dart';
import 'package:client_leger/views/chat/chat_page.dart';
import 'package:client_leger/views/game-mode/multiplayer-mode/multiplayer_mode_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

class MultiPlayerMode extends StatefulWidget {
  const MultiPlayerMode({super.key});

  @override
  State<MultiPlayerMode> createState() => _MultiPlayerModeState();
}

class _MultiPlayerModeState extends State<MultiPlayerMode> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(mainMenuRoute, (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: GetIt.instance<GameModeService>().isObjectiveMode
              ? Text(AppLocalizations.of(context)!.objectiveScrabble)
              : Text(AppLocalizations.of(context)!.classicScrabble),
          backgroundColor: GetIt.instance<SettingService>().isLightMode
              ? GetIt.instance<GameModeService>().isObjectiveMode
                  ? Color.fromARGB(255, 58, 29, 108)
                  : Color.fromARGB(255, 24, 103, 26)
              : Color(0xff0b132b),
        ),
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
          child: const MultiplayerModeCard(),
        ),
      ),
    );
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
