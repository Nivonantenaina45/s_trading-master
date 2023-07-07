import 'dart:core';

import 'package:flutter/material.dart';

class UserModel {
  String? uid;
  String? email;
  String? nom;
  String? prenom;

  UserModel({this.uid, this.email, this.nom, this.prenom});
//receive data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      nom: map['nom'],
      prenom: map['prenom'],
    );
  }
//send data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nom': nom,
      'prenom': prenom,
    };
  }
}
