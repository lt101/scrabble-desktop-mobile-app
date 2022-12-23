import 'dart:async';

import 'package:bubble/bubble.dart';
import 'package:client_leger/classes/message.dart';
import 'package:client_leger/services/chat/chat_service.dart';
import 'package:client_leger/services/game/game_service.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:client_leger/services/sockets/chat-socket/chat_socket_service.dart';
import 'package:client_leger/services/user-info/user_info_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

//
final messageController = TextEditingController();
const String reg =
    '/^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)\$/';

enum MenuAction { logout, SignIn }

class ChatView extends StatefulWidget {
  ChatView({super.key, required this.roomName_});
  final String roomName_;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  String? userName;
  UserInfoService userInfoService = UserInfoService();
  StreamSubscription<MessageL>? streamSubscription;

  void sendMessageToServer(String text) {
    if (text.isEmpty) return;
    final message = MessageL(
      gameId: widget.roomName_ == 'global'
          ? null
          : GetIt.instance<GameService>().gameId,
      playerName: userName ?? "Non defini",
      content: text,
      date: DateTime.utc(2049, 0, 0, 0, 4, 20, 0),
      isSentByMe: true,
    );
    GetIt.instance<ChatSocketService>().sendMessage(message);
    messageController.clear();
  }

  void displayMessage(MessageL message) {
    setState(() {});
  }

  void receiveMessage(MessageL message) {
    if (message.playerName != userName) {
      displayMessage(message);
    } else {
      final myMessage = MessageL(
        gameId: message.gameId,
        playerName: userName ?? "Non defini",
        content: message.content,
        date: message.date,
        isSentByMe: true,
      );
      displayMessage(myMessage);
    }
  }

  @override
  void initState() {
    GetIt.instance<ChatSocketService>().initController();
    streamSubscription =
        GetIt.instance<ChatSocketService>().controller.stream.listen((message) {
      setState(() {});
      //receiveMessage(message);
    });
    setState(() {
      userInfoService.getCurrentUser().then((value) {
        userName = value.userName;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    streamSubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String room = 'inGame';
    if (widget.roomName_.contains('global')) {
      room = 'global';
    }
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        body: Material(
          color: GetIt.instance<SettingService>().isLightMode
              ? Colors.white
              : const Color.fromARGB(255, 47, 64, 85),
          child: Column(children: [
            Expanded(
              child: GroupedListView<MessageL, DateTime>(
                elements: GetIt.instance<ChatService>().messageList[room]!,
                order: GroupedListOrder.DESC,
                padding: const EdgeInsets.all(8),
                useStickyGroupSeparators: true,
                floatingHeader: true,
                reverse: true,
                groupBy: (message) => DateTime(
                    message.date.day, message.date.hour, message.date.minute),
                groupHeaderBuilder: (MessageL message) => SizedBox(
                  height: 40,
                  child: Center(
                    child: Card(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Text(
                          DateFormat.Hm().format(message.date),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                itemBuilder: (context, MessageL message) => Bubble(
                  alignment: message.isSentByMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  nip: message.isSentByMe
                      ? BubbleNip.rightTop
                      : BubbleNip.leftTop,
                  nipWidth: 16,
                  color: message.isSentByMe
                      ? const Color(0xff2176FF)
                      : Colors.grey.shade200,
                  elevation: 8,
                  margin: const BubbleEdges.only(top: 10),
                  radius: const Radius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 23),
                    child: Column(children: [
                      Text(
                        '${DateFormat.Hms().format(message.date)} | ${message.playerName}:',
                        style: TextStyle(
                            color: message.isSentByMe
                                ? Colors.white
                                : Colors.black),
                      ),
                      Padding(
                        padding: message.content.contains('.gif')
                            ? const EdgeInsets.all(0)
                            : const EdgeInsets.all(6.0),
                        child: message.content.contains('.gif')
                            ? Image.network(
                                message.content,
                                height: 300,
                                width: 300,
                              )
                            : Text(
                                message.content,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: message.isSentByMe
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            // Input Area
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 30, top: 20),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 25),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(100, 50)),
                      onPressed: () async {
                        final gif = await GiphyPicker.pickGif(
                          context: context,
                          apiKey: 'gl6BaY6Om6q8LRMP9JHIcN0A1wlGFGK2',
                          fullScreenDialog: false,
                          previewType: GiphyPreviewType.previewGif,
                          decorator: GiphyDecorator(
                            showAppBar: false,
                            searchElevation: 4,
                            giphyTheme: ThemeData.dark().copyWith(
                              inputDecorationTheme: const InputDecorationTheme(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        );
                        //GiphyImage.original(gif: ,)
                        //sendMessageToServer(gif!.bitlyGifUrl!);
                        //https://i.giphy.com/media/Y594e0S5Rw2NX9FxGb/200.gif
                        String code = gif!.url!.split('-').last;
                        String gifUrl =
                            'https://i.giphy.com/media/$code/200.gif';
                        sendMessageToServer(gifUrl);
                      },
                      child: const Text(
                        'Gifs',
                        style: TextStyle(fontSize: 20),
                      )),
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(15),
                        hintText: AppLocalizations.of(context)!.enterMessage,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        )),
                    style: const TextStyle(fontSize: 14),
                    onSubmitted: (text) =>
                        text.isEmpty ? {} : sendMessageToServer(text.trim()),
                    onEditingComplete: () {},
                  ),
                ),
                IconButton(
                    padding: const EdgeInsets.only(bottom: 28, left: 10),
                    onPressed: () => messageController.text.isEmpty
                        ? {}
                        : sendMessageToServer(messageController.text.trim()),
                    icon: Icon(
                      Icons.send,
                      size: 50,
                      color: Colors.blue.shade700,
                    ))
              ]),
            )
          ]),
        ),
      ),
    );
  }
}
