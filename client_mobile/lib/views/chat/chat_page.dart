import 'package:client_leger/services/chat/chat_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/views/chat/chat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    GetIt.instance<ChatService>().chatIsOpen();
    super.initState();
  }

  @override
  void dispose() {
    GetIt.instance<ChatService>().chatIsClosed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Text(AppLocalizations.of(context)!.globalChat),
                Text(AppLocalizations.of(context)!.gameChat)
              ],
            ),
            title: Text(AppLocalizations.of(context)!.chat),
            backgroundColor: GetIt.instance<SettingService>().isLightMode
                ? const Color.fromARGB(255, 0, 124, 6)
                : const Color(0xff1c2541),
            toolbarHeight: 50,
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                );
              },
            )),
        body: TabBarView(children: [
          ChatView(roomName_: 'global'),
          ChatView(roomName_: 'inGame'),
        ]),
      ),
    );
  }
}
