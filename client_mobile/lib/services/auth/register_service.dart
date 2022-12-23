import 'dart:convert';
import 'dart:io';

import 'package:client_leger/constants/env.dart';
import 'package:http/http.dart' as http;

class RegisterService {
  final String registerURL = '$serverURL/auth/register';

  RegisterService();

  Future<String> registerNewAccount(
      String userName, String email, String password) async {
    String messageFromServer = "";
    await sendUserInfoToServer(userName, email, password).then((rep) {
      messageFromServer = treatServerResponse(rep.statusCode);
    }).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        messageFromServer = "Error: Server Timeout";
      },
    );
    return messageFromServer;
  }

  Future<http.Response> sendUserInfoToServer(
      String userName, String email, String password) async {
    http.Response response =
        await http.post(Uri.parse('$serverURL/auth/register'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'emailAddress': email,
              'password': password,
              'userName': userName,
            }));
    return response;
  }

  String treatServerResponse(int responseStatus) {
    switch (responseStatus) {
      case HttpStatus.created:
        return "success";
      case HttpStatus.conflict:
        return "L'adresse mail a deja ete prise.";
      case HttpStatus.notAcceptable:
        return "Le nom d'utilisateur n'est pas disponible.";
      default:
        return "Erreur inconnue.";
    }
  }
}
