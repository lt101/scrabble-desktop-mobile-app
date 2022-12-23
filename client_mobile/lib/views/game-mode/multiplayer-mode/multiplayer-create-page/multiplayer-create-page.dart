import 'package:client_leger/services/chat/chat_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/views/chat/chat_floater.dart';
import 'package:client_leger/views/chat/chat_page.dart';
import 'package:client_leger/views/game-mode/multiplayer-mode/multiplayer-create-page/multiplayer-create-card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

class MultiPlayerCreatePage extends StatefulWidget {
  const MultiPlayerCreatePage({super.key});

  @override
  State<MultiPlayerCreatePage> createState() => _MultiPlayerCreatePageState();
}

class _MultiPlayerCreatePageState extends State<MultiPlayerCreatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ),
        ),
        child: const SingleChildScrollView(
            reverse: true, child: MultiPlayerCreateCard()),
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
