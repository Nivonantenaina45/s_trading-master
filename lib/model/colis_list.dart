import 'package:flutter/material.dart';

class ColisCodebarre {
  String? tracking;
  String? trackingCarton;
  String? etat;

  ColisCodebarre({this.tracking, this.trackingCarton, this.etat});

  factory ColisCodebarre.fromMap(map) {
    return ColisCodebarre(
        tracking: map['tracking'],
        trackingCarton: map['trackingCarton'],
        etat: map['etat']);
  }
  Map<String, dynamic> toMap() {
    return {
      'tracking': tracking,
      'trackingCarton': trackingCarton,
      'etat': etat,
    };
  }
}
