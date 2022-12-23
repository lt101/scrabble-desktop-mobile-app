// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:ui';

import 'package:animated_background/animated_background.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:client_leger/classes/user_profil.dart';
import 'package:client_leger/constants/routes.dart';
import 'package:client_leger/provider/locale_provider.dart';
import 'package:client_leger/services/auth/sign_in_service.dart';
import 'package:client_leger/services/chat/chat_service.dart';
import 'package:client_leger/services/game/game_mode_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/sockets/chat-socket/chat_socket_service.dart';
import 'package:client_leger/services/user-info/avatar_service.dart';
import 'package:client_leger/services/user-info/user_info_service.dart';
import 'package:client_leger/views/auth/avatar_option_view.dart';
import 'package:client_leger/views/chat/chat_floater.dart';
import 'package:client_leger/views/chat/chat_page.dart';
import 'package:client_leger/views/menu/game_history.dart';
import 'package:client_leger/views/menu/login_history.dart';
import 'package:client_leger/views/music/music.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//
class MainMenu extends StatefulWidget {
  const MainMenu({super.key});
  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey();
  SignInService signInService = SignInService();
  UserInfoService userInfoService = UserInfoService();
  AvatarService avatarService = AvatarService();
  AudioPlayer? audio;
  late StreamSubscription eventsSub;
  late Future<UserProfile> _user;

  @override
  void initState() {
    audio = AudioPlayer(playerId: 'main');
    audio!.setReleaseMode(ReleaseMode.loop);
    audio?.setVolume(10);
    _user = userInfoService.getCurrentUser().then((value) {
      initSocket(value);
      return value;
    });
    initPreferences();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initSocket(UserProfile user) async {
    await _user;
    if (GetIt.instance<SettingService>().isSocketInit) return;
    GetIt.instance<ChatSocketService>().chatSocketListener(user);
    GetIt.instance<SettingService>().socketIsInit();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: _user,
      builder: (context, snapshot) {
        bool isConnected = false;
        SessionManager()
            .containsKey('currentUser')
            .then((value) => isConnected = value);
        if (snapshot.hasData) {
          return menuWidget();
        } else {
          return const Center(
            child: SizedBox(),
          );
        }
      },
    );
  }

  initPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await userInfoService.getUserPreferences();
    GetIt.instance<SettingService>()
        .setBoardSkin(prefs.getString('skin') ?? 'default');
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    provider.setLocale(Locale(GetIt.instance<SettingService>().language_));
  }

  Widget menuWidget() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _keyScaffold,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
      ),
      drawer: Drawer(
        backgroundColor: GetIt.instance<SettingService>().isLightMode
            ? const Color.fromARGB(255, 255, 255, 255)
            : Color(0xff0b132b),
        width: 400,
        child: drawerChild(userInfoService.userprofile),
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: GetIt.instance<SettingService>().isLightMode
                ? AssetImage("assets/images/bg.jpg")
                : AssetImage("assets/images/dark-theme.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        /* 
        ParticleOptions(
                  spawnMaxRadius: 40,
                  spawnMinSpeed: 65.00,
                  particleCount: 10,
                  spawnMaxSpeed: 100,
                  minOpacity: 0.3,
                  maxOpacity: 0.5,
                  spawnOpacity: 0.3,
                  image: Image(image: AssetImage('assets/images/letter.png')))
         */
        child: AnimatedBackground(
          vsync: this,
          behaviour: EmptyBehaviour(),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    padding: const EdgeInsets.only(top: 40, left: 70),
                    iconSize: 120,
                    splashColor: const Color.fromARGB(181, 2, 119, 41),
                    splashRadius: 100,
                    icon: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                color: Color.fromARGB(255, 0, 24, 0),
                                width: 8,
                              ),
                            ),
                            child: Image.network(
                                userInfoService.userprofile.avatarUrl!))),
                    onPressed: () {
                      _keyScaffold.currentState!.openDrawer();
                    },
                  ),
                  const SizedBox(
                    width: 0,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        color: Color.fromARGB(255, 0, 24, 0)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 15),
                    child: Text(
                      userInfoService.userprofile.userName,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 24,
                        backgroundColor: Color.fromARGB(255, 0, 24, 0),
                      ),
                    ),
                  ),
                  const Spacer(),
                  PlayerMusic(),
                  IconButton(
                    padding: const EdgeInsets.all(35),
                    iconSize: 80,
                    icon: const Icon(
                      Icons.settings,
                      color: Color.fromARGB(255, 121, 121, 121),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, StateSetter set) => Container(
                              width: 500,
                              child: Dialog(
                                backgroundColor:
                                    GetIt.instance<SettingService>().isLightMode
                                        ? Color.fromARGB(255, 255, 255, 255)
                                        : Color(0xff1c2541),
                                insetPadding: EdgeInsets.only(
                                    top: 150,
                                    bottom: 280,
                                    left: 400,
                                    right: 400),
                                child: Column(children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.settings,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: GetIt.instance<SettingService>()
                                                .isLightMode
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.theme,
                                        style: TextStyle(
                                            color:
                                                GetIt.instance<SettingService>()
                                                        .isLightMode
                                                    ? Colors.black
                                                    : Colors.white),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        width: 100,
                                        height: 60,
                                        child: DayNightSwitcher(
                                          nightBackgroundColor:
                                              Color.fromARGB(255, 28, 28, 28),
                                          isDarkModeEnabled:
                                              !GetIt.instance<SettingService>()
                                                  .isLightMode,
                                          onStateChanged: (isDarkModeEnabled) {
                                            setState(() {
                                              GetIt.instance<SettingService>()
                                                  .switchTheme();
                                              userInfoService.updatePrefTheme();
                                            });
                                            set(
                                              () {},
                                            );
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  Divider(
                                    color: Color.fromARGB(255, 99, 99, 99),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .gameSkin,
                                          style: TextStyle(
                                              color: GetIt.instance<
                                                          SettingService>()
                                                      .isLightMode
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            181, 2, 119, 41)),
                                                onPressed: () {
                                                  GetIt.instance<
                                                          SettingService>()
                                                      .setBoardSkin('default');
                                                  SharedPreferences
                                                          .getInstance()
                                                      .then((instance) =>
                                                          instance.setString(
                                                              'skin',
                                                              'default'));
                                                },
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .defau)),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    surfaceTintColor:
                                                        Colors.brown,
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 49, 30, 0)),
                                                onPressed: () async {
                                                  GetIt.instance<
                                                          SettingService>()
                                                      .setBoardSkin('wood');

                                                  SharedPreferences
                                                          .getInstance()
                                                      .then((instance) =>
                                                          instance.setString(
                                                              'skin', 'wood'));
                                                },
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .wood)),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 85, 84, 83)),
                                                onPressed: () {
                                                  GetIt.instance<
                                                          SettingService>()
                                                      .setBoardSkin('metal');
                                                  SharedPreferences
                                                          .getInstance()
                                                      .then((instance) =>
                                                          instance.setString(
                                                              'skin', 'metal'));
                                                },
                                                child: Text('Metal'))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Divider(
                                    color: Color.fromARGB(255, 99, 99, 99),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .languageTitle,
                                        style: TextStyle(
                                            color:
                                                GetIt.instance<SettingService>()
                                                        .isLightMode
                                                    ? Colors.black
                                                    : Colors.white),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      DropdownButton(
                                        iconSize: 40,
                                        hint: Text(
                                          AppLocalizations.of(context)!
                                              .language,
                                          style: TextStyle(
                                              color: GetIt.instance<
                                                          SettingService>()
                                                      .isLightMode
                                                  ? Colors.black
                                                  : Colors.white),
                                        ),
                                        alignment: AlignmentDirectional.center,
                                        items: [
                                          DropdownMenuItem(
                                            onTap: () async {
                                              final provider =
                                                  Provider.of<LocaleProvider>(
                                                      context,
                                                      listen: false);

                                              provider.setLocale(Locale('fr'));
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setString('language', 'fr');
                                              userInfoService
                                                  .updatePregLanguage('fr');
                                            },
                                            alignment:
                                                AlignmentDirectional.center,
                                            value: 'fr',
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .french),
                                          ),
                                          DropdownMenuItem(
                                            onTap: () async {
                                              final provider =
                                                  Provider.of<LocaleProvider>(
                                                      context,
                                                      listen: false);
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setString('language', 'en');
                                              provider.setLocale(Locale('en'));
                                              userInfoService
                                                  .updatePregLanguage('en');
                                            },
                                            alignment:
                                                AlignmentDirectional.center,
                                            value: 'en',
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .english),
                                          )
                                        ],
                                        onChanged: (_) {},
                                      )
                                    ],
                                  )
                                ]),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
              const SizedBox(
                height: 80,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 0),
                width: window.physicalSize.width,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      color: Color.fromARGB(0, 0, 0, 0),
                      width: 1300,
                      child: GetIt.instance<SettingService>().isLightMode
                          ? Image.asset(
                              'assets/images/scrabble-logo-client-web.png',
                              height: 130,
                            )
                          : Image.asset(
                              'assets/images/white-logo.png',
                              height: 100,
                            ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    /*
                     GetIt.instance<GameModeService>().setGameModeToClassic();
                        Navigator.of(context).pushNamed(multiPlayerModeRoute);
              
                         GetIt.instance<GameModeService>()
                            .setGameModeToObjectives();
                        Navigator.of(context).pushNamed(multiPlayerModeRoute);
                     */
                    ElevatedButton(
                      onPressed: () {
                        GetIt.instance<GameModeService>()
                            .setGameModeToClassic();
                        Navigator.of(context).pushNamed(multiPlayerModeRoute);
                      },
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 4, // thickness
                                  color: Colors.white // color
                                  ),
                              borderRadius: BorderRadius.circular(40))),
                      child: Ink(
                        decoration: BoxDecoration(
                            gradient:
                                GetIt.instance<SettingService>().isLightMode
                                    ? const LinearGradient(colors: [
                                        Color.fromARGB(255, 10, 126, 20),
                                        Color.fromARGB(255, 15, 177, 23)
                                      ])
                                    : const LinearGradient(colors: [
                                        Color.fromARGB(255, 2, 16, 57),
                                        Color.fromARGB(255, 0, 0, 0)
                                      ]),
                            borderRadius: BorderRadius.circular(40)),
                        child: Container(
                          width: 320,
                          height: 90,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sports_esports_rounded,
                                size: 40,
                              ),
                              Text(
                                AppLocalizations.of(context)!.classicScrabble,
                                style: TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        GetIt.instance<GameModeService>()
                            .setGameModeToObjectives();
                        Navigator.of(context).pushNamed(multiPlayerModeRoute);
                      },
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 4, // thickness
                                  color: Colors.white // color
                                  ),
                              borderRadius: BorderRadius.circular(40))),
                      child: Ink(
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Color.fromARGB(255, 49, 5, 68),
                              Color.fromARGB(255, 118, 12, 137)
                            ]),
                            borderRadius: BorderRadius.circular(40)),
                        child: Container(
                          width: 320,
                          height: 90,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.checklist_rtl_rounded,
                                size: 40,
                              ),
                              Text(
                                AppLocalizations.of(context)!.objectiveScrabble,
                                style: TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerChild(UserProfile userProfile) {
    final textController = TextEditingController();
    String nameChangeStatus = "";
    const double containerHeight = 30;
    const double buttonWidth = 300;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 50, bottom: 30),
          child: Text(
            userProfile.userName,
            style: TextStyle(
                fontSize: 30,
                color: GetIt.instance<SettingService>().isLightMode
                    ? Colors.black
                    : Colors.white),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: Image.network(
              userProfile.avatarUrl!,
              width: 175,
              height: 175,
            ),
          ),
        ),
        Container(
          height: containerHeight,
          child: ListTile(
            leading: Icon(
              Icons.keyboard_double_arrow_up_rounded,
              color: GetIt.instance<SettingService>().isLightMode
                  ? Colors.black
                  : Colors.white,
            ),
            title: Text(
              "${AppLocalizations.of(context)!.rank}: ${userProfile.grade}",
              style: TextStyle(
                  color: GetIt.instance<SettingService>().isLightMode
                      ? Colors.black
                      : Colors.white),
            ),
            dense: true,
          ),
        ),
        Container(
          height: containerHeight,
          child: ListTile(
            leading: Icon(
              Icons.grade,
              color: GetIt.instance<SettingService>().isLightMode
                  ? Colors.black
                  : Colors.white,
            ),
            title: Text(
              "${AppLocalizations.of(context)!.level}: ${userProfile.level}",
              style: TextStyle(
                  color: GetIt.instance<SettingService>().isLightMode
                      ? Colors.black
                      : Colors.white),
            ),
            dense: true,
          ),
        ),
        Container(
          height: containerHeight,
          child: ListTile(
            leading: Icon(
              Icons.gamepad,
              color: GetIt.instance<SettingService>().isLightMode
                  ? Colors.black
                  : Colors.white,
            ),
            title: Text(
              "${AppLocalizations.of(context)!.gamePlayed}: ${userProfile.gamePlayed}",
              style: TextStyle(
                  color: GetIt.instance<SettingService>().isLightMode
                      ? Colors.black
                      : Colors.white),
            ),
            dense: true,
          ),
        ),
        Container(
          height: containerHeight,
          child: ListTile(
            leading: Icon(
              Icons.emoji_events_rounded,
              color: GetIt.instance<SettingService>().isLightMode
                  ? Colors.black
                  : Colors.white,
            ),
            title: Text(
              "${AppLocalizations.of(context)!.gameWon}: ${userProfile.gameWon}",
              style: TextStyle(
                  color: GetIt.instance<SettingService>().isLightMode
                      ? Colors.black
                      : Colors.white),
            ),
            dense: true,
          ),
        ),
        Container(
          height: containerHeight,
          child: ListTile(
            leading: Icon(
              Icons.emoji_events_rounded,
              color: GetIt.instance<SettingService>().isLightMode
                  ? Colors.black
                  : Colors.white,
            ),
            title: Text(
              "${AppLocalizations.of(context)!.gameLost}: ${userProfile.gameLost}",
              style: TextStyle(
                  color: GetIt.instance<SettingService>().isLightMode
                      ? Colors.black
                      : Colors.white),
            ),
            dense: true,
          ),
        ),
        Container(
          height: containerHeight,
          child: ListTile(
            leading: Icon(
              Icons.analytics_rounded,
              color: GetIt.instance<SettingService>().isLightMode
                  ? Colors.black
                  : Colors.white,
            ),
            title: Text(
              "${AppLocalizations.of(context)!.pointsAverage}: ${userProfile.averagePoints}",
              style: TextStyle(
                  color: GetIt.instance<SettingService>().isLightMode
                      ? Colors.black
                      : Colors.white),
            ),
            dense: true,
          ),
        ),
        Container(
          height: containerHeight,
          child: ListTile(
            leading: Icon(
              Icons.access_time,
              color: GetIt.instance<SettingService>().isLightMode
                  ? Colors.black
                  : Colors.white,
            ),
            title: Text(
              "${AppLocalizations.of(context)!.averageTime}: ${userProfile.averageTime?.minutes} min ${userProfile.averageTime?.seconds} s",
              style: TextStyle(
                  color: GetIt.instance<SettingService>().isLightMode
                      ? Colors.black
                      : Colors.white),
            ),
            dense: true,
          ),
        ),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Container(
                    width: buttonWidth,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                GetIt.instance<SettingService>().isLightMode
                                    ? Color(0xff0e6ba8)
                                    : Color(0xff3a506b)),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Stack(
                                    children: <Widget>[
                                      Form(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .modify,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                controller: textController,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .enterUsername,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: GetIt.instance<
                                                                SettingService>()
                                                            .isLightMode
                                                        ? Color(0xff0e6ba8)
                                                        : Color(0xff3a506b)),
                                                child: Text(AppLocalizations.of(
                                                        context)!
                                                    .modify),
                                                onPressed: () {
                                                  String input =
                                                      textController.text;
                                                  userInfoService
                                                      .sendNewUsernameToServer(
                                                          userProfile
                                                                  .emailAddress
                                                              as String,
                                                          userProfile.userName,
                                                          input)
                                                      .then((value) {
                                                    if (value.body !=
                                                        'Forbidden') {
                                                      nameChangeStatus =
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .nameChangeSuccess;
                                                      UserProfile
                                                          newUserProfile =
                                                          userInfoService
                                                              .convertStringToJSON(
                                                                  value.body);
                                                      changeUsername(
                                                          newUserProfile);
                                                    } else {
                                                      nameChangeStatus =
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .nameChangeFailed;
                                                    }

                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        content: Text(
                                                            nameChangeStatus),
                                                        actions: [
                                                          Center(
                                                            child: ElevatedButton(
                                                                child:
                                                                    const Text(
                                                                        "Ok"),
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                        child: Text(
                            AppLocalizations.of(context)!.modifyUsername))),
                Container(
                    width: buttonWidth,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                GetIt.instance<SettingService>().isLightMode
                                    ? Color(0xff0e6ba8)
                                    : Color(0xff3a506b)),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  backgroundColor: Colors.black,
                                  child: AvatarOption(
                                      userName_: userProfile.userName,
                                      isNewAccount: false,
                                      callback: (String newAvatarURL) {
                                        changeAvatar(newAvatarURL);
                                      }),
                                );
                              });
                        },
                        child:
                            Text(AppLocalizations.of(context)!.modifyAvatar))),
                Container(
                    width: buttonWidth,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                GetIt.instance<SettingService>().isLightMode
                                    ? Color(0xff0e6ba8)
                                    : Color(0xff3a506b)),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.all(0),
                                        margin: const EdgeInsets.all(0),
                                        height: 800,
                                        width: 1000,
                                        child: Column(
                                          // mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              width: 1000,
                                              height: 700,
                                              child:
                                                  LoginHistory(userInfoService),
                                            ),
                                            Container(
                                                height: 50,
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .all(10),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: ElevatedButton(
                                                    child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .close),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                        child: Text(AppLocalizations.of(context)!
                            .showConnectionHistory))),
                Container(
                    width: buttonWidth,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                GetIt.instance<SettingService>().isLightMode
                                    ? Color(0xff0e6ba8)
                                    : Color(0xff3a506b)),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.all(0),
                                        margin: const EdgeInsets.all(0),
                                        height: 800,
                                        width: 1000,
                                        child: Column(
                                          // mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              width: 1000,
                                              height: 700,
                                              child:
                                                  GameHistory(userInfoService),
                                            ),
                                            Container(
                                                height: 50,
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .all(10),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: ElevatedButton(
                                                    child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .close),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                        child: Text(
                            AppLocalizations.of(context)!.showGamesHistory))),
                TextButton(
                    onPressed: () => logoutAlert(),
                    child: Text(AppLocalizations.of(context)!.logout))
              ],
            ))
      ],
    );
  }

  changeUsername(
    UserProfile userProfile,
  ) {
    setState(() {
      userInfoService.setUserProfile(userProfile);
      userInfoService.refreshUserProfile();
    });
  }

  changeAvatar(String newAvatarURL) {
    setState(() {
      userInfoService.userprofile.avatarURL = newAvatarURL;
      userInfoService.setUserProfile(userInfoService.userprofile);
    });
  }

  logoutAlert() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.disconnect),
          content: Text(AppLocalizations.of(context)!.disconnetConfirm),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(AppLocalizations.of(context)!.logout),
              onPressed: () {
                signInService.signOutUser(userInfoService.userprofile.userName,
                    userInfoService.userprofile.emailAddress!);
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  signInRoute,
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Route openChat() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const ChatPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.linearToEaseOut;

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
