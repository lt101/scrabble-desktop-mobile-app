import 'package:client_leger/classes/SidebarPlayerInformations.dart';

class SidebarInformations {
  int reserveSize;
  String? currentPlayerId;
  List<SidebarPlayerInformations> players = [];

  SidebarInformations(this.reserveSize, this.currentPlayerId, this.players);

  setPlayerInfo(dynamic data) async {
    players.clear();
    for (dynamic player in (data['players'] as List<dynamic>)) {
      players.add(SidebarPlayerInformations(
          player['playerName'], player['score'], player['playerId']));
    }
  }

  setCurrentPlayer(String currentPlayer) {
    currentPlayerId = currentPlayer;
  }
}
