class GameModeService {
  String gameMode = 'classic';
  bool isObjectiveMode = false;

  GameModeService();

  void setGameModeToObjectives() {
    gameMode = 'log2990';
    isObjectiveMode = true;
  }

  void setGameModeToClassic() {
    gameMode = 'classic';
    isObjectiveMode = false;
  }
}
