class UserProfile {
  String? emailAddress;
  String? password;
  String userName;
  bool? isSigned;
  String? avatarUrl;
  String? grade;
  String? level;
  int? gamePlayed;
  int? gameWon;
  int? gameLost;
  int? averagePoints;
  Duration? averageTime;

  UserProfile(this.password, this.userName);

  UserProfile.full(
    this.emailAddress,
    this.password,
    this.userName,
    this.isSigned,
    this.avatarUrl,
    this.grade,
    this.level,
    this.gamePlayed,
    this.gameWon,
    this.gameLost,
    this.averagePoints,
    this.averageTime,
  );

  UserProfile.Auth(this.emailAddress, this.password, this.userName);

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile.full(
      json['emailAddress'],
      json['password'],
      json['userName'],
      json['isSigned'],
      json['avatarUrl'],
      json['grade'],
      json['level'],
      json['gamePlayed'],
      json['gameWon'],
      json['gameLost'],
      json['averagePoints'],
      Duration.fromJSON(json['averageTime']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> userJSON = Map<String, dynamic>();
    userJSON["emailAddress"] = emailAddress;
    userJSON["password"] = "***";
    userJSON["userName"] = userName;
    userJSON["avatarUrl"] = avatarUrl;
    userJSON["grade"] = grade;
    userJSON["level"] = level;
    userJSON["gamePlayed"] = gamePlayed;
    userJSON["gameWon"] = gameWon;
    userJSON["gameLost"] = gameLost;
    userJSON["averagePoints"] = averagePoints;
    userJSON["averageTime"] = averageTime;
    return userJSON;
  }

  set avatarURL(String url) {
    avatarUrl = url;
  }
}

class Duration {
  int? minutes;
  int? seconds;

  Duration(this.minutes, this.seconds);

  factory Duration.fromJSON(Map<String, dynamic> json) {
    return Duration.full(
      json['minutes'],
      json['seconds'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> userJSON = Map<String, dynamic>();
    userJSON["minutes"] = minutes;
    userJSON["seconds"] = seconds;
    return userJSON;
  }

  Duration.full(
    this.minutes,
    this.seconds,
  );
}
