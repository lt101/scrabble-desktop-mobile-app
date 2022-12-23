import 'package:client_leger/classes/letter.dart';
import 'package:events_emitter/events_emitter.dart';

class GridService {
  EventEmitter events = EventEmitter();
  List<Letter> lettersPlaced = [];

  void cancelLetterPlaced() {
    events.emit('cancel');
  }

  void emitPlacedLetters(String letter) {
    events.emit('placed', letter);
  }

  void emitRemovedLetters(String letter) {
    events.emit('removed', letter);
  }
}
