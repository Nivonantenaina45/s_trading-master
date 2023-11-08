import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  String? id;
  String? email;
  String? nom;
  String? prenom;

  UserModel({this.id, this.email, this.nom, this.prenom});
//receive data from server
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      nom: map['nom'],
      prenom: map['prenom'],
    );
  }
//send data to our server
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
    };
  }

  static saveUser(UserModel user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = jsonEncode(user.toMap());
    pref.setString("user", data);
  }

  static Future<UserModel?> getUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var data = pref.getString("user");

    if (data != null) {
      var decode = jsonDecode(data);
      var user = UserModel.fromJson(decode);
      return user;
    } else {
      return null; // Return null if user data doesn't exist in SharedPreferences
    }
  }
}
