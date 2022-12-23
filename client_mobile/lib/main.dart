import 'package:audioplayers/audioplayers.dart';
import 'package:client_leger/classes/SidebarInformation.dart';
import 'package:client_leger/constants/routes.dart';
import 'package:client_leger/lang/l10n.dart';
import 'package:client_leger/provider/locale_provider.dart';
import 'package:client_leger/services/chat/chat_service.dart';
import 'package:client_leger/services/game/game_mode_service.dart';
import 'package:client_leger/services/game/grid_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/views/auth/register_view.dart';
import 'package:client_leger/views/auth/sign_in_view.dart';
import 'package:client_leger/views/chat/chat_view.dart';
import 'package:client_leger/views/game-mode/multiplayer-mode/multiplayer-create-page/multiplayer-create-page.dart';
import 'package:client_leger/views/game-mode/multiplayer-mode/multiplayer-create-page/waiting-players/waiting_players.dart';
import 'package:client_leger/views/game-mode/multiplayer-mode/multiplayer-join-page/multiplayer-join-page.dart';
import 'package:client_leger/views/game-mode/multiplayer-mode/multiplayer_mode.dart';
import 'package:client_leger/views/game/game_view.dart';
import 'package:client_leger/views/menu/main_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'services/game/easel_service.dart';
import 'services/game/game_service.dart';
import 'services/sockets/chat-socket/chat_socket_service.dart';

Future<void> main() async {
  GetIt getIt = GetIt.instance;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setSystemUIChangeCallback(
      (systemOverlaysAreVisible) async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  });
  // Register Singelton Instances
  getIt.registerSingleton<SettingService>(SettingService());
  getIt.registerSingleton<GameService>(GameService(), signalsReady: true);
  getIt.registerSingleton<SidebarInformations>(SidebarInformations(7, '', []),
      signalsReady: true);
  getIt.registerSingleton<EaselService>(EaselService());
  getIt.registerSingleton<ChatSocketService>(ChatSocketService());
  getIt.registerSingleton<GridService>(GridService(), signalsReady: true);
  getIt.registerSingleton<ChatService>(ChatService(), signalsReady: true);
  getIt.registerSingleton<GameModeService>(GameModeService());
  AudioPlayer(playerId: 'main')
      .play(AssetSource('audio/game-song.mp3'), volume: 5);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => LocaleProvider(),
        builder: (context, child) {
          final provider = Provider.of<LocaleProvider>(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            locale: provider.locale,
            supportedLocales: L10n.all,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            theme: ThemeData(
              primarySwatch: Colors.green,
            ),
            home: const SignIn(),
            routes: {
              chatRoute: (context) => ChatView(roomName_: "Global Chat Room"),
              registerRoute: (context) => const RegisterView(),
              signInRoute: (context) => const SignIn(),
              gameRoute: (context) => const GameView(
                    isObserving: false,
                  ),
              observerRoute: (context) => const GameView(isObserving: true),
              mainMenuRoute: (context) => const MainMenu(),
              multiPlayerModeRoute: (context) => const MultiPlayerMode(),
              multiPlayerCreatePageRoute: (context) =>
                  const MultiPlayerCreatePage(),
              multiPlayerJoinPageRoute: (context) =>
                  const MultiPlayerJoinPage(),
              waitingPlayers: (context) => WaitingPlayers(
                    isHost: false,
                  ),
            },
          );
        });
  }
}
