import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PlayerButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isTrue;

  PlayerButton({
    required this.onPressed,
    required this.isTrue,
  });

  @override
  _PlayerButtonState createState() => _PlayerButtonState();
}

class _PlayerButtonState extends State<PlayerButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        width: 50,
        height: 30,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 10,
            backgroundColor: Color.fromARGB(81, 0, 0, 0),
          ),
          onPressed: widget.onPressed,
          child: widget.isTrue ? Icon(Icons.volume_up) : Icon(Icons.volume_off),
        ),
      ),
    );
  }
}

class PlayerMusic extends StatefulWidget {
  const PlayerMusic({super.key});
  @override
  State<PlayerMusic> createState() => _PlayerMusicState();
}

class _PlayerMusicState extends State<PlayerMusic> {
  final player = AudioPlayer(playerId: 'main');
  bool isPlaying = false;

  Future<void> playHandler() async {
    setState(() {
      isPlaying = player.state == PlayerState.playing;
    });
    isPlaying ? player.pause() : player.resume();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        PlayerButton(
          onPressed: playHandler,
          isTrue: !isPlaying,
        ),
      ],
    );
  }
}
