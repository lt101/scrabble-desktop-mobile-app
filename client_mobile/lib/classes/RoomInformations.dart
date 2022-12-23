class RoomInformations {
  String? id;
  String? hostName;
  GameParameters? parameters;
  List<String>? playersName_;
  List<String>? observers_;

  RoomInformations(this.id, this.hostName, gameParams, players, observers) {
    parameters = gameParams;
    playersName_ = players;
    observers_ = observers;
  }

  factory RoomInformations.fromJSON(Map<String, dynamic> json) {
    GameParameters parameters = GameParameters(
      json['parameters']['dictionary'],
      json['parameters']['mode'],
      json['parameters']['timer'],
      json['parameters']['visibility'],
      json['parameters']['password'],
    );
    List<String> playersName = [];
    List<String>? observers = [];
    for (dynamic player in (json['players'] as List<dynamic>)) {
      playersName.add(player['name'].toString());
    }
    for (dynamic observer in (json['observers'] as List<dynamic>)) {
      observers.add(observer['name'].toString());
    }
    return RoomInformations(
        json['id'], json['hostName'], parameters, playersName, observers);
  }
}

class GameParameters {
  int? timer;
  String? dictionary;
  String? mode;
  String visibility;
  String password;

  GameParameters(
      this.dictionary, this.mode, this.timer, this.visibility, this.password);

  Map toJson() => {
        'timer': timer,
        'dictionary': dictionary,
        'mode': mode,
        'visibility': visibility,
        'password': password,
      };
}
