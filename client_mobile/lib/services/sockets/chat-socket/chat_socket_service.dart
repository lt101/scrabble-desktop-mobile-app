import 'dart:async';

import 'package:client_leger/classes/message.dart';
import 'package:client_leger/classes/user_profil.dart';
import 'package:client_leger/constants/socket_events.dart';
import 'package:client_leger/services/chat/chat_service.dart';
import 'package:client_leger/services/sockets/socket_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

class ChatSocketService {
  late SocketService socketService;
  StreamController<MessageL> controller = StreamController<MessageL>();
  StreamController newMessageController = StreamController();
  late UserProfile userProfile;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ChatSocketService() {
    socketService = SocketService();
  }

  StreamController<MessageL> get controller_ => controller;

  void chatSocketListener(UserProfile connectedUser) {
    if (socketService.socket!.disconnected) socketService.establishConnection();
    userProfile = connectedUser;
    socketService.socket!.off(chatEvent);
    socketService.socket!.on(chatEvent, (data) async {
      MessageL message = MessageL(
          gameId: data['gameId'],
          playerName: data['playerName'],
          content: data['content'],
          date: DateTime.parse("2022-01-01 ${data['time'] ?? "00:00:00"}"),
          isSentByMe: (userProfile.userName == data['playerName']));
      receivMessage(message);
      controller.add(message);
      if (message.content[0] != '!' &&
          !GetIt.instance<ChatService>().isChatOpen &&
          !message.content.contains("Ce placement est impossible")) {
        sendNotification(message);
      }
    });
  }

  initController() {
    controller.close();
    controller = StreamController<MessageL>();
  }

  socketHandler(data) async {
    MessageL message = MessageL(
        gameId: data['gameId'],
        playerName: data['playerName'],
        content: data['content'],
        date: DateTime.parse("2022-01-01 ${data['time'] ?? "00:00:00"}"),
        isSentByMe: (userProfile.userName == data['playerName']));
    receivMessage(message);
    controller.add(message);
    if (message.content[0] != '!' &&
        !GetIt.instance<ChatService>().isChatOpen &&
        !message.content.contains("Ce placement est impossible")) {
      sendNotification(message);
    }
  }

  void receivMessage(MessageL message) {
    if (message.gameId == null) {
      GetIt.instance<ChatService>().messageList['global']!.add(message);
    } else if (message.gameId != '') {
      GetIt.instance<ChatService>().messageList['inGame']!.add(message);
    }
  }

  void sendMessage(MessageL message) {
    socketService.socket!.emit(chatEvent, {
      'gameId': message.gameId,
      'playerId': '123',
      'playerName': message.playerName,
      'content': message.content,
    });
  }

  void sendNotification(MessageL message) async {
    if (message.playerName == 'Server') return;
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.low,
            icon: "@mipmap/ic_launcher",
            priority: Priority.low,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, 'Message', message.content, notificationDetails,
        payload: 'item x');
    GetIt.instance<ChatService>().newMessageNotif();
    GetIt.instance<ChatService>().emitNotifReceived();
  }
}
//