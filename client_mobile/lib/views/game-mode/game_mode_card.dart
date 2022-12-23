import 'package:client_leger/views/game-mode/scrabble_logo.dart';
import 'package:flutter/material.dart';
import 'package:client_leger/constants/routes.dart';

class GameModeCard extends StatelessWidget {
  const GameModeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 50.00,
        child: SizedBox(
          width: 500,
          height: 460,
          child: Column(
            children: [
              const SizedBox(height: 30),
              const ScrabbleLogoImage(),
              const Text(
                'Scrabble classique',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 90),
              const SizedBox(
                width: 250,
                child: ElevatedButton(
                    onPressed: null, child: Text('Jouer une partie en solo')),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        // If the button is pressed, return green, otherwise blue
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.blue;
                        }
                        return Colors.green[900];
                      }),
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, multiPlayerModeRoute),
                    child: Text('Jouer une partie en multijoueur')),
              ),
              const SizedBox(height: 50),
              const ElevatedButton(onPressed: null, child: Text('Retour')),
            ],
          ),
        ),
      ),
    );
  }
}
