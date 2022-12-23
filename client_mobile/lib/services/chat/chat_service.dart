import 'package:client_leger/classes/message.dart';
import 'package:events_emitter/emitters/event_emitter.dart';

class ChatService {
  EventEmitter events = EventEmitter();
  Map<String, List<MessageL>> messageList = {'global': [], 'inGame': []};
  bool isChatOpen = false;
  bool isNewMessage = false;
  int newMessageCounter = 0;
  ChatService();

  void emitNotifReceived() {
    events.emit('notif');
  }

  void clearMessagesInRoom(String roomName) {
    messageList[roomName]!.clear();
  }

  void deleteChatRoom(String roomName) {
    // Not allowed to delete general room chat
    if (roomName == 'global') return;
    messageList.remove(roomName);
  }

  Future<void> addChatRoom(String roomName) async {
    messageList.addAll({roomName: []});
  }

  void chatIsOpen() {
    isChatOpen = true;
    messageOpened();
  }

  void chatIsClosed() {
    isChatOpen = false;
  }

  void newMessageNotif() {
    newMessageCounter++;
    isNewMessage = true;
  }

  void messageOpened() {
    newMessageCounter = 0;
    isNewMessage = false;
  }
}
