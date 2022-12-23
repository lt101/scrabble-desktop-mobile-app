import 'package:shared_preferences/shared_preferences.dart';

class SettingService {
  bool isLightMode = true;
  bool isFrench = true;
  String language_ = 'fr';
  String boardSkin = 'default';
  bool isDefaultSkin = true;
  bool isSocketInit = false;
  bool isSocketRefresh = false;
  SettingService();

  switchLanguge() {
    isFrench = !isFrench;
  }

  switchTheme() async {
    isLightMode = !isLightMode;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('theme', isLightMode);
  }

  setTheme(bool isLight) {
    isLightMode = isLight;
  }

  setLanguage(String language) {
    language_ = language;
  }

  setBoardSkin(String skin) {
    boardSkin = skin;
    isDefaultSkin = skin == 'default';
  }

  getSkinUrl() {
    if (boardSkin == 'wood') {
      return 'assets/images/wood-board.jpg';
    } else if (boardSkin == 'metal') {
      return 'assets/images/metal-skin.png';
    }
  }

  socketIsInit() {
    isSocketInit = true;
  }

  socketDisconnected() {
    isSocketInit = false;
  }
}
