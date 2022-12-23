import 'dart:async';
import 'dart:math';

import 'package:client_leger/classes/RoomInformations.dart';
import 'package:client_leger/constants/routes.dart';
import 'package:client_leger/services/game/game_mode_service.dart';
import 'package:client_leger/services/game/game_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/sockets/game_room_socket/game_room_socket_service.dart';
import 'package:client_leger/services/user-info/user_info_service.dart';
import 'package:client_leger/views/game-mode/multiplayer-mode/multiplayer-create-page/waiting-players/waiting_players.dart';
import 'package:client_leger/views/game-mode/scrabble_logo.dart';
import 'package:client_leger/views/game/game_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

//
class MultiPlayerJoinCard extends StatefulWidget {
  const MultiPlayerJoinCard({super.key});

  @override
  State<MultiPlayerJoinCard> createState() => _MultiPlayerJoinCardState();
}

class _MultiPlayerJoinCardState extends State<MultiPlayerJoinCard> {
  UserInfoService userInfoService = UserInfoService();
  GameRoomSocketService gameRoomSocketService = GameRoomSocketService();
  StreamSubscription<List<RoomInformations>>? streamSubscription;
  StreamSubscription<List<RoomInformations>>? objectiveStreamSubscription;
  StreamSubscription<List<RoomInformations>>? observableGameSub;
  List<RoomInformations> roomPrivateList_ = [];
  List<RoomInformations> roomPubicList_ = [];
  List<RoomInformations> observablesList_ = [];
  final _password = TextEditingController();
  var _formKeyPassword = GlobalKey<FormState>();

