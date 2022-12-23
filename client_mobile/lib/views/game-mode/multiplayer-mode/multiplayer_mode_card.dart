import 'package:client_leger/constants/routes.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/views/game-mode/scrabble_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

class MultiplayerModeCard extends StatelessWidget {
  const MultiplayerModeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: GetIt.instance<SettingService>().isLightMode
            ? Colors.white
            : Color(0xff1c2541),
        elevation: 50.00,
        child: SizedBox(
          width: 500,
          height: 460,
          child: Column(
            children: [
              const SizedBox(height: 30),
              const ScrabbleLogoImage(),
              SizedBox(
                height: 20,
              ),
              Text(
                AppLocalizations.of(context)!.modeMulti,
                style: TextStyle(
                    fontSize: 20,
                    color: GetIt.instance<SettingService>().isLightMode
                        ? Colors.black
                        : Colors.white),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(300, 50),
                        backgroundColor: Colors.green[800]),
                    onPressed: () => Navigator.pushNamed(
                        context, multiPlayerCreatePageRoute),
                    child: Text(AppLocalizations.of(context)!.createGame)),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(fixedSize: Size(300, 50)),
                    onPressed: () {
                      Navigator.pushNamed(context, multiPlayerJoinPageRoute);
                    },
                    child: Text(AppLocalizations.of(context)!.joinGame)),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
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
                      Navigator.popAndPushNamed(context, mainMenuRoute),
                  child: Text(AppLocalizations.of(context)!.back)),
            ],
          ),
        ),
      ),
    );
  }
}
