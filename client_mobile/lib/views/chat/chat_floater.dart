import 'package:client_leger/services/chat/chat_service.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get_it/get_it.dart';

class NotificationDot extends StatefulWidget {
  const NotificationDot({super.key});

  @override
  State<NotificationDot> createState() => _NotificationDotState();
}

class _NotificationDotState extends State<NotificationDot> {
  EventListener? eventListenerNofif;

  @override
  void initState() {
    eventListener();
    super.initState();
  }

  @override
  void dispose() {
    eventListenerNofif!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetIt.instance<ChatService>().isNewMessage
        ? Container(
            // This is your Badge
            constraints: const BoxConstraints(minHeight: 20, minWidth: 20),
            decoration: BoxDecoration(
              // This controls the shadow
              boxShadow: [
                BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 5,
                    color: Colors.black.withAlpha(50))
              ],
              borderRadius: BorderRadius.circular(50),
              color: const Color.fromARGB(
                  255, 243, 33, 33), // This would be color of the Badge
            ),
            // This is your Badge
            child: Center(
              // Here you can put whatever content you want inside your Badge
              child: Text(
                  GetIt.instance<ChatService>().newMessageCounter.toString(),
                  style: const TextStyle(color: Colors.white)),
            ),
          )
        : const SizedBox();
  }

  void eventListener() {
    eventListenerNofif = GetIt.instance<ChatService>().events.on('notif', (_) {
      setState(() {});
    });
  }
}