  @override
  void initState() {
    if (GetIt.instance<GameModeService>().gameMode == 'classic') {
      streamSubscription =
          gameRoomSocketService.roomListController.stream.listen((roomList) {
        setSubscription(roomList);
      });
    } else if (GetIt.instance<GameModeService>().gameMode == 'log2990') {
      objectiveStreamSubscription =
          gameRoomSocketService.objRoomListController.stream.listen((roomList) {
        setSubscription(roomList);
      });
    }

    observableGameSub =
        gameRoomSocketService.observableListController.stream.listen((obsList) {
      setState(() {
        observablesList_ = obsList;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    observableGameSub!.cancel();
    streamSubscription?.cancel();
    objectiveStreamSubscription?.cancel();
  }

  void setSubscription(List<RoomInformations> roomList) {
    setState(() {
      roomPubicList_.clear();
      roomPrivateList_.clear();
      for (var room in roomList) {
        if (room.parameters?.visibility == 'public') {
          if (!roomPubicList_.contains(room)) {
            roomPubicList_.add(room);
          }
        } else if (!roomPrivateList_.contains(room)) {
          roomPrivateList_.add(room);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        //0b132b
        color: GetIt.instance<SettingService>().isLightMode
            ? Colors.white
            : Color(0xff0b132b),
        elevation: 50.00,
        child: SizedBox(
          width: 800,
          height: 730,
          child: Column(
            children: [
              const SizedBox(height: 30),
              const ScrabbleLogoImage(),
              Text(
                AppLocalizations.of(context)!.joinMultiGame,
                style: TextStyle(
                    fontSize: 20,
                    color: GetIt.instance<SettingService>().isLightMode
                        ? Colors.black
                        : Colors.white),
              ),
              const SizedBox(height: 20),
              Card(
                color: GetIt.instance<SettingService>().isLightMode
                    ? Colors.white
                    : Color(0xff1c2541),
                elevation: 50.00,
                shadowColor: Colors.black,
                child: Column(
                  children: [
                    SizedBox(
                      width: 750,
                      height: 200,
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.privateGames,
                            style: TextStyle(
                                color:
                                    GetIt.instance<SettingService>().isLightMode
                                        ? Colors.black
                                        : Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: 100,
                                  child: Center(
                                      child: Text(
                                    AppLocalizations.of(context)!.host,
                                    style: TextStyle(
                                        color: GetIt.instance<SettingService>()
                                                .isLightMode
                                            ? Colors.black
                                            : Colors.white),
                                  ))),
                              Text(
                                AppLocalizations.of(context)!.timer,
                                style: TextStyle(
                                    color: GetIt.instance<SettingService>()
                                            .isLightMode
                                        ? Colors.black
                                        : Colors.white),
                              ),
                              Text(
                                AppLocalizations.of(context)!.dictionnary,
                                style: TextStyle(
                                    color: GetIt.instance<SettingService>()
                                            .isLightMode
                                        ? Colors.black
                                        : Colors.white),
                              ),
                              SizedBox(
                                  width: 100,
                                  child: Text(
                                    AppLocalizations.of(context)!.action,
                                    style: TextStyle(
                                        color: GetIt.instance<SettingService>()
                                                .isLightMode
                                            ? Colors.black
                                            : Colors.white),
                                  )),
                              SizedBox(
                                  width: 200,
                                  child: Text(
                                    AppLocalizations.of(context)!.players,
                                    style: TextStyle(
                                        color: GetIt.instance<SettingService>()
                                                .isLightMode
                                            ? Colors.black
                                            : Colors.white),
                                  )),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                              child: ListView.builder(
                            itemCount: roomPrivateList_.length, // List lenght
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(
                                      height: 20,
                                      thickness: 1,
                                      color: Colors.black,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            width: 100,
                                            child: Center(
                                                child: Text(
                                                    roomPrivateList_[index]
                                                        .hostName!,
                                                    style: TextStyle(
                                                        color: GetIt.instance<
                                                                    SettingService>()
                                                                .isLightMode
                                                            ? Colors.black
                                                            : Colors.white)))),
                                        Text(
                                          roomPrivateList_[index]
                                              .parameters!
                                              .timer
                                              .toString(),
                                          style: TextStyle(
                                              color: GetIt.instance<
                                                          SettingService>()
                                                      .isLightMode
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                        Text(
                                          roomPrivateList_[index]
                                              .parameters!
                                              .dictionary!,
                                          style: TextStyle(
                                              color: GetIt.instance<
                                                          SettingService>()
                                                      .isLightMode
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                        SizedBox(
                                            width: 100,
                                            child: ElevatedButton(
                                                onPressed: () =>
                                                    joinRoom(index, false),
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .join))),
                                        SizedBox(
                                            width: 200,
                                            child: Text(
                                              roomPrivateList_[index]
                                                  .playersName_
                                                  .toString(),
                                              style: TextStyle(
                                                  color: GetIt.instance<
                                                              SettingService>()
                                                          .isLightMode
                                                      ? Colors.black
                                                      : Colors.white),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          )),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 750,
                      height: 300,
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.publicGames,
                            style: TextStyle(
                                color:
                                    GetIt.instance<SettingService>().isLightMode
                                        ? Colors.black
                                        : Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: 100,
                                  child: Center(
                                      child: Text(
                                    AppLocalizations.of(context)!.host,
                                    style: TextStyle(
                                        color: GetIt.instance<SettingService>()
                                                .isLightMode
                                            ? Colors.black
                                            : Colors.white),
                                  ))),
                              Text(
                                AppLocalizations.of(context)!.timer,
                                style: TextStyle(
                                    color: GetIt.instance<SettingService>()
                                            .isLightMode
                                        ? Colors.black
                                        : Colors.white),
                              ),
                              Text(
                                AppLocalizations.of(context)!.dictionnary,
                                style: TextStyle(
                                    color: GetIt.instance<SettingService>()
                                            .isLightMode
                                        ? Colors.black
                                        : Colors.white),
                              ),
                              SizedBox(
                                  width: 100,
                                  child: Text(
                                    AppLocalizations.of(context)!.action,
                                    style: TextStyle(
                                        color: GetIt.instance<SettingService>()
                                                .isLightMode
                                            ? Colors.black
                                            : Colors.white),
                                  )),
                              SizedBox(
                                  width: 200,
                                  child: Text(
                                    AppLocalizations.of(context)!.players,
                                    style: TextStyle(
                                        color: GetIt.instance<SettingService>()
                                                .isLightMode
                                            ? Colors.black
                                            : Colors.white),
                                  )),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                              child: ListView.builder(
                            itemCount: roomPubicList_.length, // List lenght
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(
                                      height: 20,
                                      thickness: 1,
                                      color: Colors.black,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            width: 100,
                                            child: Center(
                                                child: Text(
                                                    roomPubicList_[index]
                                                        .hostName!))),
                                        Text(
                                          roomPubicList_[index]
                                              .parameters!
                                              .timer
                                              .toString(),
                                          style: TextStyle(
                                              color: GetIt.instance<
                                                          SettingService>()
                                                      .isLightMode
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                        Text(
                                          roomPubicList_[index]
                                              .parameters!
                                              .dictionary!,
                                          style: TextStyle(
                                              color: GetIt.instance<
                                                          SettingService>()
                                                      .isLightMode
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                        SizedBox(
                                            width: 100,
                                            child: ElevatedButton(
                                                onPressed: () =>
                                                    joinRoom(index, true),
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .join))),
                                        SizedBox(
                                            width: 200,
                                            child: Text(
                                              roomPubicList_[index]
                                                  .playersName_
                                                  .toString(),
                                              style: TextStyle(
                                                  color: GetIt.instance<
                                                              SettingService>()
                                                          .isLightMode
                                                      ? Colors.black
                                                      : Colors.white),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          )),
                          Expanded(
                              child: ListView.builder(
                            itemCount: observablesList_.length, // List lenght
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(
                                      height: 20,
                                      thickness: 1,
                                      color: Colors.black,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            width: 100,
                                            child: Center(
                                                child: Text(
                                              observablesList_[index].hostName!,
                                              style: TextStyle(
                                                  color: GetIt.instance<
                                                              SettingService>()
                                                          .isLightMode
                                                      ? Colors.black
                                                      : Colors.white),
                                            ))),
                                        Text(
                                          observablesList_[index]
                                              .parameters!
                                              .timer
                                              .toString(),
                                          style: TextStyle(
                                              color: GetIt.instance<
                                                          SettingService>()
                                                      .isLightMode
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                        Text(
                                          observablesList_[index]
                                              .parameters!
                                              .dictionary!,
                                          style: TextStyle(
                                              color: GetIt.instance<
                                                          SettingService>()
                                                      .isLightMode
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                        SizedBox(
                                            width: 100,
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  if (observablesList_[index]
                                                      .parameters!
                                                      .password
                                                      .isNotEmpty) {
                                                    joinObservablePassword(
                                                        index);
                                                  } else {
                                                    gameRoomSocketService
                                                        .observeRoom(
                                                            observablesList_[
                                                                    index]
                                                                .id!,
                                                            userInfoService
                                                                .userprofile
                                                                .userName);
                                                    GetIt.instance<
                                                                GameService>()
                                                            .gameId =
                                                        observablesList_[index]
                                                            .id!;
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              GameView(
                                                                isObserving:
                                                                    true,
                                                              )),
                                                    );
                                                  }
                                                },
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .observe))),
                                        SizedBox(
                                            width: 200,
                                            child: Text(
                                              observablesList_[index]
                                                  .playersName_
                                                  .toString(),
                                              style: TextStyle(
                                                  color: GetIt.instance<
                                                              SettingService>()
                                                          .isLightMode
                                                      ? Colors.black
                                                      : Colors.white),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 50,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff3a506b)),
                      onPressed: () {
                        Navigator.pushNamed(context, multiPlayerModeRoute);
                      },
                      child: Text(AppLocalizations.of(context)!.back)),
                  const SizedBox(
                    width: 100,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff3a506b)),
                      onPressed: () => joinRandomRoom(),
                      child: Text(AppLocalizations.of(context)!.selectRandom)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void joinRandomRoom() {
    if (roomPrivateList_.isEmpty) return;
    int index = Random().nextInt(roomPrivateList_.length - 1);
    joinRoom(index, false);
  }

  void joinRoom(int index, bool isPublic) async {
    if (isPublic) {
      if (roomPubicList_[index].parameters!.password.isNotEmpty) {
        joinPasswordRoom(index);
        return;
      } else {
        await userInfoService.getCurrentUser().then((value) {
          gameRoomSocketService.joinRoom(
              value.userName,
              gameRoomSocketService.socketService.socket!.id!,
              roomPubicList_[index].id!);
        });
      }
    } else {
      await userInfoService.getCurrentUser().then((value) {
        gameRoomSocketService.joinRoom(
            value.userName,
            gameRoomSocketService.socketService.socket!.id!,
            roomPrivateList_[index].id!);
      });
    }
    if (!mounted) {
      return;
    }
    // Add names to sidebar
    if (roomPrivateList_.isNotEmpty && !isPublic) {
      var info = roomPrivateList_[index];
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => WaitingPlayers(
              isHost: false,
              roomInfo: info,
              visibility: 'Privée',
            ),
          ),
          (route) => true);
    } else if (roomPubicList_.isNotEmpty && isPublic) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => WaitingPlayers(
              isHost: false,
              roomInfo: roomPubicList_[index],
              visibility: 'Publique',
            ),
          ),
          (route) => true);
    }
  }

  joinPasswordRoom(int index) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.enterPassword,
            style: TextStyle(
                color: GetIt.instance<SettingService>().isLightMode
                    ? Colors.black
                    : Colors.white),
          ),
          content: Form(
            key: _formKeyPassword,
            child: TextFormField(
              validator: (value) {
                if (value != roomPubicList_[index].parameters!.password) {
                  return AppLocalizations.of(context)!.wrongPassword;
                } else {
                  return null;
                }
              },
              controller: _password,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password,
                labelStyle: TextStyle(
                    color: GetIt.instance<SettingService>().isLightMode
                        ? Colors.black
                        : Colors.white),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                _password.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(AppLocalizations.of(context)!.join),
              onPressed: () async {
                if (!_formKeyPassword.currentState!.validate()) return;
                await userInfoService.getCurrentUser().then((value) {
                  gameRoomSocketService.joinRoom(
                      value.userName,
                      gameRoomSocketService.socketService.socket!.id!,
                      roomPubicList_[index].id!);
                });
                FocusScopeNode currentFocus = FocusScope.of(context);

                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (BuildContext context) => WaitingPlayers(
                        isHost: false,
                        roomInfo: roomPubicList_[index],
                        visibility: 'Publique',
                      ),
                    ),
                    (route) => true);
              },
            ),
          ],
        );
      },
    );
  }

  joinObservablePassword(int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.enterPassword,
            style: TextStyle(
                color: GetIt.instance<SettingService>().isLightMode
                    ? Colors.black
                    : Colors.white),
          ),
          content: Form(
            key: _formKeyPassword,
            child: TextFormField(
              validator: ((value) {
                if (value != observablesList_[index].parameters!.password) {
                  return AppLocalizations.of(context)!.wrongPassword;
                } else {
                  return null;
                }
              }),
              controller: _password,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password,
                labelStyle: TextStyle(
                    color: GetIt.instance<SettingService>().isLightMode
                        ? Colors.black
                        : Colors.white),
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                _password.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(AppLocalizations.of(context)!.join),
              onPressed: () async {
                if (!_formKeyPassword.currentState!.validate()) return;
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                gameRoomSocketService.observeRoom(observablesList_[index].id!,
                    userInfoService.userprofile.userName);
                GetIt.instance<GameService>().gameId =
                    observablesList_[index].id!;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GameView(
                            isObserving: true,
                          )),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
