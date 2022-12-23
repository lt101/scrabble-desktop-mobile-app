import 'dart:convert';
import 'dart:io';

import 'package:client_leger/constants/env.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class AvatarService {
  final String userInfoURL = '$serverURL/user-info';
  final storageRef = FirebaseStorage.instance.ref();
  late final Reference avatarsRef;
  String avatarURL_ = "";
  late String userName_;
  late ListResult avatarsList;

  AvatarService() {
    avatarsRef = storageRef.child('avatars');
    getAllAvatars();
  }

  set avatarURL(String url) {
    avatarURL_ = url;
  }

  set userName(String name) {
    userName_ = name;
  }

  Future<String> updateUserProfil() async {
    String status = await http
        .patch(Uri.parse('$serverURL/user-info/$userName_/profil-picture'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'avatarURL': avatarURL_,
            }))
        .then((rep) {
      switch (rep.statusCode) {
        case HttpStatus.ok:
          return "L'avatar a été modifié avec succès!";
        case HttpStatus.badRequest:
          return "Erreur: l'utilisateur n'existe pas";
        default:
          return "Erreur inconnue";
      }
    });
    return status;
  }

  getAllAvatars() async {
    avatarsList = await avatarsRef.listAll();
  }

  Future<ListResult> allAvatars() async {
    return avatarsList;
  }
}
