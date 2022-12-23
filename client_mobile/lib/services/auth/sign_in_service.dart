import 'dart:convert';
import 'dart:io';

import 'package:client_leger/classes/user_profil.dart';
import 'package:client_leger/constants/env.dart';
import 'package:client_leger/services/settings/settings_service.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

class SignInService {
  final String signInURL = serverURL;

  SignInService();

  dynamic signInToAccount(String email, String password) async {
    late UserProfile user;
    var res = await _sendUserInfoToServer(email, password);
    switch (res.statusCode) {
      case HttpStatus.ok:
        final Map<String, dynamic> response = jsonDecode(res.body);
        user = UserProfile.fromJson(response['newUserProfile']);
        // getUserPreferences(user);
        break;
      case HttpStatus.forbidden:
        return 'user-already-connected';
      case HttpStatus.unauthorized:
        return 'user-incorrect-password';
      case HttpStatus.notFound:
        return 'user-not-exist';
      default:
        return 'unknown';
    }
    return user;
  }

  getUserPreferences(UserProfile user) async {
    http.Response response = await http.post(
      Uri.parse(
        '$serverURL/user-info/${user.userName}/data-persistence',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(<String, String>{'emailAddress': user.emailAddress!}),
    );
    dynamic prefObject = jsonDecode(response.body);
    GetIt.instance<SettingService>()
        .setTheme(prefObject['visualTheme'] == 'light');
    GetIt.instance<SettingService>().setLanguage(prefObject['language']);
  }

  Future<http.Response> _sendUserInfoToServer(
      String email, String password) async {
    http.Response response =
        await http.post(Uri.parse('$signInURL/auth/sign-in'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: json.encode(<String, String>{
              'emailAddress': email,
              'password': password,
            }));
    return response;
  }

  void signOutUser(String username, String email) {
    SessionManager().remove('currentUser');
    http.patch(Uri.parse('$signInURL/auth/$username/sign-out'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(<String, String>{
          'emailAddress': email,
        }));
  }
}
