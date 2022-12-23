import 'package:client_leger/views/chat/chat_page.dart';
import 'package:client_leger/views/game-mode/game_mode_card.dart';
import 'package:flutter/material.dart';

class GameMode extends StatelessWidget {
  const GameMode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        height: 70,
        margin: const EdgeInsets.only(bottom: 20, right: 10),
        child: FloatingActionButton.extended(
          elevation: 20,
          onPressed: () {
            // Display chat wigdet
            Navigator.of(context).push(openChat());
          },
          materialTapTargetSize: MaterialTapTargetSize.padded,
          backgroundColor: const Color.fromARGB(255, 10, 114, 1),
          icon: const Icon(
            Icons.question_answer_rounded,
          ),
          label: const Text("Clavardage"),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/images/basic-bg.jpg'),
          fit: BoxFit.cover,
        )),
        child: const GameModeCard(),
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
