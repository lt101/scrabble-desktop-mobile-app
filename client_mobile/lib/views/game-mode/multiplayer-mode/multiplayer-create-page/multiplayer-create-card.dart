import 'package:client_leger/constants/routes.dart';
import 'package:client_leger/services/game/game_mode_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/user-info/user_info_service.dart';
import 'package:client_leger/views/game-mode/multiplayer-mode/multiplayer-create-page/multiplayer_create_game_service.dart';
import 'package:client_leger/views/game-mode/multiplayer-mode/multiplayer-create-page/waiting-players/waiting_players.dart';
import 'package:client_leger/views/game-mode/scrabble_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

class MultiPlayerCreateCard extends StatefulWidget {
  const MultiPlayerCreateCard({super.key});

  @override
  State<MultiPlayerCreateCard> createState() => _MultiPlayerCreateCardState();
}

class _MultiPlayerCreateCardState extends State<MultiPlayerCreateCard> {
  MultiplayerCreateGameService multiplayerCreateService =
      MultiplayerCreateGameService();
  UserInfoService userInfoService = UserInfoService();
  bool confirm = false;
  bool confirmParameters = true;
  final _currentNameController = TextEditingController();
  String _dropdownTimerValue = MultiplayerCreateGameService.timerList[1];
  String _dropdownDictionaryValue =
      MultiplayerCreateGameService.dictionaryList[0];
  String _visibility = MultiplayerCreateGameService.visibilities[1];
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentNameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _currentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
            color: GetIt.instance<SettingService>().isLightMode
                ? Colors.white
                : const Color(0xff1c2541),
            elevation: 50.00,
            child: SizedBox(
              width: 600,
              height: 630,
              child: Column(children: [
                const SizedBox(height: 30),
                const ScrabbleLogoImage(),
                Text(
                  AppLocalizations.of(context)!.createMultiGame,
                  style: TextStyle(
                      fontSize: 20,
                      color: GetIt.instance<SettingService>().isLightMode
                          ? Colors.black
                          : Colors.white),
                ),
                const SizedBox(height: 20),
                // Timer drop down
                SizedBox(
                  width: 550,
                  child: DropdownButtonFormField<String>(
                    dropdownColor: GetIt.instance<SettingService>().isLightMode
                        ? Colors.white
                        : Color(0xff3a506b),
                    isExpanded: true,
                    hint: Text(
                      AppLocalizations.of(context)!.timer,
                      style: TextStyle(
                          color: GetIt.instance<SettingService>().isLightMode
                              ? Colors.black
                              : Colors.white),
                    ),
                    menuMaxHeight: 200,
                    items: MultiplayerCreateGameService.timerList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                              color:
                                  GetIt.instance<SettingService>().isLightMode
                                      ? Colors.black
                                      : Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _dropdownTimerValue = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 550,
                  child: GetIt.instance<GameModeService>().isObjectiveMode
                      ? const SizedBox()
                      : DropdownButtonFormField<String>(
                          dropdownColor:
                              GetIt.instance<SettingService>().isLightMode
                                  ? Colors.white
                                  : Color(0xff3a506b),
                          isExpanded: true,
                          hint: Text(
                            AppLocalizations.of(context)!.visibility,
                            style: TextStyle(
                                color:
                                    GetIt.instance<SettingService>().isLightMode
                                        ? Colors.black
                                        : Colors.white),
                          ),
                          menuMaxHeight: 200,
                          items: MultiplayerCreateGameService.visibilities
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                    color: GetIt.instance<SettingService>()
                                            .isLightMode
                                        ? Colors.black
                                        : Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _visibility = value!;
                            });
                          },
                        ),
                ),
                SizedBox(
                  width: 550,
                  child: (_visibility.contains('Publique') ||
                              _visibility.contains('Public')) &&
                          !GetIt.instance<GameModeService>().isObjectiveMode
                      ? TextFormField(
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            labelText:
                                AppLocalizations.of(context)!.passwordOptional,
                            labelStyle: TextStyle(
                                color:
                                    GetIt.instance<SettingService>().isLightMode
                                        ? Colors.black
                                        : Colors.white),
                          ),
                          controller: _passwordController,
                        )
                      : const Text(''),
                ),
                // Dictionary
                const SizedBox(height: 20),
                SizedBox(
                  width: 550,
                  child: DropdownButtonFormField<String>(
                    dropdownColor: GetIt.instance<SettingService>().isLightMode
                        ? Colors.white
                        : Color(0xff3a506b),
                    isExpanded: true,
                    menuMaxHeight: 200,
                    hint: Text(
                      AppLocalizations.of(context)!.dictionnary,
                      style: TextStyle(
                          color: GetIt.instance<SettingService>().isLightMode
                              ? Colors.black
                              : Colors.white),
                    ),
                    items: MultiplayerCreateGameService.dictionaryList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _dropdownDictionaryValue = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Retour
                    const SizedBox(width: 40),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.blue;
                              }
                              return Colors.green[900];
                            }),
                          ),
                          onPressed: () {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);

                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            Navigator.pushNamed(context, multiPlayerModeRoute);
                          },
                          child: Text(AppLocalizations.of(context)!.back)),
                    ),
                    // Confirmer les paramètres
                    const SizedBox(width: 100),
                    SizedBox(
                      height: 50,
                      width: 200,
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (confirmParameters) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.blue;
                                }
                                return Colors.green[900];
                              }
                            }),
                          ),
                          onPressed: () {
                            if (GetIt.instance<GameModeService>()
                                .isObjectiveMode) _visibility = 'Privée';

                            multiplayerCreateService.createGame(
                                userInfoService.userprofile.userName,
                                _dropdownDictionaryValue,
                                _dropdownTimerValue,
                                _visibility,
                                _passwordController.text);
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      WaitingPlayers(
                                    isHost: true,
                                    visibility: _visibility,
                                  ),
                                ),
                                (route) => true);
                          },
                          child:
                              Text(AppLocalizations.of(context)!.createGame)),
                    ),
                    const SizedBox(width: 10),
                  ],
                )
              ]),
            )));
  }
}
