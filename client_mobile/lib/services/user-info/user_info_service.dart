import 'dart:convert';

import 'package:client_leger/classes/user_profil.dart';
import 'package:client_leger/constants/env.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

class UserInfoService {
  late UserProfile userprofile;
  late List<dynamic> loginHistory;
  late List<dynamic> gameHistory;

  void setUserProfile(UserProfile userProfile) {
    userprofile = userProfile;
    SessionManager().set("currentUser", userProfile);
  }

  UserInfoService() {
    refreshUserProfile();
  }

  Future<void> refreshUserProfile() async {
    Map<String, dynamic> userSession =
        await SessionManager().get("currentUser") as Map<String, dynamic>;
    userprofile = UserProfile.fromJson(userSession);
  }

  Future<UserProfile> getCurrentUser() async {
    await refreshUserProfile();
    return userprofile;
  }

  Future<http.Response> sendNewUsernameToServer(
      String emailAddress, String currentUsername, String newUsername) async {
    http.Response response = await http.post(
        Uri.parse('$serverURL/user-info/$currentUsername/change-username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, String>{
          'emailAddress': emailAddress,
          'newUsername': newUsername,
        }));
    return response;
  }

  Future<List<dynamic>> getLoginHistory() async {
    http.Response response = await http.post(
        Uri.parse(
            '$serverURL/user-info/${userprofile.userName}/connection-history'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, String>{
          'emailAddress': userprofile.emailAddress!,
        }));
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getGamesPlayedHistory() async {
    http.Response response = await http.post(
        Uri.parse(
            '$serverURL/user-info/${userprofile.userName}/game-played-history'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, String>{
          'emailAddress': userprofile.emailAddress!,
        }));
    return jsonDecode(response.body);
  }

  getUserUpdateFromServer() async {
    http.Response response = await http.post(
        Uri.parse(
            '$serverURL/user-info/${userprofile.userName}/user-info-update'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, String>{
          'emailAddress': userprofile.emailAddress!,
        }));
    setUserProfile(UserProfile.fromJson(jsonDecode(response.body)[0]));
  }

  getUserPreferences() async {
    http.Response response = await http.post(
      Uri.parse(
        '$serverURL/user-info/${userprofile.userName}/data-persistence',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json
          .encode(<String, String>{'emailAddress': userprofile.emailAddress!}),
    );
    dynamic prefObject = jsonDecode(response.body);
    GetIt.instance<SettingService>()
        .setTheme(prefObject['visualTheme'] == 'light');
    GetIt.instance<SettingService>().setLanguage(prefObject['language']);
  }

  updatePrefTheme() async {
    String theme =
        GetIt.instance<SettingService>().isLightMode ? 'light' : 'dark';
    await http.post(
      Uri.parse(
        '$serverURL/user-info/${userprofile.userName}/update-visual-theme',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(<String, String>{
        'emailAddress': userprofile.emailAddress!,
        'visualTheme': theme,
      }),
    );
  }

  updatePregLanguage(String lang) async {
    await http.post(
      Uri.parse(
        '$serverURL/user-info/${userprofile.userName}/update-language',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(<String, String>{
        'emailAddress': userprofile.emailAddress!,
        'language': lang,
      }),
    );
  }

  UserProfile convertStringToJSON(String userProfile) {
    return UserProfile.fromJson(jsonDecode(userProfile));
  }
}
