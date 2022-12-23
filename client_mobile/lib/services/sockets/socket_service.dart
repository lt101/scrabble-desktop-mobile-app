import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:client_leger/classes/message.dart';
import 'package:client_leger/constants/env.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SocketService {
  socket_io.Socket? socket;
  StreamController<MessageL> controller = StreamController<MessageL>();

  SocketService() {
    // Establish connection to server
    if (socket != null && socket!.connected) {
      socket!.disconnect();
    }
    socket = socket_io.io(
      serverSocketURL,
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      devtools.log('✓ Socket connected to server.\n');
    });

    socket!.onDisconnect(
        (_) => devtools.log('✗ Socket disconnected from server.\n'));
  }

  establishConnection() {
    socket!.connect();
  }
}
